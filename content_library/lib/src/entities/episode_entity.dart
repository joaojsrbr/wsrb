import 'package:content_library/src/entities/entity.dart';

import 'package:isar/isar.dart';

part 'episode_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode'})
class EpisodeEntity extends HistoryEntity {
  int episodeDuration;

  int currentDuration;

  bool isComplete;

  String? sinopse;
  int? numberEpisode;

  @Index(replace: true, unique: true)
  String stringID;
  String animeStringID;

  DateTime? createdAt;
  DateTime? updatedAt;

  EpisodeEntity({
    required this.currentDuration,
    required this.episodeDuration,
    required this.stringID,
    required this.animeStringID,
    required this.sinopse,
    required this.numberEpisode,
    this.createdAt,
    this.updatedAt,
    this.isComplete = false,
  });

  @override
  List<Object?> get props => [
        episodeDuration,
        animeStringID,
        currentDuration,
        isComplete,
        stringID,
        numberEpisode,
        sinopse,
        createdAt,
        updatedAt,
      ];
}
