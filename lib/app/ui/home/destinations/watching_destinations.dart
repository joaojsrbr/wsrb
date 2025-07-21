import 'package:app_wsrb_jsr/app/ui/home/widgets/filtro_bottom_sheet.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/keep_watching.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class WatchingDestinations extends StatefulWidget {
  const WatchingDestinations({super.key, this.onlyFavorites = false});

  final bool onlyFavorites;

  @override
  State<WatchingDestinations> createState() => _WatchingDestinationsState();
}

class _WatchingDestinationsState extends State<WatchingDestinations> with SingleTickerProviderStateMixin {
  final Map<ContentEntity, List<HistoryEntity>> _map = {};
  late final AnimationController _bottomSheetAnimationController;
  late final AppConfigController _appConfigController;

  @override
  void initState() {
    super.initState();
    _bottomSheetAnimationController = BottomSheet.createAnimationController(this);
    _appConfigController = context.read<AppConfigController>();
  }

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
    final entities = widget.onlyFavorites ? libraRepo.favorites : libraRepo.noFavorites;
    final allGenres = entities.map((content) => content.anilistMedia?.genres).nonNulls.flattened.toList();

    // Filtrar e mapear entidades
    for (final content in entities) {
      if (filterSources.isEmpty || !filterSources.contains(content.source)) continue;

      // Ignorar se não houver gêneros ou se o filtro de gêneros não corresponder
      final genres = content.anilistMedia?.genres ?? [];
      if (!genresFilter.containsOneElement(genres) && allGenres.isNotEmpty) {
        continue;
      }

      // Obter históricos filtrados por data
      final sortedHistorics = _getFilteredHistorics(libraryController, content, filterWatching);

      // Adicionar ao mapa apenas se houver históricos válidos
      if (sortedHistorics.isNotEmpty) {
        _map[content] = sortedHistorics;
      }
    }
  }

  // Função para obter históricos filtrados por intervalo de datas
  List<HistoryEntity> _getFilteredHistorics(
    LibraryController libraryController,
    ContentEntity content,
    FilterWatching filterWatching,
  ) {
    final historics = _getHistorics(libraryController, content, filterWatching);
    return historics.where((entity) => _applyDateFilter(entity, filterWatching)).toList();
  }

  // Função para aplicar filtro de intervalo de datas
  bool _applyDateFilter(HistoryEntity entity, FilterWatching filterWatching) {
    if (entity is! EpisodeEntity || entity.createdAt == null) {
      return true; // Manter se não for episódio ou data inválida
    }

    final createdAt = _formatDataToDM(entity.createdAt)!;
    final start = filterWatching.start;
    final end = filterWatching.end;
    final infiniteDate = filterWatching.infiniteDate;

    // Se data infinita estiver ativa, considera apenas datas anteriores ao início
    if (infiniteDate) {
      return start == null || end != null && (createdAt.isAtSameMomentAs(end) || createdAt.isBefore(end));
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

  // int _sorted(HistoryEntity a, HistoryEntity b) {
  //   if ((a, b) case (
  //     EpisodeEntity data1,
  //     EpisodeEntity data2,
  //   ) when data1.getLastCurrentPosition()?.createdAt != null && data2.getLastCurrentPosition()?.createdAt != null) {
  //     return data1.getLastCurrentPosition()!.createdAt!.compareTo(data2.getLastCurrentPosition()!.createdAt!);
  //   }
  //   return -1;
  // }

  List<HistoryEntity> _getHistorics(
    LibraryController libraryController,
    ContentEntity content,
    FilterWatching filterWatching,
  ) {
    final libraryRepo = libraryController.repo;
    return libraryRepo.entities
        .map(libraryRepo.getAll)
        .nonNulls
        .flattened
        .where((entity) => (entity is EpisodeEntity && entity.animeStringID.contains(content.stringID)))
        .toList();
  }

  void _pushTofilter() async {
    final result = await Navigator.push(
      context,
      FiltroBottomSheetRoute(
        onlyFavorites: widget.onlyFavorites,
        // genres: _map.keys.map((entity) => entity.anilistMedia?.genres).nonNulls.flattened.toList(),
        appConfigController: _appConfigController,
        bottomSheetAnimationController: _bottomSheetAnimationController,
      ),
    );

    if (result != null) {
      // _appConfigController.setFilterWatching(result);
      customLog(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final appConfigController = context.watch<AppConfigController>();
    // final libraryController = context.watch<LibraryController>();

    // final filterWatching = appConfigController.config.filterWatching;
    // final DateTime startDate = DateTime(DateTime.now().year, DateTime.january, 1);

    // final libraRepo = libraryController.repo;
    // final entities = widget.onlyFavorites ? libraRepo.favorites : libraRepo.noFavorites;
    // final sources = entities.map((content) => content.source).toList();
    // final genres = entities.map((content) => content.anilistMedia?.genres ?? []).flattened.nonNulls.toList();

    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: _pushTofilter, icon: Icon(MdiIcons.plus))],
      ),
      body: Column(
        children: [
          // Flexible(
          //   child: SizedBox(
          //     width: double.infinity,
          //     child: SingleChildScrollView(
          //       physics: BouncingScrollPhysics(),
          //       scrollDirection: Axis.horizontal,
          //       child: Row(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         spacing: 6,
          //         children: [
          //           const SizedBox(width: 2),
          //           if (_map.entries.isEmpty)
          //             TextButton(
          //               onPressed: () {
          //                 _appConfigController.setFilterWatching(
          //                   FilterWatching(filterSources: sources, genresFilter: genres),
          //                 );
          //               },
          //               child: const Text("Limpar"),
          //             ),
          //           if (filterWatching.end != null) ...[
          //             ChoiceChip(
          //               selected: true,
          //               padding: EdgeInsets.zero,
          //               onSelected: (result) {
          //                 _appConfigController.setFilterWatching(
          //                   filterWatching.copyWith(start: DateTime(0), end: DateTime(0), infiniteDate: false),
          //                 );
          //               },
          //               label: Text.rich(
          //                 TextSpan(
          //                   children: [
          //                     if (!filterWatching.infiniteDate && filterWatching.start != null)
          //                       TextSpan(
          //                         text: "De ${_formatDay(filterWatching.start!.day.toDouble(), filterWatching.start!)}",
          //                       )
          //                     else
          //                       TextSpan(text: "De ∞"),
          //                     WidgetSpan(child: SizedBox(width: 4)),
          //                     TextSpan(
          //                       text:
          //                           'Até ${_formatDay(filterWatching.end!.day.toDouble(), filterWatching.start ?? startDate)}',
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //           ],
          //           if (filterWatching.genresFilter.isNotEmpty)
          //             ...filterWatching.genresFilter.map(
          //               (filter) => ChoiceChip(
          //                 label: Text(filter),
          //                 selected: true,
          //                 avatar: Icon(MdiIcons.close),
          //                 showCheckmark: false,
          //                 labelPadding: EdgeInsets.only(right: 12),
          //                 padding: EdgeInsets.zero,
          //                 onSelected: (result) {
          //                   final newFenresFilter = List<String>.from(filterWatching.genresFilter)..add(filter);
          //                   _appConfigController.setFilterWatching(
          //                     filterWatching.copyWith(genresFilter: newFenresFilter),
          //                   );
          //                 },
          //               ),
          //             ),
          //           // if (filterWatching.filterSources.isNotEmpty)
          //           //   ...filterWatching.filterSources.map(
          //           //     (filter) => ChoiceChip(
          //           //       label: Text(filter.label),
          //           //       selected: true,

          //           //       padding: EdgeInsets.zero,
          //           //       onSelected: (result) {
          //           //         final newFilterSources = List<Source>.from(filterWatching.filterSources)..remove(filter);
          //           //         _appConfigController.setFilterWatching(
          //           //           filterWatching.copyWith(filterSources: newFilterSources),
          //           //         );
          //           //       },
          //           //     ),
          //           //   ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // if (_map.entries.isEmpty) Divider(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: _map.entries.length,
              itemBuilder: (context, index) {
                final entry = _map.entries.toList().reverse(true).elementAt(index);
                final value = entry.value;

                final key = entry.key;

                if (key is AnimeEntity && value.isNotEmpty) {
                  return ExpansionTile(
                    expandedAlignment: Alignment.topCenter,
                    minTileHeight: 48,
                    enableFeedback: true,
                    enabled: true,
                    initiallyExpanded: index == 0,
                    maintainState: true,
                    title: Text(key.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 130,
                        child: KeepWatching(items: value, key: ObjectKey(value)),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDay(double days, DateTime startDate) {
    DateTime d = startDate.add(Duration(days: days.toInt()));
    return DateFormat('dd/MM').format(d);
  }

  @override
  void dispose() {
    _bottomSheetAnimationController.dispose();
    super.dispose();
  }
}
