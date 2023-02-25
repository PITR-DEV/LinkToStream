import 'package:flutter/material.dart';
import 'package:linktostream/services/update.dart';

class UpdateChecker extends StatefulWidget {
  const UpdateChecker({Key? key}) : super(key: key);

  @override
  createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  bool _checking = true;
  bool _failed = false;
  bool _success = false;
  String? _updateUrl;

  @override
  void initState() {
    super.initState();
    updateAvailable().then((value) {
      if (value != null) {
        setState(() {
          _checking = false;
          _updateUrl = value;
        });
      } else {
        setState(() {
          _checking = false;
        });
      }
    }).catchError((error) {
      setState(() {
        _checking = false;
        _failed = true;
      });
    });
  }

  Widget _content() {
    if (_checking) return const LinearProgressIndicator();
    if (_failed) return const Text('Failed to check for updates');
    if (_success) return const Text('Update successful');
    if (_updateUrl?.isNotEmpty ?? false) {
      return Text('Newer version of yt-dlp is available\n\n$_updateUrl');
    }
    return const Text('No update available');
  }

  List<Widget> _actions() {
    if (_checking) return [];
    if (_failed) {
      return [
        FilledButton.tonal(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
                context: context, builder: (context) => const UpdateChecker());
          },
          child: const Text('Retry'),
        )
      ];
    }
    if (_success) {
      return [
        FilledButton.tonal(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ];
    }
    if (_updateUrl?.isNotEmpty ?? false) {
      return [
        FilledButton(
          onPressed: () {
            setState(() {
              _checking = true;
            });
            downloadUpdate(_updateUrl!).then((_) {
              setState(() {
                _checking = false;
                _success = true;
                _updateUrl = null;
              });
            }).catchError((error) {
              setState(() {
                _checking = false;
                _failed = true;
              });
            });
          },
          child: const Text('Update'),
        )
      ];
    }
    return [
      FilledButton.tonal(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Updater'),
      content: _content(),
      actions: _actions(),
    );
  }
}
