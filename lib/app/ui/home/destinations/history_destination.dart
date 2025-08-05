import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:app_wsrb_jsr/app/ui/player/arguments/player_args.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_network_image_cache.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:app_wsrb_jsr/app/utils/history_utils.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class HistoryDestination extends StatefulWidget {
  const HistoryDestination({super.key});

  @override
  State<HistoryDestination> createState() => _HistoryDestinationState();
}

class _HistoryDestinationState extends State<HistoryDestination>
    with AutomaticKeepAliveClientMixin {
  final Map<DateTime, (List<ContentEntity>, List<HistoricEntity>)> _map = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies(); // Chamar super primeiro para seguir boas práticas

    // Limpar o mapa antes de processar novos dados
    _map.clear();

    // Obter controladores e configurações do contexto
    final appConfigController = context.watch<AppConfigController>();
    final libraryController = context.watch<LibraryController>();
    final libraRepo = libraryController.repo;
    final filterWatching = appConfigController.config.filterWatching;
    final genresFilter = filterWatching.genresFilter;
    final filterSources = filterWatching.filterSources;

    // Selecionar entidades com base no parâmetro onlyFavorites
    final entities = libraRepo.entities;
    // final allGenres = entities.map((content) => content.anilistMedia?.genres).nonNulls.flattened.toList();

    // Filtrar e mapear entidades
    for (final content in entities) {
      if (filterSources.isEmpty || !filterSources.contains(content.source)) continue;

      // Ignorar se não houver gêneros ou se o filtro de gêneros não corresponder
      final genres = content.anilistMedia?.genres ?? [];
      if (genresFilter.isNotEmpty && !genresFilter.containsOneElement(genres)) {
        continue;
      }

      // Obter históricos filtrados por data
      final sortedHistorics = _getFilteredHistorics(
        libraryController,
        content,
        filterWatching,
      );

      // Adicionar ao mapa apenas se houver históricos válidos
      if (sortedHistorics.isNotEmpty) {
        final toMap = sortedHistorics.groupListsBy(
          (date) => _formatDataToDM(date.updatedAt),
        );

        for (final entry in toMap.entries) {
          final date = entry.key;

          if (date == null) continue;

          if (_map[date] != null) {
            final list = _map[date]?.$2;
            for (var entity in entry.value) {
              list?.addOrUpdateWhere(entity, entity.contains);
            }

            _map[date]?.$1.addOrUpdateWhere(content, content.contains);
            _map[date]?.$2.sort(_sorted);
          } else {
            _map[date] = ([content], sortedHistorics);
          }
        }
      }
    }
  }

  int _sorted(HistoricEntity a, HistoricEntity b) {
    if (a is EpisodeEntity &&
        b is EpisodeEntity &&
        b.updatedAt != null &&
        a.updatedAt != null) {
      return a.updatedAt!.compareTo(b.updatedAt!);
    }

    return -1;
  }

  // Função para obter históricos filtrados por intervalo de datas
  List<HistoricEntity> _getFilteredHistorics(
    LibraryController libraryController,
    ContentEntity content,
    FilterWatching filterWatching,
  ) {
    final historics = _getHistorics(libraryController, content, filterWatching);
    return historics.where((entity) => _applyDateFilter(entity, filterWatching)).toList();
  }

  // Função para aplicar filtro de intervalo de datas
  bool _applyDateFilter(HistoricEntity entity, FilterWatching filterWatching) {
    if (entity is! EpisodeEntity || entity.createdAt == null) {
      return true; // Manter se não for episódio ou data inválida
    }

    final createdAt = _formatDataToDM(entity.createdAt)!;
    final start = filterWatching.start;
    final end = filterWatching.end;
    final infiniteDate = filterWatching.infiniteDate;

    // Se data infinita estiver ativa, considera apenas datas anteriores ao início
    if (infiniteDate) {
      return start == null ||
          end != null && (createdAt.isAtSameMomentAs(end) || createdAt.isBefore(end));
    }

    // Se ambas datas existem, verifica se está dentro do intervalo
    if (start != null && end != null) {
      return (createdAt.isAtSameMomentAs(start) || createdAt.isAfter(start)) &&
          (createdAt.isAtSameMomentAs(end) || createdAt.isBefore(end));
    }

    // Se apenas a data de início existe
    if (start != null) {
      return createdAt.isAtSameMomentAs(start) || createdAt.isAfter(start);
    }

    // Se apenas a data de fim existe
    if (end != null) {
      return createdAt.isAtSameMomentAs(end) || createdAt.isBefore(end);
    }

    return true; // Sem filtro
  }

  DateTime? _formatDataToDM(DateTime? data) {
    if (data == null) return null;

    return DateTime(data.year, data.month, data.day);
  }

  List<HistoricEntity> _getHistorics(
    LibraryController libraryController,
    ContentEntity content,
    FilterWatching filterWatching,
  ) {
    final libraryRepo = libraryController.repo;
    return libraryRepo.entities.map(libraryRepo.getAll).nonNulls.flattened.where((
      entity,
    ) {
      return (entity is EpisodeEntity && entity.animeStringID.contains(content.stringID));
    }).toList();
  }

  @override
  bool get wantKeepAlive => true;

  ContentEntity _getContentByList(List<ContentEntity> data, HistoricEntity historic) {
    final id = switch (historic) {
      EpisodeEntity data => data.animeStringID,
      ChapterEntity data => data.bookStringID,
      _ => "",
    };

    return data.firstWhere((content) => content.stringID.contains(id));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    // final searchController = HomeScope.of(context).searchController;
    // final searchQuery = searchController.text.trim();
    // final searchOpen = searchController.isOpen;
    // final contentRepo = context.watch<ContentRepository>();
    final borderRadius = BorderRadius.circular(8);
    final library = context.watch<LibraryController>();
    final historicController = context.watch<HistoricController>();

    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _map.length,
      itemBuilder: (context, index) {
        final entry = _map.entries.toList().reverse(true).elementAt(index);
        final (contents, historics) = entry.value;
        final date = entry.key;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _dateLabelMelhorado(date),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            //  const SizedBox(height: 16),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Row(
            //     children: [
            //       const Expanded(child: Divider(thickness: 1)),
            //       const SizedBox(width: 8),
            //       Text(_dateLabelMelhorado(date), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            //       const SizedBox(width: 8),
            //       const Expanded(child: Divider(thickness: 1)),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 12),
            ...List.generate(historics.length, (index) {
              final historic = historics.elementAt(index);
              final content = _getContentByList(contents, historic);

              return InkWell(
                onTap: () async {
                  if ((historic, content) case (
                    EpisodeEntity episode,
                    AnimeEntity anime,
                  )) {
                    final videoFile = AppStorage.getReleaseFile(
                      anime.toAnime(),
                      episode.toEpisode(anime.isDublado),
                    );
                    await context.push(
                      RouteName.PLAYER.route,
                      extra: PlayerArgs(
                        forceEnterFullScreen: true,
                        data: videoFile != null ? [FileVideoData(file: videoFile)] : null,
                        getAnimeData: true,
                        anime: anime.toAnime(),
                        episode: episode.toEpisode(anime.isDublado),
                        startPossition: episode.cdToDuration,
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomCachedNetworkImage(
                        onTap: () async {
                          if ((historic, content) case (
                            EpisodeEntity _,
                            AnimeEntity anime,
                          )) {
                            final result = await context.push(
                              RouteName.CONTENTINFO.route,
                              extra: ContentInformationArgs(
                                content: anime.toAnime(),
                                isLibrary: false,
                              ),
                            );
                            if (result != null && context.mounted) {
                              context.showErrorSnackBar(result);
                            }
                          }
                        },
                        imageUrl: content.imageUrl.isEmpty
                            ? historic.thumbnail ?? content.imageUrl
                            : content.imageUrl,
                        borderRadius: borderRadius,
                        height: 80,
                        width: 60,
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
                              _chapterInfo(historic, content),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
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
                          if (content.isFavorite) {
                            library.add(
                              contentEntity: content.copyWith(isFavorite: false),
                            );
                          } else {
                            library.add(
                              contentEntity: content.copyWith(isFavorite: true),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(MdiIcons.delete, size: 20),
                        onPressed: () async {
                          final result = await HistoryUtils.questionDelete(
                            context,
                            historic,
                          );
                          if (result) {
                            historicController.add(
                              HistoricEntity: historic.copyWith(
                                positions: [],
                                updatedAt: DateTime.now(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _dateLabelMelhorado(DateTime date) {
    // Pega a data e hora de agora
    final now = DateTime.now();

    // Cria objetos DateTime apenas com a data (zerando a hora),
    // para garantir uma comparação de dias precisa.
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Calcula a diferença em dias.
    // Se o resultado for 0, é hoje.
    // Se for 1, foi ontem.
    // Se for -1, será amanhã.
    final differenceInDays = today.difference(dateOnly).inDays;

    if (differenceInDays == 0) {
      return 'Hoje';
    } else if (differenceInDays == 1) {
      return 'Ontem';
    } else if (differenceInDays > 1 && differenceInDays <= 6) {
      // Para datas entre 2 e 6 dias atrás
      return 'Há $differenceInDays dias';
    } else if (differenceInDays == -1) {
      // Para o dia de amanhã
      return 'Amanhã';
    } else {
      // Para qualquer outra data (mais antiga que 6 dias ou no futuro distante),
      // retorna o formato padrão.
      // Usar 'pt_BR' garante que a formatação seja consistente.
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
    }
  }

  String _chapterInfo(HistoricEntity historic, ContentEntity content) {
    // return historic.title;

    switch ((historic, content)) {
      case (EpisodeEntity data, AnimeEntity _) when data.updatedAt != null:
        final chapter = 'Episodio ${data.numberEpisode}';
        final time = DateFormat('HH:mm').format(data.updatedAt!);
        return [chapter, time].where((e) => e.isNotEmpty).join(' - ');
      case (ChapterEntity data, BookEntity _) when data.updatedAt != null:
        final chapter = data.title;
        final time = DateFormat('HH:mm').format(data.updatedAt!);
        return [chapter, time].where((e) => e.isNotEmpty).join(' - ');
    }

    // final chapter = content.chapter != null ? 'Cap. ${content.chapter}' : '';
    // final time = DateFormat('HH:mm').format(content);
    // return [chapter, time].where((e) => e.isNotEmpty).join(' - ');
    return "";
  }
}
