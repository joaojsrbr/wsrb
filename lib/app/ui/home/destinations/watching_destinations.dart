import 'package:app_wsrb_jsr/app/ui/home/widgets/keep_watching.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
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

class _WatchingDestinationsState extends State<WatchingDestinations> {
  // late final HistoricController _historicController;
  // late final LibraryController _libraryController;

  Map<ContentEntity, List<HistoryEntity>> _map = {};

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
}
