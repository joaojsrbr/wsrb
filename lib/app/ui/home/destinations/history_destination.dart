import 'dart:collection';

import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_network_image_cache.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/global_overlay.dart';
import 'package:app_wsrb_jsr/app/utils/history_utils.dart';
import 'package:app_wsrb_jsr/app/utils/multi_comparator.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HistoryDestination extends StatefulWidget {
  const HistoryDestination({super.key});

  @override
  State<HistoryDestination> createState() => _HistoryDestinationState();
}

class _HistoryDestinationState extends State<HistoryDestination>
    with AutomaticKeepAliveClientMixin {
  final Map<DateTime, ContentHistoricGroup> _map = SplayTreeMap();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _map.clear();

    final appConfig = context.watch<AppConfigController>();
    final library = context.watch<LibraryController>();
    final repo = library.repo;

    final filterWatching = appConfig.config.filterWatching;
    final genresFilter = filterWatching.genresFilter;
    final filterSources = filterWatching.filterSources;

    for (final content in repo.entities) {
      if (_shouldSkipContent(content, filterSources.toSet(), genresFilter)) continue;

      final historics = _getFilteredHistorics(library, content, filterWatching);
      _removePreviousEpisodes(historics);
      if (historics.isEmpty) continue;

      final grouped = historics.groupListsBy(
        (h) => _dateOnly(h.position?.createdAt ?? h.updatedAt),
      );

      for (final entry in grouped.entries) {
        final date = entry.key;
        if (date == null) continue;

        _map.update(
          date,
          (existing) {
            existing.historics.addAll(entry.value);
            existing.contents.add(content);
            return existing;
          },
          ifAbsent: () => ContentHistoricGroup(
            contents: {content},
            historics: SplayTreeSet.from(
              historics,
              multiComparator<HistoricEntity>({
                _sortByCreatedAt,
                (a, b) {
                  if (a is EpisodeEntity && b is EpisodeEntity) {
                    return a.numberEpisode.compareTo(b.numberEpisode) +
                        content.title.length;
                  }
                  return 0;
                },
              }),
            ),
          ),
        );
      }
    }
  }

  /// Decide se o conteúdo deve ser ignorado pelo filtro
  bool _shouldSkipContent(
    ContentEntity content,
    Set<Source> filterSources,
    List<String> genresFilter,
  ) {
    if (filterSources.isNotEmpty && !filterSources.contains(content.source)) {
      return true;
    }

    final genres = content.anilistMedia?.genres ?? [];
    if (genresFilter.isNotEmpty && !genresFilter.containsOneElement(genres)) {
      return true;
    }

    return false;
  }

  /// Remove episódios anteriores ao último encontrado
  void _removePreviousEpisodes(List<HistoricEntity> historics) {
    final grouped = historics.groupSetsBy((e) => e.contentStringID);
    final all = grouped.values.flattened.toList();

    final maxEp = all.reduceOrNull(_getMaxEpisode);
    if (maxEp == null) return;

    historics.removeWhere(
      (a) =>
          a.numberEpisode < maxEp.numberEpisode &&
          maxEp.contentStringID.contains(a.contentStringID),
    );
  }

  HistoricEntity _getMaxEpisode(HistoricEntity a, HistoricEntity b) {
    final aNum = a.numberEpisode;
    final bNum = b.numberEpisode;

    if (aNum > bNum) return a;
    if (aNum < bNum) return b;

    if (bNum is double) {
      if (bNum.isNaN) return b;
      return a;
    }

    if (bNum == 0 && aNum.isNegative) return b;
    return a;
  }

  int _sortByCreatedAt(HistoricEntity a, HistoricEntity b) {
    if ((a, b) case (
      EpisodeEntity ep1,
      EpisodeEntity ep2,
    ) when ep1.position?.createdAt != null && ep2.position?.createdAt != null) {
      return ep1.position!.createdAt!.compareTo(ep2.position!.createdAt!);
    }
    return -1;
  }

  List<HistoricEntity> _getFilteredHistorics(
    LibraryController library,
    ContentEntity content,
    FilterWatching filterWatching,
  ) {
    final historics = _getHistorics(library, content);
    return historics.where((e) => _applyDateFilter(e, filterWatching)).toList();
  }

  bool _applyDateFilter(HistoricEntity entity, FilterWatching filter) {
    if (entity.isComplete) return false;
    if (entity is! EpisodeEntity || entity.createdAt == null) return true;

    final createdAt = entity.createdAt!;
    final start = filter.start;
    final end = filter.end;

    if (filter.infiniteDate) {
      return start == null ||
          (end != null && (createdAt.isAtSameMomentAs(end) || createdAt.isBefore(end)));
    }

    if (start != null && end != null) {
      return (createdAt.isAtSameMomentAs(start) || createdAt.isAfter(start)) &&
          (createdAt.isAtSameMomentAs(end) || createdAt.isBefore(end));
    }

    if (start != null) {
      return createdAt.isAtSameMomentAs(start) || createdAt.isAfter(start);
    }
    if (end != null) return createdAt.isAtSameMomentAs(end) || createdAt.isBefore(end);

    return true;
  }

  DateTime? _dateOnly(DateTime? date) =>
      date == null ? null : DateTime(date.year, date.month, date.day, date.hour);

  List<HistoricEntity> _getHistorics(LibraryController library, ContentEntity content) {
    final repo = library.repo;
    return repo.entities
        .map(repo.getAll)
        .nonNulls
        .flattened
        .where((e) => e is EpisodeEntity && e.contentStringID.contains(content.stringID))
        .toList();
  }

  ContentEntity _getContentByHistoric(
    Iterable<ContentEntity> contents,
    HistoricEntity historic,
  ) {
    final id = switch (historic) {
      EpisodeEntity e => e.contentStringID,
      ChapterEntity c => c.bookStringID,
      _ => "",
    };
    return contents.firstWhere((c) => c.stringID.contains(id));
  }

  String _dateLabel(DateTime date) => timeago.format(date, allowFromNow: true);

  String _chapterInfo(HistoricEntity historic, ContentEntity content) {
    switch ((historic, content)) {
      case (EpisodeEntity e, AnimeEntity _) when e.position?.createdAt != null:
        return "Episódio ${e.numberEpisode} - "
            "${DateFormat('HH:mm').format(e.position!.createdAt!)}";
      case (ChapterEntity c, BookEntity _) when c.position?.createdAt != null:
        return "${c.title} - ${DateFormat('HH:mm').format(c.position!.createdAt!)}";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final entries = _map.entries.toList().reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final (contents, historics) = (entry.value.contents, entry.value.historics);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _dateLabel(entry.key),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),

            ...historics.map((e) => _ItemBuilder(e, contents)),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ItemBuilder extends StatelessWidget {
  const _ItemBuilder(this.historic, this.contents);
  final HistoricEntity historic;
  final Set<ContentEntity> contents;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_HistoryDestinationState>()!;
    final content = state._getContentByHistoric(contents, historic);
    final theme = Theme.of(context);
    final library = context.watch<LibraryController>();
    final historicController = context.watch<HistoricController>();
    final borderRadius = BorderRadius.circular(8);
    return InkWell(
      onTap: () async {
        if ((historic, content) case (EpisodeEntity ep, AnimeEntity anime)) {
          final videoFile = AppStorage.getReleaseFile(
            anime.toContent(),
            ep.toEpisode(anime.isDublado),
          );
          await context.pushEnum(
            RouteName.PLAYER,
            extra: PlayerArgs(
              forceEnterFullScreen: true,
              data: [if (videoFile != null) FileVideoData(file: videoFile)],
              anime: anime.toContent(),
              episode: ep.toEpisode(anime.isDublado),
              startPossition: ep.cdToDuration,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCachedNetworkImage(
              onTap: () async {
                if ((historic, content) case (EpisodeEntity _, AnimeEntity anime)) {
                  final result = await context.pushEnum(
                    RouteName.CONTENTINFO,
                    extra: ContentInformationArgs(
                      content: anime.toContent(),
                      isLibrary: false,
                    ),
                  );
                  if (result != null && context.mounted) {
                    context.showErrorNotification(result.toString());
                  }
                }
              },
              imageUrl: content.imageUrl.isEmpty
                  ? historic.thumbnail ?? content.imageUrl
                  : content.imageUrl,
              borderRadius: borderRadius,
              height: 100,
              width: 80,
              fit: BoxFit.cover,
              memCacheHeight: 300,
              memCacheWidth: 200,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    content.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state._chapterInfo(historic, content),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                content.isFavorite ? MdiIcons.heart : MdiIcons.heartOutline,
                size: 20,
              ),
              color: content.isFavorite ? Colors.red : null,
              onPressed: () {
                library.add(
                  contentEntity: content.copyWith(isFavorite: !content.isFavorite),
                );
              },
            ),
            IconButton(
              icon: Icon(MdiIcons.delete, size: 20),
              onPressed: () async {
                await HistoryUtils.questionDelete(
                  context,
                  [historic],
                  onConfirmDelete: () {
                    historicController.add(
                      historic: historic.copyWith(
                        position: null,
                        updatedAt: DateTime.now(),
                      ),
                    );
                  },
                  onUndoDelete: (oldHistoric) {
                    historicController.addAll(historyEntities: oldHistoric);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
