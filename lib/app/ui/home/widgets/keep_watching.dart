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
  const KeepWatching({super.key, this.items});
  final List<HistoryEntity>? items;

  @override
  State<KeepWatching> createState() => _KeepWatchingState();
}

class _KeepWatchingState extends State<KeepWatching> {
  List<HistoryEntity> _sortedByUpdateAt = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.items != null) {
      _sortedByUpdateAt = widget.items!.sorted(_sortedItems);
      return;
    }

    final tabController = HomeScope.of(context).tabController;
    final libraryController = context.watch<LibraryController>();
    final repo = libraryController.repo;

    _sortedByUpdateAt =
        (tabController.index == 0 ? repo.noFavorites : repo.favorites)
            .map(repo.getIsarLinks)
            .flattened
            .sorted(_sortedByCreateAt)
            .getMax(5);
  }

  int _sortedItems(HistoryEntity a, HistoryEntity b) {
    if ((a, b) case (EpisodeEntity a1, EpisodeEntity b1)
        when a1.numberEpisode != null && b1.numberEpisode != null) {
      return b1.numberEpisode!.compareTo(a1.numberEpisode!);
    }
    return -1;
  }

  int _sortedByCreateAt(HistoryEntity a, HistoryEntity b) {
    if ((a, b) case (EpisodeEntity a1, EpisodeEntity b1)
        when a1.getLastCurrentPosition()?.createdAt != null &&
            b1.getLastCurrentPosition()?.createdAt != null) {
      return b1
          .getLastCurrentPosition()!
          .createdAt!
          .compareTo(a1.getLastCurrentPosition()!.createdAt!);
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items != null) {
      return _Content(sortedByUpdateAt: _sortedByUpdateAt);
    }

    final scope = HomeScope.maybeOf(context);
    final tabController = scope?.tabController;
    final isValid = _sortedByUpdateAt.isNotEmpty &&
        ([0, 1].contains(tabController?.index) || widget.items != null);

    return SliverAnimatedPaintExtent(
      duration: const Duration(milliseconds: 350),
      child: isValid
          ? SliverToBoxAdapter(
              child: _Content(sortedByUpdateAt: _sortedByUpdateAt),
            )
          : const SliverToBoxAdapter(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.sortedByUpdateAt});
  final List<HistoryEntity> sortedByUpdateAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = HomeScope.maybeOf(context);
    final libraryRepo = context.watch<LibraryController>().repo;

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
                onPressed: () {
                  Navigator.of(context).push(
                    SharedAxisTransitionPageWrapper(
                      transitionKey: const ValueKey("watching"),
                      screen: WatchingDestinations(
                        onlyFavorites: scope.tabController.index == 1,
                      ),
                    ).createRoute(context),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continuar Assistindo',
                      style: theme.textTheme.titleSmall?.copyWith(
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(MdiIcons.arrowRight, color: Colors.white),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: scope?.keepWatchingScrollController,
              scrollDirection: Axis.horizontal,
              padding: scope != null
                  ? const EdgeInsets.only(left: 12, top: 8)
                  : const EdgeInsets.only(left: 8, bottom: 8),
              itemCount: sortedByUpdateAt.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final entity = sortedByUpdateAt[index];
                if (entity is! EpisodeEntity) return const SizedBox.shrink();

                final anime = libraryRepo.getContentEntityByStringID(
                  entity.animeStringID,
                ) as AnimeEntity?;
                final position = entity.getLastCurrentPosition();

                if (position == null) return const SizedBox.shrink();

                final imageWidget = position.currentPositionBase64 != null
                    ? _Image(
                        width: 500,
                        height: 340,
                        currentPositionBase64: position.currentPositionBase64!,
                      )
                    : (entity.thumbnail != null
                        ? CachedNetworkImage(
                            cacheManager: App.APP_IMAGE_CACHE,
                            imageUrl: entity.thumbnail!,
                            memCacheWidth: 500,
                            memCacheHeight: 340,
                            fit: BoxFit.cover,
                            httpHeaders: App.HEADERS,
                            errorWidget: (context, url, error) =>
                                const Material(child: Card.filled()),
                          )
                        : const SizedBox.shrink());

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black38.withAlpha(71),
                                Colors.black38.withAlpha(71),
                              ],
                            ).createShader(bounds),
                            child: imageWidget,
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(
                                left: 10, top: 8, right: 14),
                            child: Text(
                              entity.cdToDuration.label(),
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (anime != null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    'Episódio ${entity.numberEpisode}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 6, bottom: 8),
                                  child: Text(
                                    anime.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          AnimatedBorderProgressIndicator(
                            value:
                                position.percent.isNaN ? 0.0 : position.percent,
                            color: anime?.anilistMedia?.coverImage?.color
                                    ?.fromHex ??
                                theme.colorScheme.primary,
                            strokeWidth: 4,
                            borderRadius: 12,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final videoFile = AppStorage.getReleaseFile(
                                  anime!.toAnime(),
                                  entity.toEpisode(anime.isDublado),
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
                                    episode: entity.toEpisode(anime.isDublado),
                                    startPossition: entity.cdToDuration,
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
  final String currentPositionBase64;
  final int width;
  final int height;

  @override
  State<_Image> createState() => _ImageState();
}

class _ImageState extends State<_Image> {
  late Uint8List _bytes;
  late ResizeImage _image;
  late ResizeImage _placeholder;

  @override
  void initState() {
    super.initState();
    _initImages();
  }

  @override
  void didUpdateWidget(covariant _Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPositionBase64 != oldWidget.currentPositionBase64 ||
        widget.width != oldWidget.width ||
        widget.height != oldWidget.height) {
      _initImages();
    }
  }

  void _initImages() {
    _bytes = base64Decode(widget.currentPositionBase64);
    _image = ResizeImage(MemoryImage(_bytes),
        width: widget.width, height: widget.height);
    _placeholder = ResizeImage(App.IMAGE_BLACK,
        width: widget.width, height: widget.height);
  }

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      image: _image,
      placeholder: _placeholder,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholderFit: BoxFit.cover,
    );
  }
}
