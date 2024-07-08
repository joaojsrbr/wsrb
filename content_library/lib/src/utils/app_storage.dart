// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:io';

import 'package:content_library/src/models/content.dart';
import 'package:content_library/src/models/release.dart';

class AppStorage {
  AppStorage._();

  static bool checkFileExists(String path) {
    return File(path).existsSync();
  }

  static bool checkDirExists(String path) {
    return Directory(path).existsSync();
  }

  static Future<FileSystemEntity> deleteFile(String path,
      {bool recursive = false}) async {
    return await Directory(path).delete(recursive: recursive);
  }

  static final DOWNLOAD_DIR = Directory('/storage/emulated/0/Download');

  static File? getReleaseFile(Content content, Release release) {
    final dirPath = '${AppStorage.DOWNLOAD_DIR.path}/wsrb/${content.title}';
    final filePath = '$dirPath/episodio_${release.number}.mp4';
    final file = File(filePath);
    return switch (file.existsSync()) {
      true => file,
      false => null,
    };
  }
}
