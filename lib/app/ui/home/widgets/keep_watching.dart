import 'dart:convert';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/routes/shared_axis_transition_page_wrapper.dart';
import 'package:app_wsrb_jsr/app/ui/home/destinations/watching_destinations.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:border_progress_indicator/border_progress_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class KeepWatching extends StatefulWidget {
  const KeepWatching({
    super.key,
    this.items,
  });
  final List<HistoryEntity>? items;
  @override
  State<KeepWatching> createState() => _KeepWatchingState();
}

class _KeepWatchingState extends State<KeepWatching> {
  List<HistoryEntity> _sortedByUpdateAt = [];

  @override
  void didChangeDependencies() {
    if (widget.items != null) {
      _sortedByUpdateAt = widget.items!.sorted(_sortedItems);
    } else {
      final TabController tabController = HomeScope.of(context).tabController;
      final LibraryController libraryController =
          context.watch<LibraryController>();
      final libraryRepo = libraryController.repo;

      final sortedByUpdateAt = (tabController.index == 0
              ? libraryRepo.entities
              : libraryRepo.favorites)
          .map(libraryRepo.getIsarLinks)
          .flattened
          .sorted()
          .getMax(5);

      _sortedByUpdateAt = sortedByUpdateAt.sorted(_sortedByCreateAt);
    }

    super.didChangeDependencies();
  }

  int _sortedItems(HistoryEntity a, HistoryEntity b) {
    if ((a, b) case (EpisodeEntity data1, EpisodeEntity data2)
        when data1.numberEpisode != null && data2.numberEpisode != null) {
      return data1.numberEpisode!.compareTo(data2.numberEpisode!);
    }
    return -1;
  }

