import 'package:content_library/content_library.dart';
import 'package:content_library/src/utils/in_repository.dart';

class InHistoricRepository extends InRepository<HistoricEntity> {
  UnmodifiableListView<String> get ids =>
      UnmodifiableListView(entities.map(_extractStringID).nonNulls);

  String? _extractStringID(HistoricEntity entity) => switch (entity) {
    EpisodeEntity e => e.stringID,
    ChapterEntity c => c.stringID,
    _ => null,
  };

  bool contains({HistoricEntity? historic, Release? release}) {
    final id = switch (historic ?? release) {
      EpisodeEntity e => e.stringID,
      ChapterEntity c => c.stringID,
      Episode e => e.stringID,
      Chapter c => c.stringID,
      _ => null,
    };
    return id != null && ids.contains(id);
  }

  T? getByID<T extends HistoricEntity>(List<String> ids) {
    return entities.firstWhereOrNull((entity) {
          if (entity is EpisodeEntity) {
            return ids.containsOneElement([entity.stringID, entity.contentStringID]);
          }
          return false;
        })
        as T?;
  }

  List<HistoricEntity> getAllByIDs(List<String> ids) {
    return entities.where((entity) {
      if (entity is EpisodeEntity) {
        return ids.containsOneElement([entity.stringID, entity.contentStringID]);
      }
      return false;
    }).toList();
  }

  UnmodifiableListView<HistoricEntity> get sortedByCreatedAt =>
      UnmodifiableListView(entities.sorted((a, b) => b.compareTo(a)));

  UnmodifiableListView<ChapterEntity> get chapterHistoric =>
      UnmodifiableListView(entities.whereType<ChapterEntity>());

  UnmodifiableListView<EpisodeEntity> get episodeHistoric =>
      UnmodifiableListView(entities.whereType<EpisodeEntity>());

  T? getHistoric<T extends HistoricEntity>({
    Release? release,
    Content? content,
    ContentEntity? contentEntity,
    T? Function()? orElse,
  }) {
    bool match(HistoricEntity e) => switch (e) {
      ChapterEntity c => c.stringID == release?.stringID,
      EpisodeEntity ep =>
        ep.stringID == release?.stringID &&
            release?.numberEpisode == ep.numberEpisode &&
            (content == null || ep.contentStringID.contains(content.stringID)),
      _ => false,
    };

    return entities.firstWhereOrNull(match) as T? ?? orElse?.call();
  }

  T? getInKeepWatching<T extends HistoricEntity>({
    required ContentEntity contentEntity,
    T? Function()? orElse,
  }) {
    return entities.firstWhereOrNull(
              (e) =>
                  e is EpisodeEntity &&
                  e.contentStringID.contains(contentEntity.stringID),
            )
            as T? ??
        orElse?.call();
  }
}
