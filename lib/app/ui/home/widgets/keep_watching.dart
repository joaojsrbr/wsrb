import 'dart:convert';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:border_progress_indicator/border_progress_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class KeepWatching extends StatefulWidget {
  const KeepWatching({super.key});

  @override
  State<KeepWatching> createState() => _KeepWatchingState();
}

class _KeepWatchingState extends State<KeepWatching> {
  List<HistoryEntity> _sortedByUpdateAt = [];

  late LibraryService _libraryService;

  @override
  void didChangeDependencies() {
    final TabController tabController = HomeScope.of(context).tabController;

    _libraryService = LibraryService(context.watch(), context.watch());
    _sortedByUpdateAt = (tabController.index == 0
            ? _libraryService.entities
            : _libraryService.favorites)
        .map(_libraryService.getIsarLinks)
        .nonNulls
        .flattened
        .sorted();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final HomeScope scope = HomeScope.of(context);

    final ThemeData themeData = Theme.of(context);

    final TextTheme textTheme = themeData.textTheme;

    final TabController tabController = scope.tabController;

    // return SliverAnimatedPaintExtent(
    //   duration: const Duration(milliseconds: 350),
    //   child: SliverToBoxAdapter(
    //     child: _sortedByUpdateAt.isEmpty ||
    //             ![0, 1].contains(tabController.index)
    //         ? null
    //         : Padding(
    //             padding: const EdgeInsets.only(top: 16),
    //             child: SizedBox(
    //               height: 180,
    //               child: CarouselView.weighted(
    //                 key: PageStorageKey(
    //                   'home_and_library_watching_${_sortedByUpdateAt.length}',
    //                 ),
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(12),
    //                 ),
    //                 flexWeights: [9, 4, 4],
    //                 children: List.generate(_sortedByUpdateAt.length, (index) {
    //                   final HistoryEntity historyEntity =
    //                       _sortedByUpdateAt.elementAt(index);

    //                   return switch (historyEntity) {
    //                     EpisodeEntity data => Builder(builder: (context) {
    //                         final anime =
    //                             _libraryService.getContentEntityByStringID(
    //                                 data.animeStringID) as AnimeEntity?;

    //                         return Padding(
    //                           padding: EdgeInsets.only(
    //                             left: index == 0 ? 12 : 0,
    //                           ),
    //                           child: ClipRRect(
    //                             borderRadius: BorderRadius.circular(12),
    //                             child: Stack(
    //                               fit: StackFit.expand,
    //                               children: [
    //                                 ShaderMask(
    //                                   blendMode: BlendMode.srcOver,
    //                                   shaderCallback: (bounds) {
    //                                     return LinearGradient(
    //                                       begin: Alignment.topCenter,
    //                                       end: Alignment.bottomCenter,
    //                                       colors: [
    //                                         Colors.black38.withOpacity(0.28),
    //                                         Colors.black38.withOpacity(0.28),
    //                                         // Colors.transparent,
    //                                       ],
    //                                       stops: const [0.00, 1.0],
    //                                     ).createShader(bounds);
    //                                   },
    //                                   child: data.currentPositionBase64 != null
    //                                       ? _Image(
    //                                           currentPositionBase64:
    //                                               data.currentPositionBase64!,
    //                                         )
    //                                       : data.thumbnail != null
    //                                           ? CachedNetworkImage(
    //                                               fit: BoxFit.cover,
    //                                               maxWidthDiskCache: 480,
    //                                               maxHeightDiskCache: 280,
    //                                               imageUrl: data.thumbnail!,
    //                                               httpHeaders: App.HEADERS,
    //                                               errorWidget:
    //                                                   (context, url, error) {
    //                                                 return const Material(
    //                                                   child: Card.filled(),
    //                                                 );
    //                                               },
    //                                             )
    //                                           : const SizedBox.shrink(),
    //                                 ),
    //                                 Container(
    //                                   alignment: Alignment.topRight,
    //                                   padding: const EdgeInsets.only(
    //                                     left: 10,
    //                                     top: 8,
    //                                     right: 14,
    //                                   ),
    //                                   child: AnimatedDefaultTextStyle(
    //                                     duration:
    //                                         const Duration(milliseconds: 350),
    //                                     style: (textTheme.titleMedium ??
    //                                             const TextStyle())
    //                                         .copyWith(fontSize: 14),
    //                                     child: Text(
    //                                       data.cdToDuration.label(),
    //                                       maxLines: 1,
    //                                       textAlign: TextAlign.start,
    //                                       overflow: TextOverflow.ellipsis,
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 if (anime != null)
    //                                   Column(
    //                                     mainAxisAlignment:
    //                                         MainAxisAlignment.end,
    //                                     mainAxisSize: MainAxisSize.max,
    //                                     children: [
    //                                       Container(
    //                                         alignment: Alignment.bottomLeft,
    //                                         padding: const EdgeInsets.only(
    //                                           left: 10,
    //                                           right: 14,
    //                                         ),
    //                                         child: AnimatedDefaultTextStyle(
    //                                           duration: const Duration(
    //                                               milliseconds: 350),
    //                                           style: (textTheme.titleMedium ??
    //                                                   const TextStyle())
    //                                               .copyWith(fontSize: 14),
    //                                           child: Text(
    //                                             'Episódio ${data.numberEpisode}',
    //                                             maxLines: 1,
    //                                             textAlign: TextAlign.start,
    //                                             overflow: TextOverflow.ellipsis,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                       Container(
    //                                         alignment: Alignment.topLeft,
    //                                         padding: const EdgeInsets.only(
    //                                           left: 10,
    //                                           right: 6,
    //                                           bottom: 8,
    //                                         ),
    //                                         child: Text(
    //                                           anime.title,
    //                                           maxLines: 1,
    //                                           style: textTheme.titleMedium
    //                                               ?.copyWith(fontSize: 14),
    //                                           textAlign: TextAlign.start,
    //                                           overflow: TextOverflow.ellipsis,
    //                                           // style: textTheme.labelSmall?.copyWith(),
    //                                         ),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 Material(
    //                                   type: MaterialType.transparency,
    //                                   child: InkWell(
    //                                     onTap: () async {
    //                                       final videoFile =
    //                                           AppStorage.getReleaseFile(
    //                                         anime!.toAnime,
    //                                         data.toEpisode(anime.isDublado),
    //                                       );

    //                                       await context.push(
    //                                         RouteName.PLAYER,
    //                                         extra: PlayerArgs(
    //                                           forceEnterFullScreen: true,
    //                                           data: videoFile != null
    //                                               ? FileVideoData(
    //                                                   file: videoFile)
    //                                               : null,
    //                                           getAnimeData: false,
    //                                           anime: anime.toAnime,
    //                                           episode: data
    //                                               .toEpisode(anime.isDublado),
    //                                           startPossition: data.cdToDuration,
    //                                         ),
    //                                       );
    //                                     },
    //                                   ),
    //                                 ),
    //                                 AnimatedBorderProgressIndicator(
    //                                   value: data.videoPercent.isNaN
    //                                       ? 0.0
    //                                       : data.videoPercent,
    //                                   color:
    //                                       Theme.of(context).colorScheme.primary,
    //                                   strokeWidth: 6,
    //                                   borderRadius: 12,
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                         );
    //                       }),
    //                     _ => const SizedBox.shrink(),
    //                   };
    //                 }),
    //               ),
    //             ),
    //           ),
    //   ),
    // );

