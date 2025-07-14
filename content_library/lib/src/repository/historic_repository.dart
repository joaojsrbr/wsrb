import 'package:content_library/content_library.dart';
import 'package:content_library/src/utils/in_repository.dart';

class InHistoricRepository extends InRepository<HistoryEntity> {
  UnmodifiableListView<String> get ids =>
      UnmodifiableListView(entities.map(_map).nonNulls);

  String? _map(HistoryEntity entity) {
    return switch (entity) {
      EpisodeEntity data => data.stringID,
      ChapterEntity data => data.stringID,
      _ => null,
    };
  }

  bool contains({
    HistoryEntity? historyEntity,
    Release? release,
  }) {
    bool result = false;
    if (release != null) {
      assert(historyEntity == null);
      result = switch (release) {
        Episode data => ids.contains(data.stringID),
        Chapter data => ids.contains(data.stringID),
        _ => false,
      };
    } else if (historyEntity != null) {
      assert(release == null);
      result = switch (historyEntity) {
        EpisodeEntity data => ids.contains(data.stringID),
        ChapterEntity data => ids.contains(data.stringID),
        _ => false,
      };
    }
    return result;
  }

  T? getHistoryEntityByID<T extends HistoryEntity>(List<String> ids) {
    final entity = entities.firstWhereOrNull((entity) => switch (entity) {
          EpisodeEntity data =>
            ids.containsOneElement([data.stringID, data.animeStringID]),
          _ => false,
        });

    return entity is T ? entity : null;
  }

  List<HistoryEntity> getAllHistoryEntityByID(List<String> ids) {
    return entities
        .where((entity) => switch (entity) {
              EpisodeEntity data =>
                ids.containsOneElement([data.stringID, data.animeStringID]),
              _ => false,
            })
        .cast<HistoryEntity>()
        .toList();
  }

  UnmodifiableListView<HistoryEntity> get sortedByCreatedAt =>
      UnmodifiableListView(
        entities.sorted(
          (historic1, historic2) => historic2.compareTo(historic1),
        ),
      );

  UnmodifiableListView<ChapterEntity> get chapterHistoric =>
      UnmodifiableListView<ChapterEntity>(entities.whereType());

  UnmodifiableListView<EpisodeEntity> get episodeHistoric =>
      UnmodifiableListView<EpisodeEntity>(entities.whereType());

  T? getHistoric<T extends HistoryEntity>({
    Release? release,
    Content? content,
    ContentEntity? contentEntity,
    T? Function()? orElse,
  }) {
    bool matchesEntity(HistoryEntity e) {
      return switch (e) {
        ChapterEntity data => data.stringID.contains(release?.stringID ?? ""),
        EpisodeEntity data => data.stringID.contains(release?.stringID ?? "") &&
            int.tryParse(release?.number ?? "") == data.numberEpisode &&
            (content == null || data.animeStringID.contains(content.stringID)),
        _ => false,
      };
    }

    return entities.firstWhereOrNull(matchesEntity) as T? ?? orElse?.call();
  }

  T? getHistoricInKeepWatching<T extends HistoryEntity>({
    required ContentEntity contentEntity,
    T? Function()? orElse,
  }) {
    bool matchesEntity(HistoryEntity e) {
      if (e case EpisodeEntity episode) {
        return episode.animeStringID.contains(contentEntity.stringID);
      } else {
        return false;
      }
    }

    final value =
        entities.firstWhereOrNull(matchesEntity) as T? ?? orElse?.call();
    return value;
  }
}
