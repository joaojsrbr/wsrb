import 'package:content_library/content_library.dart';
import 'package:content_library/src/utils/in_repository.dart';

class InHistoricRepository extends InRepository<HistoricEntity> {
  UnmodifiableListView<String> get ids =>
      UnmodifiableListView(entities.map(_map).nonNulls);

  String? _map(HistoricEntity entity) {
    return switch (entity) {
      EpisodeEntity data => data.stringID,
      ChapterEntity data => data.stringID,
      _ => null,
    };
  }

  bool contains({HistoricEntity? HistoricEntity, Release? release}) {
    bool result = false;
    if (release != null) {
      assert(HistoricEntity == null);
      result = switch (release) {
        Episode data => ids.contains(data.stringID),
        Chapter data => ids.contains(data.stringID),
        _ => false,
      };
    } else if (HistoricEntity != null) {
      assert(release == null);
      result = switch (HistoricEntity) {
        EpisodeEntity data => ids.contains(data.stringID),
        ChapterEntity data => ids.contains(data.stringID),
        _ => false,
      };
    }
    return result;
  }

  T? getHistoricEntityByID<T extends HistoricEntity>(List<String> ids) {
    final entity = entities.firstWhereOrNull(
      (entity) => switch (entity) {
        EpisodeEntity data => ids.containsOneElement([
          data.stringID,
          data.animeStringID,
        ]),
        _ => false,
      },
    );

    return entity is T ? entity : null;
  }

  List<HistoricEntity> getAllHistoricEntityByID(List<String> ids) {
    return entities
        .where(
          (entity) => switch (entity) {
            EpisodeEntity data => ids.containsOneElement([
              data.stringID,
              data.animeStringID,
            ]),
            _ => false,
          },
        )
        .cast<HistoricEntity>()
        .toList();
  }

  UnmodifiableListView<HistoricEntity> get sortedByCreatedAt =>
      UnmodifiableListView(
        entities.sorted(
          (historic1, historic2) => historic2.compareTo(historic1),
        ),
      );

  UnmodifiableListView<ChapterEntity> get chapterHistoric =>
      UnmodifiableListView<ChapterEntity>(entities.whereType());

  UnmodifiableListView<EpisodeEntity> get episodeHistoric =>
      UnmodifiableListView<EpisodeEntity>(entities.whereType());

  T? getHistoric<T extends HistoricEntity>({
    Release? release,
    Content? content,
    ContentEntity? contentEntity,
    T? Function()? orElse,
  }) {
    bool matchesEntity(HistoricEntity e) {
      return switch (e) {
        ChapterEntity data => data.stringID.contains(release?.stringID ?? ""),
        EpisodeEntity data =>
          data.stringID.contains(release?.stringID ?? "") &&
              int.tryParse(release?.number ?? "") == data.numberEpisode &&
              (content == null ||
                  data.animeStringID.contains(content.stringID)),
        _ => false,
      };
    }

    return entities.firstWhereOrNull(matchesEntity) as T? ?? orElse?.call();
  }

  T? getHistoricInKeepWatching<T extends HistoricEntity>({
    required ContentEntity contentEntity,
    T? Function()? orElse,
  }) {
    bool matchesEntity(HistoricEntity e) {
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
