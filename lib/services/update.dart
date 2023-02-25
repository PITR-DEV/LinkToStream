import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:linktostream/consts.dart';
import 'package:linktostream/helper/path_helper.dart';

Future<String?> updateAvailable() async {
  final file = File('$ytDlpPath.exe');

  String? hash;

  if (await file.exists()) {
    hash = _hashLocalCopy(file);
  }

  var res = await Dio().get(ytDlpReleaseUrl);
  Map<String, dynamic> json = res.data;

  var assets = json['assets'] as List<dynamic>;

  if (hash != null) {
    var hashAsset =
        assets.firstWhere((element) => element['name'] == 'SHA2-256SUMS');

    // Download the file
    res = await Dio().get(hashAsset['browser_download_url'] as String);

    // Look for the latest hash
    var lines = const LineSplitter().convert(res.data);
    var line = lines.firstWhere((element) => element.contains('yt-dlp.exe'));

    var isUpToDate = line.startsWith(hash);

    if (isUpToDate) return null;
  }

  var exeUrl = assets.firstWhere((element) => element['name'] == 'yt-dlp.exe');
  return exeUrl['browser_download_url'] as String;
}

Future<void> downloadUpdate(String exeUrl) async {
  var res = await Dio()
      .get(exeUrl, options: Options(responseType: ResponseType.bytes));

  final file = File('$ytDlpPath.exe');
  await file.writeAsBytes(res.data);
  print('Update complete');
}

String _hashLocalCopy(File file) {
  final bytes = file.readAsBytesSync();
  final hash = sha256.convert(bytes).toString();

  print('$hash  yt-dlp.exe');
  return hash;
}
