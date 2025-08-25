// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:content_library/content_library.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_new_gpl/statistics.dart';
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
    downloadList.removeWhere((element) => release.stringID == element.releaseId);
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

    final allFiles = Directory(
      '${AppStorage.DOWNLOAD_DIR.path}/${content.source.label.capitalize}/${content.title.toID}',
    );

    if (allFiles.listSync(recursive: true).isEmpty) {
      allFiles.deleteSync();
    }

    notifyListeners();
    return file != null;
  }

  // void _bindBackgroundIsolate(ReceivePort port, String id) {
  //   final isSuccess = IsolateNameServer.registerPortWithName(port.sendPort, id);
  //   if (!isSuccess) {
  //     _unbindBackgroundIsolate(id);
  //     _bindBackgroundIsolate(port, id);
  //   }
  // }

  // void _unbindBackgroundIsolate(String name) {
  //   IsolateNameServer.removePortNameMapping(name);
  // }

  // static final _controller = StreamController<Map<String, dynamic>>.broadcast();

  // static Future<void> downloadReleaseVideoByHLSWork(
  //   Map<String, dynamic> inputData,
  // ) async {
  //   final portId = inputData["port_id"] as String;
  //   final SendPort? send = IsolateNameServer.lookupPortByName(portId);

  //   if (send != null) {
  //     final httpHeaders = inputData["httpHeaders"] as List;
  //     final videoContent = inputData["videoContent"] as String;
  //     final inputArgs = inputData["args"] as List<dynamic>;
  //     final capitalize = inputArgs[0] as String;
  //     final toID = inputArgs[1] as String;
  //     final number = inputArgs[2] as String;
  //     final Completer completer = Completer();

  //     final releaseDir = Directory('${AppStorage.DOWNLOAD_DIR.path}/$capitalize/$toID');
  //     DownloadInfo info;
  //     if (!await releaseDir.exists()) {
  //       await releaseDir.create(recursive: true);
  //     }

  //     List<String> args = [
  //       ...httpHeaders,
  //       '-i',
  //       '"$videoContent"',
  //       '-c',
  //       'copy',
  //       '${releaseDir.path}/episodio_$number.mp4',
  //     ];

  //     await FFprobeKit.getMediaInformationFromCommand(
  //       [...httpHeaders, '-i', '"$videoContent"'].join(' '),
  //     ).then((session) async {
  //       final output = await session.getOutput();
  //       final RegExp rgDuration = RegExp(r"(Duration:).*[0-9](, start)");

  //       if (output != null) {
  //         final duration = rgDuration
  //             .stringMatch(output)
  //             ?.replaceAll(', start', '')
  //             .replaceAll('Duration:', '')
  //             .trim();

  //         info = DownloadInfo(
  //           path: '${releaseDir.path}/episodio_$number.mp4',
  //           id: -1,
  //           releaseId: portId,
  //           isDownloading: false,
  //           videoDuration: duration?.parseDuration,
  //         );
  //         send.send(info.toMap());
  //       }
  //     });
  //     await completer.future;
  //     await FFmpegKit.executeAsync(
  //       args.join(' '),
  //       (session) async {
  //         final returnCode = await session.getReturnCode();

  //         // final info = downloadList.firstWhereOrNull(
  //         //   (info) => info.releaseId == release.stringID,
  //         // );

  //         // if (info != null) {
  //         //   info.setValue(isDownloading: false);
  //         //   downloadList.remove(info);
  //         //   notifyListeners();
  //         //   info.dispose();
  //         // }

  //         if (ReturnCode.isSuccess(returnCode)) {
  //           send.send(true);
  //         } else if (ReturnCode.isCancel(returnCode)) {
  //           send.send(false);
  //         } else {
  //           send.send(returnCode?.getValue());
  //         }
  //       },
  //       (test) {
  //         customLog(test.getMessage());
  //       },
  //       (status) async {
  //         final info = DownloadInfo(
  //           time: status.getTime().toDouble(),
  //           id: status.getSessionId(),
  //           isDownloading: true,
  //           speed: status.getSpeed(),
  //           bitrate: status.getBitrate(),
  //           releaseId: portId,
  //           path: '${releaseDir.path}/episodio_$number.mp4',
  //         );

  //         send.send(info.toMap());
  //       },
  //     );
  //   }
  // }

  Future<void> downloadReleaseVideoByHLS(
    Release release,
    Content content,
    ContentRepository repository, {
    void Function(Statistics statistics)? statisticsCallback,
    void Function(Result result)? onResult,
  }) async {
    if (await PermissionUtils.manageExternalStorage() && content is Anime) {
      final videoData = await repository.source(content.source).getContent(release);

      // if (videoData case Success<List<Data>> success) {
      //   final selected = success.data.first as VideoData;

      // final List<String> httpHeaders = [];

      // for (final header in (selected.httpHeaders ?? <String, String>{}).entries) {
      //   httpHeaders.add('-headers "${header.key.capitalize}: ${header.value}"');
      // }

      // await Workmanager().registerOneOffTask(
      //   UniqueKey().toString(),
      //   App.APP_RELEASE_DOWNLOAD,
      //   inputData: {
      //     "videoContent": selected.videoContent,
      //     "httpHeaders": httpHeaders,
      //     "port_id": release.stringID,
      //     "args": [content.source.label.capitalize, content.title.toID, release.number],
      //   },
      //   tag: release.stringID,
      //   constraints: Constraints(networkType: NetworkType.connected),
      // );

      // final ReceivePort port = ReceivePort();
      // final Completer completer = Completer();
      // _bindBackgroundIsolate(port, release.stringID);
      // final listen = port.listen((data) {
      //   switch (data) {
      //     case Map<String, dynamic> map:
      //       final info = DownloadInfo.fromMap(map);

      //       if (info.isDownloading) {
      //         downloadList
      //             .firstWhere((info) => info.releaseId == release.stringID)
      //             .setValue(
      //               time: info.time,
      //               id: info.id,
      //               isDownloading: info.isDownloading,
      //               speed: info.speed,
      //               bitrate: info.bitrate,
      //             );
      //       } else {
      //         downloadList.add(info);
      //       }

      //       notifyListeners();
      //     case bool data:
      //       switch (data) {
      //         case true:
      //           onResult?.call(const Result.success(true));
      //         case false:
      //           onResult?.call(const Result.cancel());
      //       }
      //       completer.complete();
      //     case int data:
      //       onResult?.call(Result.failure(Exception(data)));
      //   }
      // });
      // await completer.future;
      // await listen.cancel();
      // }

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
              '${releaseDir.path}/episodio_${release.numberInt}.mp4',
            ];

            final Completer completer = Completer();

            late DownloadInfo info;

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

                info = DownloadInfo(
                  path: '${releaseDir.path}/episodio_${release.numberInt}.mp4',
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

                // final info = downloadList.firstWhereOrNull(
                //   (info) => info.releaseId == release.stringID,
                // );

                // if (info != null) {
                info.setValue(isDownloading: false);
                downloadList.remove(info);
                notifyListeners();
                info.dispose();
                // }

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
                downloadList
                    .firstWhere((info) => info.releaseId == release.stringID)
                    .setValue(
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

  String getStringDownloadPercent() =>
      '${(((time * 100) / videoDuration!.inMilliseconds)).ceil().toString()}%';

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isDownloading': isDownloading,
      'releaseId': releaseId,
      'speed': speed,
      'bitrate': bitrate,
      'path': path,
      'videoDuration': videoDuration?.inMilliseconds,
      'time': time,
    };
  }

  factory DownloadInfo.fromMap(Map<String, dynamic> map) {
    return DownloadInfo(
      id: map['id'] as int,
      isDownloading: map['isDownloading'] as bool,
      releaseId: map['releaseId'] as String,
      speed: map['speed'] as double,
      bitrate: map['bitrate'] as double,
      path: map['path'] as String,
      videoDuration: map['videoDuration'] != null
          ? Duration(milliseconds: map['videoDuration'] as int)
          : null,
      time: map['time'] as double,
    );
  }
}