    return SliverAnimatedPaintExtent(
      duration: const Duration(milliseconds: 350),
      child: SliverToBoxAdapter(
        child: _sortedByUpdateAt.isEmpty ||
                ![0, 1].contains(tabController.index)
            ? null
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  key: PageStorageKey(
                    'home_and_library_watching_${_sortedByUpdateAt.length}',
                  ),
                  controller: scope.keepWatchingScrollController,
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _sortedByUpdateAt.length,
                  itemBuilder: (context, index) {
                    final HistoryEntity historyEntity =
                        _sortedByUpdateAt.elementAt(index);

                    return switch (historyEntity) {
                      EpisodeEntity data => Builder(builder: (context) {
                          final anime =
                              _libraryService.getContentEntityByStringID(
                                  data.animeStringID) as AnimeEntity?;

                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 12,
                              top: 8,
                              bottom: 8,
                            ),
                            child: SizedBox(
                              width: 240,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ShaderMask(
                                      blendMode: BlendMode.srcOver,
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black38.withAlpha(71),
                                            Colors.black38.withAlpha(71),
                                            // Colors.transparent,
                                          ],
                                          stops: const [0.00, 1.0],
                                        ).createShader(bounds);
                                      },
                                      child: data.currentPositionBase64 != null
                                          ? _Image(
                                              currentPositionBase64:
                                                  data.currentPositionBase64!,
                                            )
                                          : data.thumbnail != null
                                              ? CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  maxWidthDiskCache: 480,
                                                  maxHeightDiskCache: 280,
                                                  imageUrl: data.thumbnail!,
                                                  httpHeaders: App.HEADERS,
                                                  errorWidget:
                                                      (context, url, error) {
                                                    return const Material(
                                                      child: Card.filled(),
                                                    );
                                                  },
                                                )
                                              : const SizedBox.shrink(),
                                    ),
                                    Container(
                                      alignment: Alignment.topRight,
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        top: 8,
                                        right: 14,
                                      ),
                                      child: AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 350),
                                        style: (textTheme.titleMedium ??
                                                const TextStyle())
                                            .copyWith(fontSize: 14),
                                        child: Text(
                                          data.cdToDuration.label(),
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    if (anime != null)
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            alignment: Alignment.bottomLeft,
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 14,
                                            ),
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(
                                                  milliseconds: 350),
                                              style: (textTheme.titleMedium ??
                                                      const TextStyle())
                                                  .copyWith(fontSize: 14),
                                              child: Text(
                                                'Episódio ${data.numberEpisode}',
                                                maxLines: 1,
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 6,
                                              bottom: 8,
                                            ),
                                            child: Text(
                                              anime.title,
                                              maxLines: 1,
                                              style: textTheme.titleMedium
                                                  ?.copyWith(fontSize: 14),
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              // style: textTheme.labelSmall?.copyWith(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    AnimatedBorderProgressIndicator(
                                      value: data.videoPercent.isNaN
                                          ? 0.0
                                          : data.videoPercent,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      strokeWidth: 4,
                                      borderRadius: 12,
                                    ),
                                    Material(
                                      type: MaterialType.transparency,
                                      child: InkWell(
                                        onTap: () async {
                                          final videoFile =
                                              AppStorage.getReleaseFile(
                                            anime!.toAnime,
                                            data.toEpisode(anime.isDublado),
                                          );

                                          await context.push(
                                            RouteName.PLAYER,
                                            extra: PlayerArgs(
                                              forceEnterFullScreen: true,
                                              data: videoFile != null
                                                  ? FileVideoData(
                                                      file: videoFile)
                                                  : null,
                                              getAnimeData: false,
                                              anime: anime.toAnime,
                                              episode: data
                                                  .toEpisode(anime.isDublado),
                                              startPossition: data.cdToDuration,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      _ => const SizedBox.shrink(),
                    };
                  },
                ),
              ),
      ),
    );
  }
}

