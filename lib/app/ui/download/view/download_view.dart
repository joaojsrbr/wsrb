// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../routes/routes.dart';
import '../../player/arguments/player_args.dart';
import '../../shared/mixins/subscriptions.dart';
import '../../shared/widgets/global_overlay.dart';

class _FileData with EquatableMixin implements Comparable<_FileData> {
  final FileSystemEntity file;
  final String imageThumbnail;
  _FileData({required this.file, required this.imageThumbnail});

  int? get number {
    return int.tryParse(
      _parts[_parts.length - 1].replaceAll('mp4', '').replaceAll(RegExp(r'[^0-9]'), ''),
    );
  }

  List<String> get _parts => file.path.split('/');

  String get title {
    return _parts[_parts.length - 2].replaceAll('_', " ").capitalize;
  }

  String get source {
    return _parts[_parts.length - 3].replaceAll('_', " ").capitalize;
  }

  bool get isVideo => file.path.contains("mp4");

  @override
  List<Object?> get props => [file.path, imageThumbnail];

  _FileData copyWith({FileSystemEntity? file, String? imageThumbnail}) {
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
  final Debouncer _debouncer = Debouncer(duration: const Duration(milliseconds: 150));

  final List<_FileData> _files = [];
  late final ValueNotifierList _valueNotifierList;
  late final LibraryController _libraryController;
  final List<String> _fileSelected = [];

  late final DownloadService _downloadService;

  bool _isLoading = true;

  @override
  void initState() {
    _valueNotifierList = context.read<ValueNotifierList>();
    _downloadService = context.read<DownloadService>();
    _libraryController = context.read<LibraryController>();
    scheduleMicrotask(_onInit);
    super.initState();
  }

  void add(String id) {
    if (!_fileSelected.contains(id)) {
      setState(() => _fileSelected.add(id));
    } else {
      setState(() => _fileSelected.remove(id));
    }

    if (_fileSelected.isNotEmpty && _valueNotifierList.isEmpty) {
      _valueNotifierList.toggle(id);
      context.showBottomNotification(
        _DownloadBottomButtons(
          onTap: () async {
            final allSelected = _files.where(
              (file) => _fileSelected.contains(file.file.path),
            );

            for (final file in allSelected) {
              await file.file.delete();
            }

            setStateIfMounted(_fileSelected.clear);
          },
        ),
        height: 52,
        persistent: true,
        showCountdown: false,
        // showCountdown: true,
        // duration: const Duration(seconds: 20),
      );
    } else {
      _valueNotifierList.toggle(id);
      context.maintainOverlap(duration: const Duration(seconds: 20));
      if (_valueNotifierList.isEmpty) {
        context.closeNotification();
      }
    }
  }

  void _setDirs() async {
    final result = AppStorage.getAllReleaseDir();
    if (result == null) return;

    _dirs = result.sorted(
      (dir1, dir2) => dir2.statSync().changed.compareTo(dir1.statSync().changed),
    );
  }

  void _onInit() async {
    if (!mounted) return;
    if (!_isLoading && _downloadService.downloadList.isEmpty) {
      setStateIfMounted(() => _isLoading = true);
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _setDirs();
    final tempPath = (await getTemporaryDirectory()).path;

    if (_dirs.isEmpty) {
      _files.clear();
      _isLoading = false;
      setStateIfMounted(() {});
      return;
    }

    subscriptions.addAll(
      _dirs.map(
        (dir) => dir
            .watch(events: FileSystemEvent.all)
            .listen((data) => _debouncer.call(_onInit)),
      ),
    );

    _files.clear();

    _dirs
        .map((dir) {
          final files = (dir as Directory)
              .listSync()
              .map((dir) => (dir as Directory).listSync())
              .flattened
              .where((file) => file.existsSync());

          if (files.isEmpty && _isLoading) {
            setStateIfMounted(() => _isLoading = false);
          }
          return files;
        })
        .flattened
        .forEachIndexed((index, file) async {
          _FileData data = _FileData(file: file, imageThumbnail: "");
          if (data.number != null &&
              _libraryController.repo.allDownIds.contains(data.title.toID)) {
            final cacheDir = Directory("$tempPath/${data.source}/${data.title.toUuID}");
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
          }
        });

    setStateIfMounted(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
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
              const Align(alignment: Alignment.topCenter, child: Divider(height: 2)),
            Builder(
              builder: (context) {
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
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
                          borderRadius: BorderRadius.circular(
                            8,
                          ).add(selected ? BorderRadius.circular(2) : BorderRadius.zero),
                          border: selected
                              ? Border.all(color: Colors.white, width: 1.5)
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Card(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 90,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.horizontal(
                                        left: Radius.circular(8),
                                      ),
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
                                  Flexible(
                                    child: ListTile(
                                      subtitle: Text('Episódio ${data.number}'),
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
                                          final animeEntity = _libraryController
                                              .repo
                                              .entities
                                              .firstWhereOrNull(
                                                (entity) => switch (entity) {
                                                  AnimeEntity anime =>
                                                    anime.title.toID.contains(
                                                      data.title.toID,
                                                    ),
                                                  _ => false,
                                                },
                                              );

                                          if (animeEntity != null &&
                                              animeEntity is AnimeEntity) {
                                            final episode = animeEntity.episodes
                                                .firstWhere(
                                                  (episode) =>
                                                      episode.numberEpisode ==
                                                      data.number,
                                                );

                                            await context.pushEnum(
                                              RouteName.PLAYER,
                                              extra: PlayerArgs(
                                                forceEnterFullScreen: true,
                                                startPossition:
                                                    (episode.position?.currentDuration ??
                                                            0) >
                                                        0
                                                    ? episode.cdToDuration
                                                    : null,
                                                episode: episode.toEpisode(
                                                  animeEntity.isDublado,
                                                ),
                                                anime: animeEntity.toContent(),
                                                data: [
                                                  FileVideoData(
                                                    file: File(data.file.path),
                                                  ),
                                                ],
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
                );
              },
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

class _DownloadBottomButtons extends StatefulWidget {
  const _DownloadBottomButtons({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_DownloadBottomButtons> createState() => DownloadoBottomButtonsState();
}

class DownloadoBottomButtonsState extends State<_DownloadBottomButtons> {
  late final ValueNotifierList _valueNotifierList;

  @override
  void initState() {
    _valueNotifierList = context.read<ValueNotifierList>()..addListener(_listener);
    super.initState();
  }

  void _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    _valueNotifierList.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverflowBar(
      spacing: 8,
      textDirection: Directionality.of(context),
      overflowAlignment: OverflowBarAlignment.center,
      children: [IconButton(onPressed: widget.onTap, icon: Icon(MdiIcons.delete))],
    );
  }
}

class _Image extends StatefulWidget {
  const _Image({required this.path});

  final String path;

  @override
  State<_Image> createState() => _ImageState();
}

class _ImageState extends State<_Image> {
  late ResizeImage _memoryImage;

  late final ImageProvider _placeHolder;

  @override
  void initState() {
    _memoryImage = ResizeImage(FileImage(File(widget.path)), width: 350, height: 200);
    _placeHolder = const ResizeImage(App.IMAGE_BLACK, width: 350, height: 200);
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
      _memoryImage = ResizeImage(FileImage(File(widget.path)), width: 350, height: 200);
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
