// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/src/entities/entity.dart';
import 'package:content_library/src/models/episode.dart';
import 'package:isar/isar.dart';

part 'episode_entity.g.dart';

@Collection(
    ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'videoPercent'})
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
  int? pageNumber;
  DateTime? updatedAt;
  String? thumbnail;
  String? slugSerie;
  String? generateID;
  String url;
  String? currentPositionBase64;
  String title;

  double get videoPercent => (currentDuration / episodeDuration).abs();

  EpisodeEntity({
    this.currentDuration = 0,
    this.episodeDuration = 0,
    required this.stringID,
    required this.title,
    required this.animeStringID,
    required this.sinopse,
    required this.numberEpisode,
    required this.url,
    this.slugSerie,
    this.pageNumber,
    this.currentPositionBase64,
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
        currentPositionBase64,
        pageNumber,
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
      return other.updatedAt!.compareTo(updatedAt!);
    } else if (updatedAt != null &&
        (other as EpisodeEntity).updatedAt == null) {
      return 1;
    } else if (updatedAt == null &&
        (other as EpisodeEntity).updatedAt != null) {
      return 0;
    }
    return -1;
  }

  Episode toEpisode(bool isDublado) {
    return Episode(
      pageNumber: pageNumber,
      url: url,
      title: title,
      numberEpisode: numberEpisode,
      generateID: generateID,
      slugSerie: slugSerie,
      isDublado: isDublado,
      sinopse: sinopse,
      thumbnail: thumbnail,
    );
  }

  @override
  String toString() {
    return 'EpisodeEntity(episodeDuration: $episodeDuration, currentDuration: $currentDuration, isComplete: $isComplete, sinopse: $sinopse, numberEpisode: $numberEpisode, stringID: $stringID, animeStringID: $animeStringID, createdAt: $createdAt, updatedAt: $updatedAt, thumbnail: $thumbnail, slugSerie: $slugSerie, generateID: $generateID, url: $url, title: $title)';
  }
}
