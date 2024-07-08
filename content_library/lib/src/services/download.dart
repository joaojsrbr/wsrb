// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:content_library/content_library.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:flutter/foundation.dart';

class DownloadService extends ChangeNotifier {
  Future<void> download() async {}

  final List<DownloadInfo> downloadList = [];

  final _downloadDir = Directory('/storage/emulated/0/Download');

  Future<void> cancelReleaseDownload({
    required Content content,
    required Release release,
    required int sessionId,
  }) async {
    await FFmpegKit.cancel(sessionId);
    downloadList.removeWhere(
      (element) => release.stringID == element.releaseId,
    );
    notifyListeners();
    // await deleteReleaseFile(content: content, release: release);
  }

  Future<bool> deleteReleaseFile({
    String? path,
    required Content content,
    required Release release,
  }) async {
    final result = Directory(
      path ?? '${_downloadDir.path}/wsrb/${content.title}',
    );
    final file = File('${result.path}/episodio_${release.number}.mp4');

    if (await result.exists() && await file.exists()) {
      await file.delete(recursive: true);
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  File getReleasFile(
    Content content,
    Release release,
  ) {
    return File(
        '${_downloadDir.path}/wsrb/${content.title}/episodio_${release.number}.mp4');
  }

  bool existsRelease(
    Content content,
    Release release,
  ) {
    // final result = await Directory(
    //   '${downloadDir.path}/wsrb/${content.title}/episodio_${release.number}.mp4',
    // ).exists();

    final file = File(
        '${_downloadDir.path}/wsrb/${content.title}/episodio_${release.number}.mp4');

    return file.existsSync();

    // try {
    //   final result = Directory(
    //     '${_downloadDir.path}/wsrb/${content.title}',
    //   ).listSync();

    //   return result.any((releaseFile) =>
    //       releaseFile.path.contains('episodio_${release.number}.mp4'));
    // } on PathNotFoundException catch (_) {
    //   return false;
    // }
  }

  Future<void> downloadReleaseVideoByHLS(
    Release release,
    Content content,
    ContentRepository repository, {
    void Function(Statistics statistics)? statisticsCallback,
    void Function(Result result)? onResult,
  }) async {
    if (await PermissionUtils.manageExternalStorage() && content is Anime) {
      final videoData =
          await repository.source(content.source).getContent(release);

      videoData.fold(
        onSuccess: (success) async {
          final selected = success.first as VideoData;

          if (selected.videoContent.contains('m3u8')) {
            final releaseDir =
                Directory('${_downloadDir.path}/wsrb/${content.title}');

            if (!await releaseDir.exists()) {
              await releaseDir.create(recursive: true);
            }

            List<String> args = [
              '-i',
              selected.videoContent,
              '-c',
              'copy',
              '-v trace',
              '"${releaseDir.path}/episodio_${release.number}.mp4"',
            ];

            selected.httpHeaders?.keys.toList().reversed.forEach(
              (key) {
                final value = selected.httpHeaders![key];
                args.insert(0, '-headers "$key:$value"');
              },
            );

            customLog(args.join(' '));

            await FFmpegKit.executeAsync(
              args.join(' '),
              (session) async {
                final returnCode = await session.getReturnCode();

                final info = downloadList.firstWhereOrNull(
                  (info) => info.releaseId == release.stringID,
                );

                if (info != null) {
                  info.setValue(isDownloading: false);
                  downloadList.remove(info);
                  notifyListeners();
                  info.dispose();
                }

                if (ReturnCode.isSuccess(returnCode)) {
                  onResult?.call(const Result.success(true));
                } else if (ReturnCode.isCancel(returnCode)) {
                  onResult?.call(const Result.cancel());
                } else {
                  onResult?.call(Result.failure(Exception(returnCode)));
                }
              },
              null,
              (status) async {
                (downloadList.firstWhere(
                  (info) => info.releaseId == release.stringID,
                  orElse: () {
                    final info = DownloadInfo(
                      id: status.getSessionId(),
                      releaseId: release.stringID,
                      isDownloading: true,
                    );
                    downloadList.add(info);
                    notifyListeners();
                    return info;
                  },
                )).setValue(
                  isDownloading: true,
                  speed: status.getSpeed(),
                  bitrate: status.getBitrate(),
                );

                statisticsCallback?.call(status);
              },
            );
          }
        },
      );
    }
  }

  void clearDownloadList() {
    for (final download in downloadList) {
      download.dispose();
    }
    downloadList.clear();
  }

  @override
  void dispose() {
    for (final download in downloadList) {
      download.dispose();
    }
    super.dispose();
  }
}

// class DownloadList extends ListBase<DownloadInfo> with ChangeNotifier {
//   @override
//   void add(DownloadInfo element) {
//     notifyListeners();
//     _array.add(element);
//   }

//   final List<DownloadInfo> _array = [];

//   @override
//   int get length => _array.length;

//   @override
//   DownloadInfo operator [](int index) => _array[index];

//   @override
//   void operator []=(int index, DownloadInfo value) => _array[index] = value;

//   @override
//   set length(int newLength) => _array.length = newLength;
// }

class DownloadInfo with ChangeNotifier {
  int id;
  bool isDownloading;
  String releaseId;
  double speed;
  double bitrate;

  DownloadInfo({
    required this.id,
    required this.releaseId,
    this.bitrate = 0.0,
    this.speed = 0.0,
    this.isDownloading = false,
  });

  void setValue({
    int? id,
    bool? isDownloading,
    String? releaseId,
    double? speed,
    double? bitrate,
  }) {
    this.id = id ?? this.id;
    this.speed = speed ?? this.speed;
    this.bitrate = bitrate ?? this.bitrate;
    this.releaseId = releaseId ?? this.releaseId;
    this.isDownloading = isDownloading ?? this.isDownloading;

    notifyListeners();
    customLog(toString());
  }

  @override
  String toString() {
    return 'DownloadInfo(id: $id, isDownloading: $isDownloading, speed: $speed, bitrate: $bitrate)';
  }
}
