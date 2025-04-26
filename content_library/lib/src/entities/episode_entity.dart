// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

part 'episode_entity.g.dart';

@Collection(ignore: {
  'props',
  'imageUrl',
  'stringify',
  'hashCode',
  'videoPercent',
  'percent'
})
class EpisodeEntity extends HistoryEntity {
  final int episodeDuration;
  final int currentDuration;
  @override
  final bool isComplete;
  final String? sinopse;
  final int? numberEpisode;
  @Index(replace: true, unique: true)
  final String stringID;
  final String animeStringID;
  final DateTime? createdAt;
  final int? pageNumber;
  final DateTime? updatedAt;
  final String? thumbnail;
  final String? slugSerie;
  final String? generateID;
  final String url;
  final String? currentPositionBase64;
  final String title;

  @override
  final double percent;

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
  }) : percent = (currentDuration / episodeDuration).abs();

  factory EpisodeEntity.save({
    bool isComplete = false,
    required Episode episode,
    required Anime anime,
    Duration position = Duration.zero,
    Duration duration = Duration.zero,
    String? currentPositionBase64,
    EpisodeEntity? entity,
  }) {
    return EpisodeEntity(
      currentDuration: position.inMicroseconds,
      currentPositionBase64: currentPositionBase64,
      title: episode.title,
      animeStringID: anime.stringID,
      generateID: episode.generateID,
      slugSerie: episode.slugSerie,
      pageNumber: episode.pageNumber,
      url: episode.url,
      episodeDuration: duration.inMicroseconds,
      thumbnail: episode.thumbnail,
      createdAt: entity?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      stringID: episode.stringID,
      isComplete: isComplete,
      sinopse: episode.sinopse,
      numberEpisode: int.tryParse(episode.number),
    );
  }

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
}