  int _sortedByCreateAt(HistoryEntity a, HistoryEntity b) {
    if ((a, b) case (EpisodeEntity data1, EpisodeEntity data2)
        when data1.getLastCurrentPosition()?.createdAt != null &&
            data2.getLastCurrentPosition()?.createdAt != null) {
      return data1
          .getLastCurrentPosition()!
          .createdAt!
          .compareTo(data2.getLastCurrentPosition()!.createdAt!);
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    Widget container = _Content(sortedByUpdateAt: _sortedByUpdateAt);

    if (widget.items != null) return container;

    final HomeScope scope = HomeScope.of(context);
    final TabController tabController = scope.tabController;

    if (_sortedByUpdateAt.isEmpty ||
        (![0, 1].contains(tabController.index) && widget.items == null)) {
      container = SliverToBoxAdapter();
    } else {
      container = SliverToBoxAdapter(child: container);
    }

    return SliverAnimatedPaintExtent(
      duration: const Duration(milliseconds: 350),
      child: container,
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required List<HistoryEntity> sortedByUpdateAt,
  }) : _sortedByUpdateAt = sortedByUpdateAt;

  final List<HistoryEntity> _sortedByUpdateAt;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final HomeScope? scope = HomeScope.maybeOf(context);
    final widthCache = 500;
    final heightCache = 340;
    final LibraryController libraryController =
        context.watch<LibraryController>();
    final libraryRepo = libraryController.repo;
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (scope != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 20),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  disabledIconColor: Colors.white,
                  disabledBackgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.only(left: 12, right: 8),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    SharedAxisTransitionPageWrapper(
                      transitionKey: ValueKey("watching"),
                      screen: WatchingDestinations(
                        onlyFavorites: scope.tabController.index == 1,
                      ),
                    ).createRoute(context),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continuar Assistindo',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Icon(MdiIcons.arrowRight),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              // key: PageStorageKey(
              //   'home_and_library_watching_${_sortedByUpdateAt.length}',
              // ),
              controller: scope?.keepWatchingScrollController,
              padding: scope != null
                  ? const EdgeInsets.only(left: 12, top: 8)
                  : const EdgeInsets.only(left: 8, bottom: 8),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _sortedByUpdateAt.length,
              itemBuilder: (context, index) {
                final HistoryEntity historyEntity =
                    _sortedByUpdateAt.elementAt(index);

                return switch (historyEntity) {
                  EpisodeEntity data => Builder(builder: (context) {
                      final anime = libraryRepo.getContentEntityByStringID(
                          data.animeStringID) as AnimeEntity?;

                      // if (data.positions.length > 1) {
                      //   return ListView.builder(
                      //     scrollDirection: Axis.horizontal,
                      //     shrinkWrap: true,
                      //     itemCount: data.positions.length,
                      //     itemBuilder: (context, index) {
                      //       final currentPosition =
                      //           data.positions.elementAt(index);
                      //       return Padding(
                      //         padding: const EdgeInsets.only(
                      //           right: 12,
                      //           top: 4,
                      //           bottom: 4,
                      //         ),
                      //         child: SizedBox(
                      //           height: 140,
                      //           width: 160,
                      //           child: ClipRRect(
                      //             borderRadius: BorderRadius.circular(12),
                      //             child: Stack(
                      //               fit: StackFit.expand,
                      //               children: [
                      //                 ShaderMask(
                      //                   blendMode: BlendMode.srcOver,
                      //                   shaderCallback: (bounds) {
                      //                     return LinearGradient(
                      //                       begin: Alignment.topCenter,
                      //                       end: Alignment.bottomCenter,
                      //                       colors: [
                      //                         Colors.black38.withAlpha(71),
                      //                         Colors.black38.withAlpha(71),
                      //                         // Colors.transparent,
                      //                       ],
                      //                       stops: const [0.00, 1.0],
                      //                     ).createShader(bounds);
                      //                   },
                      //                   child: currentPosition
                      //                               .currentPositionBase64 !=
                      //                           null
                      //                       ? _Image(
                      //                           width: widthCache,
                      //                           height: heightCache,
                      //                           currentPositionBase64:
                      //                               currentPosition
                      //                                   .currentPositionBase64!,
                      //                         )
                      //                       : data.thumbnail != null
                      //                           ? CachedNetworkImage(
                      //                               cacheManager:
                      //                                   App.APP_IMAGE_CACHE,
                      //                               fit: BoxFit.cover,
                      //                               memCacheWidth: widthCache,
                      //                               memCacheHeight: heightCache,
                      //                               imageUrl: data.thumbnail!,
                      //                               httpHeaders: App.HEADERS,
                      //                               errorWidget:
                      //                                   (context, url, error) {
                      //                                 return const Material(
                      //                                   child: Card.filled(),
                      //                                 );
                      //                               },
                      //                             )
                      //                           : const SizedBox.shrink(),
                      //                 ),
                      //                 Container(
                      //                   alignment: Alignment.topRight,
                      //                   padding: const EdgeInsets.only(
                      //                     left: 10,
                      //                     top: 8,
                      //                     right: 14,
                      //                   ),
                      //                   child: AnimatedDefaultTextStyle(
                      //                     duration:
                      //                         const Duration(milliseconds: 350),
                      //                     style: (textTheme.titleMedium ??
                      //                             const TextStyle())
                      //                         .copyWith(fontSize: 12),
                      //                     child: Text(
                      //                       data.cdToDuration.label(),
                      //                       maxLines: 1,
                      //                       textAlign: TextAlign.start,
                      //                       overflow: TextOverflow.ellipsis,
                      //                     ),
                      //                   ),
                      //                 ),
                      //                 if (anime != null)
                      //                   Column(
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.end,
                      //                     mainAxisSize: MainAxisSize.max,
                      //                     children: [
                      //                       Container(
                      //                         alignment: Alignment.bottomLeft,
                      //                         padding: const EdgeInsets.only(
                      //                           left: 10,
                      //                           right: 14,
                      //                         ),
                      //                         child: AnimatedDefaultTextStyle(
                      //                           duration: const Duration(
                      //                               milliseconds: 350),
                      //                           style: (textTheme.titleMedium ??
                      //                                   const TextStyle())
                      //                               .copyWith(fontSize: 12),
                      //                           child: Text(
                      //                             'Episódio ${data.numberEpisode}',
                      //                             maxLines: 1,
                      //                             textAlign: TextAlign.start,
                      //                             overflow:
                      //                                 TextOverflow.ellipsis,
                      //                           ),
                      //                         ),
                      //                       ),
                      //                       Container(
                      //                         alignment: Alignment.topLeft,
                      //                         padding: const EdgeInsets.only(
                      //                           left: 10,
                      //                           right: 6,
                      //                           bottom: 8,
                      //                         ),
                      //                         child: Text(
                      //                           anime.title,
                      //                           maxLines: 1,
                      //                           style: textTheme.titleMedium
                      //                               ?.copyWith(fontSize: 12),
                      //                           textAlign: TextAlign.start,
                      //                           overflow: TextOverflow.ellipsis,
                      //                           // style: textTheme.labelSmall?.copyWith(),
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 AnimatedBorderProgressIndicator(
                      //                   value: currentPosition.percent.isNaN
                      //                       ? 0.0
                      //                       : currentPosition.percent,
                      //                   color: anime?.anilistMedia?.coverImage
                      //                           ?.color?.fromHex ??
                      //                       Theme.of(context)
                      //                           .colorScheme
                      //                           .primary,
                      //                   strokeWidth: 4,
                      //                   borderRadius: 12,
                      //                 ),
                      //                 Material(
                      //                   type: MaterialType.transparency,
                      //                   child: InkWell(
                      //                     onTap: () async {
                      //                       final videoFile =
                      //                           AppStorage.getReleaseFile(
                      //                         anime!.toAnime(),
                      //                         data.toEpisode(anime.isDublado),
                      //                       );

                      //                       await context.push(
                      //                         RouteName.PLAYER,
                      //                         extra: PlayerArgs(
                      //                           forceEnterFullScreen: true,
                      //                           data: videoFile != null
                      //                               ? FileVideoData(
                      //                                   file: videoFile)
                      //                               : null,
                      //                           getAnimeData: false,
                      //                           anime: anime.toAnime(),
                      //                           episode: data
                      //                               .toEpisode(anime.isDublado),
                      //                           startPossition:
                      //                               data.cdToDuration,
                      //                         ),
                      //                       );
                      //                     },
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //   );
                      // }

                      final currentPosition = data.getLastCurrentPosition();

                      if (currentPosition == null) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                          right: 12,
                          top: 4,
                          bottom: 4,
                        ),
                        child: SizedBox(
                          height: 140,
                          width: 160,
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
                                  child: currentPosition
                                              .currentPositionBase64 !=
                                          null
                                      ? _Image(
                                          width: widthCache,
                                          height: heightCache,
                                          currentPositionBase64: currentPosition
                                              .currentPositionBase64!,
                                        )
                                      : data.thumbnail != null
                                          ? CachedNetworkImage(
                                              cacheManager: App.APP_IMAGE_CACHE,
                                              fit: BoxFit.cover,
                                              memCacheWidth: widthCache,
                                              memCacheHeight: heightCache,
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
                                    duration: const Duration(milliseconds: 350),
                                    style: (textTheme.titleMedium ??
                                            const TextStyle())
                                        .copyWith(fontSize: 12),
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
                                          duration:
                                              const Duration(milliseconds: 350),
                                          style: (textTheme.titleMedium ??
                                                  const TextStyle())
                                              .copyWith(fontSize: 12),
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
                                              ?.copyWith(fontSize: 12),
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          // style: textTheme.labelSmall?.copyWith(),
                                        ),
                                      ),
                                    ],
                                  ),
                                AnimatedBorderProgressIndicator(
                                  value: currentPosition.percent.isNaN
                                      ? 0.0
                                      : currentPosition.percent,
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
                                      final videoFile =
                                          AppStorage.getReleaseFile(
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
                                          episode:
                                              data.toEpisode(anime.isDublado),
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
        ],
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
