// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/statistics.dart';

class DownloadService extends ChangeNotifier {
  Future<void> download() async {}

  final List<DownloadInfo> downloadList = [];

  Future<void> cancelReleaseDownload({
    required Content content,
    required Release release,
    required int sessionId,
  }) async {
    await FFmpegKit.cancel(sessionId);
    downloadList.removeWhere((element) => release.stringID == element.releaseId);
    notifyListeners();
  }

  Future<bool> deleteReleaseFile({String? path, required Content content, required Release release}) async {
    final file = AppStorage.getReleaseFile(content, release);

    if (file != null) {
      await AppStorage.deleteFile(file.path, recursive: true);
    }

    final allFiles = Directory(
      '${AppStorage.DOWNLOAD_DIR.path}/${content.source.label.capitalize}/${content.title.toID}',
    );

    if (allFiles.listSync(recursive: true).isEmpty) {
      allFiles.deleteSync();
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
      final videoData = await repository.source(content.source).getContent(release);

      videoData.fold(
        onSuccess: (success) async {
          final selected = success.first as VideoData;

          if (selected.videoContent.contains('m3u8') || content.source == Source.GOYABU) {
            final releaseDir = Directory(
              '${AppStorage.DOWNLOAD_DIR.path}/${content.source.label.capitalize}/${content.title.toID}',
            );

            if (!await releaseDir.exists()) {
              await releaseDir.create(recursive: true);
            }

            List<String> args = [
              for (final header in (selected.httpHeaders ?? <String, String>{}).entries)
                '-headers "${header.key.capitalize}: ${header.value}"',
              '-i',
              '"${selected.videoContent}"',
              '-c',
              'copy',
              '${releaseDir.path}/episodio_${release.number}.mp4',
            ];

            final Completer completer = Completer();

            await FFprobeKit.getMediaInformationFromCommand(
              [
                for (final header in (selected.httpHeaders ?? <String, String>{}).entries)
                  '-headers "${header.key.capitalize}: ${header.value}"',
                '-i',
                '"${selected.videoContent}"',
              ].join(' '),
            ).then((session) async {
              final output = await session.getOutput();
              final RegExp rgDuration = RegExp(r"(Duration:).*[0-9](, start)");

              if (output != null) {
                final duration = rgDuration
                    .stringMatch(output)
                    ?.replaceAll(', start', '')
                    .replaceAll('Duration:', '')
                    .trim();

                final info = DownloadInfo(
                  path: '${releaseDir.path}/episodio_${release.number}.mp4',
                  id: -1,
                  releaseId: release.stringID,
                  isDownloading: false,
                  videoDuration: duration?.parseDuration,
                );
                downloadList.add(info);
                completer.complete();
                notifyListeners();
              }
            });

            await completer.future;
            customLog(args.join(' '));

            // https: //cdn-zenitsu-2-gamabunta.b-cdn.net/cf/hls/animes/jidou-hanbaiki-ni-umarekawatta-ore-wa-meikyuu-wo-samayou-2/001.mp4/media-1/stream.m3u8

            await FFmpegKit.executeAsync(
              args.join(' '),
              (session) async {
                final returnCode = await session.getReturnCode();

                final info = downloadList.firstWhereOrNull((info) => info.releaseId == release.stringID);

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
              (test) {
                customLog(test.getMessage());
              },
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
                  time: status.getTime().toDouble(),
                  id: status.getSessionId(),
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

  @override
  void dispose() {
    for (final download in downloadList) {
      download.dispose();
    }
    downloadList.clear();
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
  Duration? videoDuration;
  double time;

  DownloadInfo({
    required this.id,
    required this.releaseId,
    required this.path,
    this.videoDuration,
    this.time = 0.0,
    this.bitrate = 0.0,
    this.speed = 0.0,
    this.isDownloading = false,
  });

  String getStringDownloadPercent() => '${(((time * 100) / videoDuration!.inMilliseconds)).ceil().toString()}%';

  String getSpeedString() => ' - speed: ${speed.toStringAsFixed(2)}';

  void setValue({
    int? id,
    double? time,
    bool? isDownloading,
    String? releaseId,
    double? speed,
    double? bitrate,
    Duration? videoDuration,
  }) {
    this.videoDuration = videoDuration ?? this.videoDuration;
    this.id = id ?? this.id;
    this.time = time ?? this.time;
    this.speed = speed ?? this.speed;
    this.bitrate = bitrate ?? this.bitrate;
    this.releaseId = releaseId ?? this.releaseId;
    this.isDownloading = isDownloading ?? this.isDownloading;

    notifyListeners();
    // customLog(toString());
    // customLog(this.time ~/ (videoDuration?.inMilliseconds ?? 0.0));
  }

  @override
  String toString() {
    return 'DownloadInfo(id: $id, isDownloading: $isDownloading, releaseId: $releaseId, speed: $speed, bitrate: $bitrate, videoDuration: $videoDuration, time: $time)';
  }
}
