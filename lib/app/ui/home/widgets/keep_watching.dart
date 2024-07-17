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

class KeepWatching extends StatelessWidget {
  const KeepWatching({super.key});

  @override
  Widget build(BuildContext context) {
    final LibraryController libraryController =
        context.watch<LibraryController>();

    final HomeScope scope = HomeScope.of(context);

    final ThemeData themeData = Theme.of(context);

    final TextTheme textTheme = themeData.textTheme;

    final TabController tabController = scope.tabController;

    final LibraryService libraryService = LibraryService(libraryController);

    final sortedByCreatedAt = (tabController.index == 0
            ? libraryService.entities
            : libraryService.favorites)
        .map(LibraryService.getIsarLinks)
        .nonNulls
        .flattened
        .sorted((historic1, historic2) => historic1.compareTo(historic2));

    return SliverToBoxAdapter(
      child: (sortedByCreatedAt.isEmpty ||
              ![0, 1].contains(tabController.index))
          ? const SizedBox.shrink()
          : SizedBox(
              height: 180,
              width: double.infinity,
              child: ListView.builder(
                controller: scope.keepWatchingScrollController,
                padding: const EdgeInsets.only(left: 12, top: 12),
                scrollDirection: Axis.horizontal,
                // shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: sortedByCreatedAt.length,
                itemBuilder: (context, index) {
                  final HistoryEntity historyEntity =
                      sortedByCreatedAt.elementAt(index);

                  return switch (historyEntity) {
                    EpisodeEntity data => Builder(builder: (context) {
                        final anime = libraryService.getContentEntityByStringID(
                            data.animeStringID) as AnimeEntity?;

                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 12,
                            top: 8,
                            bottom: 8,
                          ),
                          child: SizedBox(
                            height: 160,
                            width: 200,
                            child: AnimatedBorderProgressIndicator(
                              value: data.videoPercent.isNaN
                                  ? 0.0
                                  : data.videoPercent,
                              color: data.videoPercent <= 0.85
                                  ? Colors.blue
                                  : Colors.green,
                              strokeWidth: 4,
                              borderRadius: 12,
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
                                            Colors.black38.withOpacity(0.28),
                                            Colors.black38.withOpacity(0.28),
                                            // Colors.transparent,
                                          ],
                                          stops: const [0.00, 1.0],
                                        ).createShader(bounds);
                                      },
                                      child: data.currentPositionBase64 != null
                                          ? _Image(
                                              currentPositionBase64:
                                                  data.currentPositionBase64!)
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
                                          Duration(
                                            milliseconds: data.currentDuration,
                                          ).label(),
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
                                    Material(
                                      type: MaterialType.transparency,
                                      child: InkWell(
                                        onTap: () async {
                                          final videoFile =
                                              AppStorage.getReleaseFile(
                                            anime!.toAnime,
                                            data.toEpisode(anime.toAnime),
                                          );
                                          await context.push(
                                            RouteName.PLAYER,
                                            extra: PlayerArgs(
                                              data: (videoFile?.existsSync() ??
                                                      false)
                                                  ? FileVideoData(
                                                      file: videoFile!,
                                                    )
                                                  : null,
                                              anime: anime.toAnime,
                                              episode: data.toEpisode(
                                                anime.toAnime,
                                              ),
                                              startPossition: Duration(
                                                milliseconds:
                                                    data.currentDuration,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }
}

class _Image extends StatefulWidget {
  const _Image({
    required this.currentPositionBase64,
  });

  final String currentPositionBase64;

  @override
  State<_Image> createState() => __ImageState();
}

class __ImageState extends State<_Image> {
  late Uint8List _currentPositionUint8List;
  late ResizeImage _memoryImage;
  @override
  void initState() {
    _currentPositionUint8List = base64.decode(widget.currentPositionBase64);
    _memoryImage = ResizeImage(
      MemoryImage(_currentPositionUint8List),
      width: 480,
      height: 280,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    precacheImage(_memoryImage, context);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant _Image oldWidget) {
    if (widget.currentPositionBase64 != oldWidget.currentPositionBase64) {
      _currentPositionUint8List = base64.decode(widget.currentPositionBase64);
      _memoryImage = ResizeImage(
        MemoryImage(_currentPositionUint8List),
        width: 480,
        height: 280,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: _memoryImage,
      fit: BoxFit.cover,
    );
  }
}
