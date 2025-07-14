import 'package:app_wsrb_jsr/app/ui/home/widgets/filtro_bottom_sheet.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/keep_watching.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class WatchingDestinations extends StatefulWidget {
  const WatchingDestinations({
    super.key,
    this.onlyFavorites = false,
  });

  final bool onlyFavorites;

  @override
  State<WatchingDestinations> createState() => _WatchingDestinationsState();
}

class _WatchingDestinationsState extends State<WatchingDestinations>
    with SingleTickerProviderStateMixin {
  Map<ContentEntity, List<HistoryEntity>> _map = {};
  late final AnimationController _bottomSheetAnimationController;
  late final AppConfigController _appConfigController;

  @override
  void initState() {
    super.initState();
    _bottomSheetAnimationController =
        BottomSheet.createAnimationController(this);
    _appConfigController = context.read<AppConfigController>();
  }

  @override
  void didChangeDependencies() {
    _map.clear();
    // final historicRepo = _historicController.repo;
    final LibraryController libraryController =
        context.watch<LibraryController>();
    final libraRepo = libraryController.repo;

    final favoriteEntities =
        widget.onlyFavorites ? libraRepo.favorites : libraRepo.entities;

    for (var content in favoriteEntities) {
      final libraryRepo = libraryController.repo;
      final sortedByUpdateAt = libraryRepo.entities
          .map(libraryRepo.getAll)
          .nonNulls
          .flattened
          .where(
            (entity) => (entity is EpisodeEntity &&
                entity.animeStringID.contains(content.stringID)),
          )
          .sorted(_sorted);

      if (sortedByUpdateAt.isEmpty) continue;

      _map[content] = sortedByUpdateAt;
    }
    super.didChangeDependencies();
  }

  int _sorted(HistoryEntity a, HistoryEntity b) {
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

  void _filter() async {
    final result = await Navigator.push(
      context,
      FiltroBottomSheetRoute(
        genres: _map.keys
            .map((entity) => entity.anilistMedia?.genres)
            .nonNulls
            .flattened
            .toList(),
        appConfigController: _appConfigController,
        bottomSheetAnimationController: _bottomSheetAnimationController,
      ),
    );

    if (result != null) {
      _appConfigController.setFilterWatching(result);
      customLog(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _filter, icon: Icon(MdiIcons.plus)),
        ],
      ),
      body: _map.entries.isEmpty
          ? const SizedBox.shrink()
          : ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _map.entries.length,
              itemBuilder: (context, index) {
                final entry =
                    _map.entries.toList().reverse(true).elementAt(index);
                final value = entry.value;

                final key = entry.key;

                if (key is AnimeEntity && value.isNotEmpty) {
                  return ExpansionTile(
                    expandedAlignment: Alignment.topCenter,
                    // childrenPadding: EdgeInsets.zero,
                    // tilePadding: EdgeInsets.zero,m
                    minTileHeight: 48,
                    enableFeedback: true,
                    enabled: true,
                    initiallyExpanded: index == 0,
                    maintainState: true,
                    title: Text(
                      key.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 130,
                        child: KeepWatching(
                          items: value,
                          key: ObjectKey(value),
                        ),
                      )
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
    );
  }

  @override
  void dispose() {
    _bottomSheetAnimationController.dispose();
    super.dispose();
  }
}