class _Image extends StatefulWidget {
  const _Image({required this.currentPositionBase64});

  final String currentPositionBase64;

  @override
  State<_Image> createState() => _ImageState();
}

class _ImageState extends State<_Image> {
  late Uint8List _currentPositionUint8List;
  late ResizeImage _memoryImage;

  late final ImageProvider _placeHolder;

  @override
  void initState() {
    _currentPositionUint8List = base64.decode(widget.currentPositionBase64);
    _memoryImage = ResizeImage(
      MemoryImage(_currentPositionUint8List),
      width: 720,
      height: 450,
    );
    _placeHolder = const ResizeImage(
      App.IMAGE_BLACK,
      width: 720,
      height: 450,
    );
    // scheduleMicrotask(_precacheImage);
    super.initState();
  }

  // void _precacheImage() {
  //   precacheImage(_memoryImage, context);
  //   precacheImage(_placeHolder, context);
  // }

  @override
  void didUpdateWidget(covariant _Image oldWidget) {
    if (widget.currentPositionBase64 != oldWidget.currentPositionBase64) {
      _currentPositionUint8List = base64.decode(widget.currentPositionBase64);
      _memoryImage = ResizeImage(
        MemoryImage(_currentPositionUint8List),
        width: 720,
        height: 450,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      fadeOutDuration: const Duration(milliseconds: 350),
      fadeInDuration: const Duration(milliseconds: 350),
      placeholder: _placeHolder,
      image: _memoryImage,
      fit: BoxFit.cover,
      placeholderFit: BoxFit.cover,
    );
  }
}
