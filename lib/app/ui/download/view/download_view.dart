// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';

class _FileData with EquatableMixin implements Comparable<_FileData> {
  final FileSystemEntity file;
  final String imageThumbnail;
  _FileData({
    required this.file,
    required this.imageThumbnail,
  });

  int get number {
    return int.parse(file.path
        .split('/')[file.path.split('/').length - 1]
        .replaceAll('mp4', '')
        .replaceAll(RegExp(r'[^0-9]'), ''));
  }

  String get title {
    return file.path
        .split('/')[file.path.split('/').length - 2]
        .replaceAll('_', " ")
        .capitalize;
  }

  bool get isVideo {
    return file.path.contains("mp4");
  }

  @override
  List<Object?> get props => [file.path, imageThumbnail];

  _FileData copyWith({
    FileSystemEntity? file,
    String? imageThumbnail,
  }) {
    return _FileData(
      file: file ?? this.file,
      imageThumbnail: imageThumbnail ?? this.imageThumbnail,
    );
  }

  @override
  int compareTo(_FileData other) {
    return title.compareTo(other.title);
  }
}

class DownloadView extends StatefulWidget {
  const DownloadView({super.key});

  @override
  State<DownloadView> createState() => _DownloadViewState();
}

class _DownloadViewState extends State<DownloadView> with SubscriptionsMixin {
  List<FileSystemEntity> _dirs = [];
  final Debouncer _debouncer = Debouncer(
    duration: const Duration(milliseconds: 150),
  );

  final List<_FileData> _files = [];

  late final DownloadService _downloadService;

  bool _isLoading = true;

  @override
  void initState() {
    _downloadService = context.read<DownloadService>();
    scheduleMicrotask(_onInit);
    super.initState();
  }

  void _setDirs() async {
    final result = AppStorage.getAllReleaseDir();
    if (result == null) return;
    _dirs = result.sorted((dir1, dir2) =>
        dir2.statSync().changed.compareTo(dir1.statSync().changed));
  }

  void _onInit() async {
    if (!_isLoading && _downloadService.downloadList.isEmpty) {
      setState(() => _isLoading = true);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    _setDirs();
    final tempPath = (await getTemporaryDirectory()).path;

    subscriptions.addAll(
      _dirs.map((dir) => dir
          .watch(events: FileSystemEvent.all)
          .listen((data) => _debouncer.call(_onInit))),
    );

    if (_dirs.isEmpty) {
      _files.clear();
      if (_isLoading) _isLoading = false;
      setState(() {});
      return;
    }

    _files.clear();

    _dirs
        .map((dir) {
          return (dir as Directory).listSync().where((file) =>
              file.existsSync() &&
              !_downloadService.downloadList
                  .any((download) => download.path == file.path));
        })
        .flattened
        .forEachIndexed((index, file) async {
          _FileData data = _FileData(file: file, imageThumbnail: "");

          final cacheDir = Directory("$tempPath/${data.title.toUuID}");
          final cacheFile = File("${cacheDir.path}/${data.number}.png");

          String? fileName = cacheFile.path;

          if (!cacheFile.existsSync()) {
            if (!cacheDir.existsSync()) {
              await cacheDir.create(recursive: true);
            }

            try {
              fileName = await VideoThumbnail.thumbnailFile(
                video: file.path,
                maxWidth: 350,
                maxHeight: 200,
                thumbnailPath: cacheFile.path,
                imageFormat: ImageFormat.PNG,
                quality: 100,
              );
            } catch (_) {}
          }
          data = data.copyWith(imageThumbnail: fileName);
          setState(() {
            _isLoading = false;
            _files
              ..addOrUpdateWhere(data, (element) => element == data)
              ..sort();
          });
        });

    if (_dirs.isEmpty && _isLoading) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await subscriptions.cancelAll();

          _onInit();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isLoading)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2),
              )
            else
              const Align(
                alignment: Alignment.topCenter,
                child: Divider(height: 2),
              ),
            if (_files.isNotEmpty)
              ListView.builder(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.zero,
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final data = _files.elementAt(index);

                  return Column(
                    children: [
                      if (index != 0) const Divider(height: 2),
                      ListTile(
                        visualDensity: const VisualDensity(vertical: 3),
                        onTap: () async {
                          final LibraryService libraryService = LibraryService(
                            context.read(),
                            context.read(),
                          );

                          final animeEntity = libraryService.entities
                              .firstWhereOrNull((entity) => switch (entity) {
                                    AnimeEntity anime => anime.title.capitalize
                                        .contains(data.title),
                                    _ => false,
                                  });

                          if (animeEntity != null &&
                              animeEntity is AnimeEntity) {
                            final episode = animeEntity.episodes.firstWhere(
                                (episode) =>
                                    episode.numberEpisode == data.number);

                            await context.push(
                              RouteName.PLAYER,
                              extra: PlayerArgs(
                                getAnimeData: false,
                                forceEnterFullScreen: true,
                                startPossition: episode.currentDuration > 0
                                    ? episode.cdToDuration
                                    : null,
                                episode: episode.toEpisode(animeEntity.toAnime),
                                anime: animeEntity.toAnime,
                                data: FileVideoData(
                                  file: File(data.file.path),
                                ),
                              ),
                            );
                          }
                        },
                        leading: Container(
                          width: 100,
                          height: 90,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: data.imageThumbnail.isNotEmpty
                                ? _Image(path: data.imageThumbnail)
                                : DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: data.isVideo
                                          ? Colors.blue
                                          : Colors.orange,
                                    ),
                                    child: Center(
                                      child: Text(data.number.toString()),
                                    ),
                                  ),
                          ),
                        ),
                        subtitle: Text('Episódio ${data.number}'),
                        title: Text(
                          data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (data == _files.last) const Divider(height: 2),
                    ],
                  );
                },
              )
            else if (!_isLoading)
              const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Nenhum arquivo encontrado'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}

class _Image extends StatefulWidget {
  const _Image({
    required this.path,
  });

  final String path;

  @override
  State<_Image> createState() => _ImageState();
}

class _ImageState extends State<_Image> {
  late ResizeImage _memoryImage;

  late final ImageProvider _placeHolder;

  @override
  void initState() {
    _memoryImage = ResizeImage(
      FileImage(File(widget.path)),
      width: 350,
      height: 200,
    );
    _placeHolder = const ResizeImage(
      App.IMAGE_BLACK,
      width: 350,
      height: 200,
    );
    scheduleMicrotask(_precacheImage);
    super.initState();
  }

  void _precacheImage() {
    precacheImage(_memoryImage, context);
    precacheImage(_placeHolder, context);
  }

  @override
  void didUpdateWidget(covariant _Image oldWidget) {
    if (widget.path != oldWidget.path) {
      _memoryImage = ResizeImage(
        FileImage(File(widget.path)),
        width: 350,
        height: 200,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      placeholder: _placeHolder,
      image: _memoryImage,
      fit: BoxFit.cover,
      placeholderFit: BoxFit.cover,
    );
  }
}
