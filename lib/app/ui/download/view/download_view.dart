// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/rail_menu.dart';
import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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

  bool get isVideo => file.path.contains("mp4");

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
    return other.file.statSync().modified.compareTo(file.statSync().modified);
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
  late final RailMenuController _railMenuController;
  final List<String> _fileSelected = [];

  late final DownloadService _downloadService;

  bool _isLoading = true;

  @override
  void initState() {
    _railMenuController = RailMenuController();
    _downloadService = context.read<DownloadService>();
    scheduleMicrotask(_onInit);
    super.initState();
  }

  void add(String id) {
    if (!_fileSelected.contains(id)) {
      setState(() => _fileSelected.add(id));
    } else {
      setState(() => _fileSelected.remove(id));
    }

    if (_fileSelected.isNotEmpty) {
      _railMenuController.open();
    } else if (_fileSelected.isEmpty && _railMenuController.isOpen) {
      _railMenuController.close();
    }
  }

  void _setDirs() async {
    final result = AppStorage.getAllReleaseDir();
    if (result == null) return;
    _dirs = result.sorted((dir1, dir2) =>
        dir2.statSync().changed.compareTo(dir1.statSync().changed));
  }

  void _onInit() async {
    if (!mounted) return;
    if (!_isLoading && _downloadService.downloadList.isEmpty) {
      setStateIfMounted(() => _isLoading = true);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    _setDirs();
    final tempPath = (await getTemporaryDirectory()).path;

    if (_dirs.isEmpty) {
      _files.clear();
      _isLoading = false;
      setStateIfMounted(() {});
      return;
    }

    subscriptions.addAll(
      _dirs.map((dir) => dir
          .watch(events: FileSystemEvent.all)
          .listen((data) => _debouncer.call(_onInit))),
    );

    _files.clear();

    _dirs
        .map((dir) {
          final files =
              (dir as Directory).listSync().where((file) => file.existsSync());

          if (files.isEmpty && _isLoading) {
            setStateIfMounted(() => _isLoading = false);
          }
          return files;
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
          _files
            ..addOrUpdateWhere(data, (element) => element == data)
            ..sort();
          setStateIfMounted(() {});
        });

    setStateIfMounted(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await subscriptions.cancelAll();
          _onInit();
        },
        child: RailMenu(
          railMenuController: _railMenuController,
          buttons: (context) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Card.filled(
                color: themeData.colorScheme.primary.withOpacity(0.04),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: OverflowBar(
                  spacing: 8,
                  textDirection: Directionality.of(context),
                  overflowAlignment: OverflowBarAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final allSelected = _files.where(
                            (file) => _fileSelected.contains(file.file.path));

                        for (final file in allSelected) {
                          await file.file.delete();
                        }

                        _railMenuController.close();

                        setStateIfMounted(_fileSelected.clear);
                      },
                      icon: Icon(MdiIcons.delete),
                    ),
                  ],
                ),
              ),
            );
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
              Builder(builder: (context) {
                final menuController = RailMenu.menuControllerOf(context);
                return AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.only(
                    right: menuController.isOpen
                        ? menuController.menuSize.width + 8
                        : 8,
                    left: 8,
                  ),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _files.isNotEmpty ? _files.length : 1,
                    itemBuilder: (context, index) {
                      if (_files.isEmpty) {
                        return const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text('Nenhum arquivo encontrado.'),
                          ),
                        );
                      }

                      final data = _files.elementAt(index);

                      final selected = _fileSelected.contains(data.file.path);

                      return Padding(
                        padding: index != 0
                            ? const EdgeInsets.only(top: 8)
                            : EdgeInsets.zero,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 450),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: selected
                                  ? Border.all(
                                      color:
                                          const Color.fromARGB(255, 19, 15, 15),
                                      width: 1.5)
                                  : null),
                          child: Stack(
                            children: [
                              Card(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 90,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                                left: Radius.circular(8)),
                                        child: data.imageThumbnail.isNotEmpty
                                            ? _Image(path: data.imageThumbnail)
                                            : DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: data.isVideo
                                                      ? Colors.blue
                                                      : Colors.orange,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                      data.number.toString()),
                                                ),
                                              ),
                                      ),
                                    ),
                                    Flexible(
                                      child: ListTile(
                                        subtitle:
                                            Text('Episódio ${data.number}'),
                                        title: Text(
                                          data.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned.fill(
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onLongPress: selected
                                        ? null
                                        : () {
                                            add(data.file.path);
                                          },
                                    onTap: _fileSelected.isNotEmpty
                                        ? () {
                                            add(data.file.path);
                                          }
                                        : () async {
                                            final LibraryService
                                                libraryService = LibraryService(
                                              context.read(),
                                              context.read(),
                                            );

                                            final animeEntity = libraryService
                                                .entities
                                                .firstWhereOrNull(
                                              (entity) => switch (entity) {
                                                AnimeEntity anime => anime
                                                    .title.toID
                                                    .contains(data.title.toID),
                                                _ => false,
                                              },
                                            );

                                            if (animeEntity != null &&
                                                animeEntity is AnimeEntity) {
                                              final episode = animeEntity
                                                  .episodes
                                                  .firstWhere(
                                                (episode) =>
                                                    episode.numberEpisode ==
                                                    data.number,
                                              );

                                              await context.push(
                                                RouteName.PLAYER,
                                                extra: PlayerArgs(
                                                  getAnimeData: false,
                                                  forceEnterFullScreen: true,
                                                  startPossition:
                                                      episode.currentDuration >
                                                              0
                                                          ? episode.cdToDuration
                                                          : null,
                                                  episode: episode.toEpisode(
                                                    animeEntity.isDublado,
                                                  ),
                                                  anime: animeEntity.toAnime,
                                                  data: FileVideoData(
                                                    file: File(data.file.path),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              })
            ],
          ),
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
