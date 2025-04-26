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

    _libraryService = context.watch<LibraryService>();
    final sortedByUpdateAt = (tabController.index == 0
            ? _libraryService.entities
            : _libraryService.favorites)
        .map(_libraryService.getIsarLinks)
        .nonNulls
        .flattened
        .sorted()
        .getMax(5);

    if (!listEquals(sortedByUpdateAt, _sortedByUpdateAt)) {
      _sortedByUpdateAt = sortedByUpdateAt;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final HomeScope scope = HomeScope.of(context);

    final ThemeData themeData = Theme.of(context);

    final TextTheme textTheme = themeData.textTheme;

    final TabController tabController = scope.tabController;

    return SliverAnimatedPaintExtent(
      duration: const Duration(milliseconds: 350),
      child: _sortedByUpdateAt.isEmpty || ![0, 1].contains(tabController.index)
          ? SliverToBoxAdapter()
          : SliverToBoxAdapter(
              child: _Content(
                sortedByUpdateAt: _sortedByUpdateAt,
                scope: scope,
                libraryService: _libraryService,
                textTheme: textTheme,
              ),
            ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required List<HistoryEntity> sortedByUpdateAt,
    required this.scope,
    required LibraryService libraryService,
    required this.textTheme,
  })  : _sortedByUpdateAt = sortedByUpdateAt,
        _libraryService = libraryService;

  final List<HistoryEntity> _sortedByUpdateAt;
  final HomeScope scope;
  final LibraryService _libraryService;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final widthCache = 500;
    final heightCache = 340;

    return SizedBox(
      height: 160,
      width: 180,
      child: ListView.builder(
        shrinkWrap: true,
        // key: PageStorageKey(
        //   'home_and_library_watching_${_sortedByUpdateAt.length}',
        // ),
        controller: scope.keepWatchingScrollController,
        padding: const EdgeInsets.only(left: 8, top: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _sortedByUpdateAt.length,
        itemBuilder: (context, index) {
          final HistoryEntity historyEntity =
              _sortedByUpdateAt.elementAt(index);

          return switch (historyEntity) {
            EpisodeEntity data => Builder(builder: (context) {
                final anime = _libraryService.getContentEntityByStringID(
                    data.animeStringID) as AnimeEntity?;

                return Padding(
                  padding: const EdgeInsets.only(
                    right: 12,
                    top: 4,
                    bottom: 4,
                  ),
                  child: SizedBox(
                    height: 180,
                    width: 180,
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
                                    width: widthCache,
                                    height: heightCache,
                                    currentPositionBase64:
                                        data.currentPositionBase64!,
                                  )
                                : data.thumbnail != null
                                    ? CachedNetworkImage(
                                        cacheManager: App.APP_IMAGE_CACHE,
                                        fit: BoxFit.cover,
                                        memCacheWidth: widthCache,
                                        memCacheHeight: heightCache,
                                        imageUrl: data.thumbnail!,
                                        httpHeaders: App.HEADERS,
                                        errorWidget: (context, url, error) {
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
                              duration: const Duration(milliseconds: 350),
                              style:
                                  (textTheme.titleMedium ?? const TextStyle())
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
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 14,
                                  ),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 350),
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
                            value: data.percent.isNaN ? 0.0 : data.percent,
                            color: anime?.anilistMedia?.coverImage?.color
                                    ?.fromHex ??
                                Theme.of(context).colorScheme.primary,
                            strokeWidth: 4,
                            borderRadius: 12,
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () async {
                                final videoFile = AppStorage.getReleaseFile(
                                  anime!.toAnime(),
                                  data.toEpisode(anime.isDublado),
                                );

                                await context.push(
                                  RouteName.PLAYER,
                                  extra: PlayerArgs(
                                    forceEnterFullScreen: true,
                                    data: videoFile != null
                                        ? FileVideoData(file: videoFile)
                                        : null,
                                    getAnimeData: false,
                                    anime: anime.toAnime(),
                                    episode: data.toEpisode(anime.isDublado),
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
    );
  }
}

class _Image extends StatefulWidget {
  const _Image({
    required this.currentPositionBase64,
    required this.width,
    required this.height,
  });
  final int width;
  final int height;
  final String currentPositionBase64;

  @override
  State<_Image> createState() => _ImageState();
}

class _ImageState extends State<_Image> {
  late Uint8List _currentPositionUint8List;
  late ResizeImage _memoryImage;
  late ImageProvider _placeHolder = ResizeImage(
    App.IMAGE_BLACK,
    width: widget.width,
    height: widget.height,
  );

  Uint8List _base64ToBytes(String base64String) {
    return base64Decode(base64String);
  }

  @override
  void initState() {
    _currentPositionUint8List = _base64ToBytes(widget.currentPositionBase64);

    _memoryImage = ResizeImage(
      MemoryImage(_currentPositionUint8List),
      width: widget.width,
      height: widget.height,
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
    if (widget.currentPositionBase64 != oldWidget.currentPositionBase64 ||
        widget.height != oldWidget.height ||
        widget.width != oldWidget.width) {
      _currentPositionUint8List = Uint8List.fromList(
        _base64ToBytes(widget.currentPositionBase64),
      );
      _placeHolder = ResizeImage(
        App.IMAGE_BLACK,
        width: widget.width,
        height: widget.height,
      );
      _memoryImage = ResizeImage(
        MemoryImage(_currentPositionUint8List),
        width: widget.width,
        height: widget.height,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      fadeOutDuration: const Duration(milliseconds: 150),
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: _placeHolder,
      image: _memoryImage,
      fit: BoxFit.cover,
      placeholderFit: BoxFit.cover,
    );
  }
}

// class KeepWatching2 extends StatefulWidget {
//   const KeepWatching2({super.key});

//   @override
//   State<KeepWatching2> createState() => _KeepWatching2State();
// }

// class _KeepWatching2State extends State<KeepWatching2> {
//   List<HistoryEntity> _sortedByUpdateAt = [];

//   late LibraryService _libraryService;

//   @override
//   void didChangeDependencies() {
//     final TabController tabController = HomeScope.of(context).tabController;

//     _libraryService = context.watch<LibraryService>();
//     _sortedByUpdateAt = (tabController.index == 0
//             ? _libraryService.entities
//             : _libraryService.favorites)
//         .map(_libraryService.getIsarLinks)
//         .nonNulls
//         .flattened
//         .sorted();

//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final HomeScope scope = HomeScope.of(context);

//     final ThemeData themeData = Theme.of(context);

//     final TextTheme textTheme = themeData.textTheme;

//     final TabController tabController = scope.tabController;
//     return SliverAnimatedPaintExtent(
//       duration: const Duration(milliseconds: 350),
//       child: SliverToBoxAdapter(
//         child: _sortedByUpdateAt.isEmpty ||
//                 ![0, 1].contains(tabController.index)
//             ? null
//             : Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: SizedBox(
//                   height: 180,
//                   child: CarouselView.weighted(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                     flexWeights: [12, 2],
//                     children: List.generate(
//                       _sortedByUpdateAt.length,
//                       (index) {
//                         final HistoryEntity historyEntity =
//                             _sortedByUpdateAt.elementAt(index);

//                         return switch (historyEntity) {
//                           EpisodeEntity data => Builder(builder: (context) {
//                               final anime =
//                                   _libraryService.getContentEntityByStringID(
//                                       data.animeStringID) as AnimeEntity?;

//                               return Padding(
//                                 padding: EdgeInsets.only(
//                                   left: index == 0 ? 12 : 0,
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(6),
//                                   child: Stack(
//                                     fit: StackFit.expand,
//                                     children: [
//                                       ShaderMask(
//                                         blendMode: BlendMode.srcOver,
//                                         shaderCallback: (bounds) {
//                                           return LinearGradient(
//                                             begin: Alignment.topCenter,
//                                             end: Alignment.bottomCenter,
//                                             colors: [
//                                               Colors.black38.withOpacity(0.28),
//                                               Colors.black38.withOpacity(0.28),
//                                               // Colors.transparent,
//                                             ],
//                                             stops: const [0.00, 1.0],
//                                           ).createShader(bounds);
//                                         },
//                                         child: data.currentPositionBase64 !=
//                                                 null
//                                             ? _Image(
//                                                 currentPositionBase64:
//                                                     data.currentPositionBase64!,
//                                               )
//                                             : data.thumbnail != null
//                                                 ? CachedNetworkImage(
//                                                     fit: BoxFit.cover,
//                                                     memCacheWidth: 350,
//                                                     memCacheHeight: 200,
//                                                     imageUrl: data.thumbnail!,
//                                                     httpHeaders: App.HEADERS,
//                                                     errorWidget:
//                                                         (context, url, error) {
//                                                       return const Material(
//                                                         child: Card.filled(),
//                                                       );
//                                                     },
//                                                   )
//                                                 : const SizedBox.shrink(),
//                                       ),
//                                       Container(
//                                         alignment: Alignment.topRight,
//                                         padding: const EdgeInsets.only(
//                                           left: 10,
//                                           top: 8,
//                                           right: 14,
//                                         ),
//                                         child: AnimatedDefaultTextStyle(
//                                           duration:
//                                               const Duration(milliseconds: 350),
//                                           style: (textTheme.titleMedium ??
//                                                   const TextStyle())
//                                               .copyWith(fontSize: 14),
//                                           child: Text(
//                                             data.cdToDuration.label(),
//                                             maxLines: 1,
//                                             textAlign: TextAlign.start,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ),
//                                       if (anime != null)
//                                         Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           mainAxisSize: MainAxisSize.max,
//                                           children: [
//                                             Container(
//                                               alignment: Alignment.bottomLeft,
//                                               padding: const EdgeInsets.only(
//                                                 left: 10,
//                                                 right: 14,
//                                               ),
//                                               child: AnimatedDefaultTextStyle(
//                                                 duration: const Duration(
//                                                     milliseconds: 350),
//                                                 style: (textTheme.titleMedium ??
//                                                         const TextStyle())
//                                                     .copyWith(fontSize: 14),
//                                                 child: Text(
//                                                   'Episódio ${data.numberEpisode}',
//                                                   maxLines: 1,
//                                                   textAlign: TextAlign.start,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                             Container(
//                                               alignment: Alignment.topLeft,
//                                               padding: const EdgeInsets.only(
//                                                 left: 10,
//                                                 right: 6,
//                                                 bottom: 8,
//                                               ),
//                                               child: Text(
//                                                 anime.title,
//                                                 maxLines: 1,
//                                                 style: textTheme.titleMedium
//                                                     ?.copyWith(fontSize: 14),
//                                                 textAlign: TextAlign.start,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 // style: textTheme.labelSmall?.copyWith(),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       Material(
//                                         type: MaterialType.transparency,
//                                         child: InkWell(
//                                           onTap: () async {
//                                             final videoFile =
//                                                 AppStorage.getReleaseFile(
//                                               anime!.toAnime,
//                                               data.toEpisode(anime.isDublado),
//                                             );

//                                             await context.push(
//                                               RouteName.PLAYER,
//                                               extra: PlayerArgs(
//                                                 forceEnterFullScreen: true,
//                                                 data: videoFile != null
//                                                     ? FileVideoData(
//                                                         file: videoFile)
//                                                     : null,
//                                                 getAnimeData: false,
//                                                 anime: anime.toAnime,
//                                                 episode: data
//                                                     .toEpisode(anime.isDublado),
//                                                 startPossition:
//                                                     data.cdToDuration,
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       AnimatedBorderProgressIndicator(
//                                         value: data.percent.isNaN
//                                             ? 0.0
//                                             : data.percent,
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .primary,
//                                         strokeWidth: 6,
//                                         borderRadius: 12,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }),
//                           _ => const SizedBox.shrink(),
//                         };
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }
// }
