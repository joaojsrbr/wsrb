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
  }

  Future<bool> deleteReleaseFile({
    String? path,
    required Content content,
    required Release release,
  }) async {
    final file = AppStorage.getReleaseFile(content, release);

    if (file != null) {
      await AppStorage.deleteFile(file.path, recursive: true);
    }

    notifyListeners();
    return file != null;
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
            final releaseDir = Directory(
                '${AppStorage.DOWNLOAD_DIR.path}/wsrb/${content.title.toID}');

            if (!await releaseDir.exists()) {
              await releaseDir.create(recursive: true);
            }

            List<String> args = [
              '-headers "referer:${repository.source(content.source).BASE_URL}/"',
              '-i',
              selected.videoContent,
              '-c',
              'copy',
              '"${releaseDir.path}/episodio_${release.number}.mp4"',
            ];

            // selected.httpHeaders?.keys.toList().reversed.forEach(
            //   (key) {
            //     final value = selected.httpHeaders![key];
            //     args.insert(0, '-headers "$key:$value"');
            //   },
            // );

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
              (test) => customLog(test.getMessage()),
              (status) async {
                (downloadList.firstWhere(
                  (info) => info.releaseId == release.stringID,
                  orElse: () {
                    final info = DownloadInfo(
                      path: '${releaseDir.path}/episodio_${release.number}.mp4',
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
    clearDownloadList();
    super.dispose();
  }
}

class DownloadInfo with ChangeNotifier {
  int id;
  bool isDownloading;
  String releaseId;
  double speed;
  double bitrate;
  String path;

  DownloadInfo({
    required this.id,
    required this.releaseId,
    required this.path,
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
