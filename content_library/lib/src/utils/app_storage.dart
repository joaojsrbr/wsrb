// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:io';

import 'package:content_library/content_library.dart';

class AppStorage {
  AppStorage._();

  static bool checkFileExists(String path) {
    return File(path).existsSync();
  }

  static bool checkDirExists(String path) {
    return Directory(path).existsSync();
  }

  static List<FileSystemEntity>? getAllReleaseDir() {
    final dirPath = '${AppStorage.DOWNLOAD_DIR.path}/';

    final dir = Directory(dirPath);

    return switch (dir.existsSync()) {
      true => dir.listSync(),
      false => null,
    };
  }

  static Future<FileSystemEntity> deleteFile(String path,
      {bool recursive = false}) async {
    return await Directory(path).delete(recursive: recursive);
  }

  static final DOWNLOAD_DIR = Directory('${App.APP_DIRECTORY}/donwload');

  static File? getReleaseFile(Content content, Release release) {
    final dirPath = '${AppStorage.DOWNLOAD_DIR.path}/${content.title.toID}';
    final filePath = '$dirPath/episodio_${release.number}.mp4';
    final file = File(filePath);
    return file.existsSync() ? file : null;
  }
}
