import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linktostream/components/error_dialog.dart';
import 'package:linktostream/consts.dart';
import 'package:linktostream/helper/path_helper.dart';
import 'package:linktostream/helper/prefs_helper.dart';
import 'package:linktostream/notification_layer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

const clipboardTriggers = <String>['youtu.be/', 'youtube.com/watch?v='];

class _MainScreenState extends State<MainScreen> {
  bool _active = false;
  bool _processing = false;
  bool _processingTimeout = false;
  int _clipboardConversions = 0;
  final TextEditingController _controller = TextEditingController();
  Timer? _clipboardTimer;
  Timer? _processingCancelTimer;

  final List<String> _failedUrls = [];

  String stripVideoId(String videoId) {
    if (videoId.length == 11) return videoId;
    var lastSegment =
        videoId.contains('=') ? videoId.indexOf('=') : videoId.lastIndexOf('/');
    if (lastSegment == -1) return videoId;
    videoId = videoId.substring(lastSegment + 1);
    if (videoId.length == 11) return videoId;
    videoId = videoId.substring(0, videoId.length < 11 ? videoId.length : 11);

    return videoId;
  }

  String? vidUrl(List<dynamic> fs) {
    var availableQualities = fs
        .where((element) =>
            element['acodec'] != null &&
            element['vcodec'] != null &&
            element['acodec'] != 'none' &&
            element['vcodec'] != 'none')
        .toList();
    availableQualities.sort((a, b) {
      if (!a.containsKey('quality')) return 1;
      if (!b.containsKey('quality')) return -1;
      return a['quality'].compareTo(b['quality']);
    });

    if (availableQualities.isEmpty) return null;

    return availableQualities.last['url'];
  }

  void showError(String error) {
    showDialog(context: context, builder: (context) => ErrorDialog(error));
  }

  Future<String?> fetchAndPickStream(String link) async {
    if (_failedUrls.contains(link)) return null;
    link = 'https://youtu.be/$link';
    print('fetching data for $link');
    var result =
        await Process.run(ytDlpPath, ['--dump-json', '--skip-download', link]);
    if (result.exitCode != 0) {
      final error = result.stderr;
      _failedUrls.add(link);
      cancelProcessing();
      showError(error);
      return null;
    }

    if (result.stdout.isEmpty) {
      print('No video found');
      cancelProcessing();
      return null;
    }

    var data = jsonDecode(result.stdout.trim()) as Map<String, dynamic>;
    var fs = data['formats'] as List<dynamic>;
    var r = vidUrl(fs);
    return r;
  }

  void startProcessing() {
    if (_processing) return;

    print('processing started');

    setState(() {
      _processing = true;
      _processingTimeout = false;
    });

    _processingCancelTimer = Timer(const Duration(seconds: 6), () {
      setState(() {
        _processingTimeout = true;
      });
    });
  }

  void cancelProcessing() {
    setState(() {
      _processing = false;
      _processingTimeout = false;
    });

    _processingCancelTimer?.cancel();
  }

  Future<void> clipboardHandler() async {
    {
      if (_processing) return;
      var clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

      if (clipboardData?.text == null) return cancelProcessing();
      if (clipboardData!.text!.isEmpty) return cancelProcessing();

      var linkDetected = false;
      for (var trigger in clipboardTriggers) {
        if (clipboardData.text!.contains(trigger)) {
          linkDetected = true;
          break;
        }
      }
      if (!linkDetected) return cancelProcessing();

      startProcessing();

      var directStream =
          await fetchAndPickStream(stripVideoId(clipboardData.text!));
      if (directStream == null) return cancelProcessing();

      Clipboard.setData(ClipboardData(text: directStream));
      _controller.text = directStream;
      setState(() {
        _clipboardConversions++;
        _processing = false;
      });
      NotificationLayerState.instance.sendNotification();
    }
  }

  void enableAutoClipboard() {
    _clipboardTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async {
      await clipboardHandler();
    });
  }

  bool isValidVideo(String url) {
    if (url.isEmpty) return false;

    // video id only
    if (url.length == 11 && RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(url)) {
      return true;
    }

    // full url
    if (url.contains('youtu.be/') || url.contains('youtube.com/watch?v=')) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    if (sharedPreferences.getBool(PrefConsts.autoConvertClipboard) ?? false) {
      setState(() {
        _active = true;
      });
      enableAutoClipboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              _active
                  ? 'Watching Clipboard ($_clipboardConversions converted)'
                  : 'LinkToStream',
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                icon: const Icon(Icons.settings),
                splashRadius: 24,
              ),
            ],
          ),
          body: Column(
            children: [
              ListTile(
                title: Text(
                  'Auto-Convert Clipboard',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
                subtitle: const Text(
                    'Automatically convert youtube links in your clipboard'),
                trailing: Switch(
                  value: _active,
                  onChanged: (value) async {
                    setState(() {
                      _active = value;
                    });
                    await sharedPreferences.setBool(
                        PrefConsts.autoConvertClipboard, value);
                    if (_active) {
                      enableAutoClipboard();
                    } else {
                      _clipboardTimer?.cancel();
                      _clipboardTimer = null;
                    }
                  },
                ),
              ),
              const Divider(
                thickness: 0.5,
              ),
              ListTile(
                title: Text(
                  'Manual',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        onPressed: () async {
                          var clipboardData =
                              await Clipboard.getData(Clipboard.kTextPlain);
                          if (clipboardData?.text == null) {
                            return cancelProcessing();
                          }
                          if (clipboardData!.text!.isEmpty) {
                            return cancelProcessing();
                          }

                          _controller.text = clipboardData.text!;
                          startProcessing();
                          var res = await fetchAndPickStream(
                              stripVideoId(clipboardData.text!));
                          if (res == null) return cancelProcessing();
                          _controller.text = res;
                          setState(() {
                            _processing = false;
                          });
                        },
                        icon: const Icon(Icons.content_paste_go),
                        iconSize: 20,
                        splashRadius: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        readOnly: _processing,
                        controller: _controller,
                        onChanged: (value) async {
                          var url = value.trim();
                          if (!isValidVideo(url)) return;
                          startProcessing();
                          var r = await fetchAndPickStream(stripVideoId(url));
                          if (r == null) return cancelProcessing();
                          _controller.text = r;
                          setState(() {
                            _processing = false;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Paste youtube link',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: _controller.text.trim(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        iconSize: 20,
                        splashRadius: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_processing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(140),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (_processingTimeout)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ElevatedButton(
                          onPressed: () {
                            cancelProcessing();
                          },
                          child: const Text('Cancel'),
                        ),
                      )
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }
}
