import 'package:content_library/content_library.dart';

class HistoryService {
  final HistoricController _historicController;

  HistoryService(this._historicController);

  UnmodifiableListView<HistoryEntity> get sortedByCreatedAt =>
      UnmodifiableListView(
        _historicController.entities.sorted(
          (historic1, historic2) => historic2.compareTo(historic1),
        ),
      );
  UnmodifiableListView<ChapterEntity> get chapterHistoric =>
      UnmodifiableListView(entities.whereType<ChapterEntity>());

  HistoryEntity? getHistoric({Release? release}) {
    return entities.firstWhereOrNull(
      (e) => switch (e) {
        ChapterEntity data => data.stringID.contains(release?.stringID ?? ""),
        EpisodeEntity data => data.stringID.contains(release?.stringID ?? "") &&
            int.tryParse(release?.number ?? "") == data.numberEpisode,
        _ => false,
      },
    );
  }

  UnmodifiableListView<HistoryEntity> get entities =>
      _historicController.entities;
}
