import 'package:content_library/src/entities/entity.dart';
import 'package:content_library/src/models/episode.dart';

import 'package:isar/isar.dart';

import '../models/anime.dart';

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

  String? thumbnail;
  String? slugSerie;
  String? generateID;
  String url;
  String title;

  EpisodeEntity({
    required this.currentDuration,
    required this.episodeDuration,
    required this.stringID,
    required this.title,
    required this.animeStringID,
    required this.sinopse,
    required this.numberEpisode,
    required this.url,
    this.slugSerie,
    this.generateID,
    this.createdAt,
    this.thumbnail,
    this.updatedAt,
    this.isComplete = false,
  });

  @override
  List<Object?> get props => [
        episodeDuration,
        thumbnail,
        animeStringID,
        currentDuration,
        isComplete,
        stringID,
        numberEpisode,
        sinopse,
        createdAt,
        updatedAt,
        title,
      ];

  @override
  int compareTo(HistoryEntity other) {
    if (updatedAt != null && (other as EpisodeEntity).updatedAt != null) {
      return updatedAt!.compareTo(other.updatedAt!);
    } else if (updatedAt != null &&
        (other as EpisodeEntity).updatedAt == null) {
      return 1;
    } else if (updatedAt == null &&
        (other as EpisodeEntity).updatedAt != null) {
      return 0;
    }
    return -1;
  }

  Episode toEpisode(Anime anime) {
    return Episode(
      url: url,
      title: title,
      numberEpisode: numberEpisode,
      generateID: generateID,
      slugSerie: slugSerie,
      isDublado: anime.isDublado,
      sinopse: sinopse,
      thumbnail: thumbnail,
    );
  }
}
