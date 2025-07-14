// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
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
  final DateTime? registrationData;
  final String? thumbnail;
  final String? slugSerie;
  final String? generateID;
  final String url;
  // final int currentDuration;
  // final String? currentPositionBase64;
  final String title;
  final List<CurrentPosition> positions;

  CurrentPosition? getLastCurrentPosition() {
    return positions.reduceOrNull(
      (position1, position2) =>
          (position1.createdAt != null && position2.createdAt != null) &&
                  (position1.createdAt!.millisecond >
                      position2.createdAt!.millisecond)
              ? position1
              : position2,
    );
  }

  @override
  double get percent => getPercent();

  @override
  double getPercent() {
    final percent = getLastCurrentPosition()?.percent;
    return isComplete == true
        ? 1.0
        : (percent?.isNaN == true ? 0.0 : percent) ?? 0.0;
  }

  EpisodeEntity({
    this.positions = const [],
    required this.stringID,
    required this.title,
    required this.animeStringID,
    required this.sinopse,
    required this.numberEpisode,
    required this.url,
    this.slugSerie,
    this.registrationData,
    this.pageNumber,
    this.generateID,
    this.createdAt,
    this.thumbnail,
    this.updatedAt,
    this.isComplete = false,
  });

  factory EpisodeEntity.save({
    bool isComplete = false,
    required Episode episode,
    required Anime anime,
    Duration? position,
    Duration? duration,
    String? currentPositionBase64,
    EpisodeEntity? entity,
  }) {
    return EpisodeEntity(
      title: episode.title,
      registrationData: episode.registrationData ?? entity?.registrationData,
      animeStringID: anime.stringID,
      generateID: episode.generateID,
      slugSerie: episode.slugSerie,
      pageNumber: episode.pageNumber,
      url: episode.url,
      positions: [
        if (duration != null && position != null)
          CurrentPosition(
            createdAt: DateTime.now(),
            episodeDuration: duration.inMicroseconds,
            currentPositionBase64: currentPositionBase64,
            currentDuration: position.inMicroseconds,
          )
        else
          ...?entity?.positions,
      ],
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
        positions,
        thumbnail,
        animeStringID,
        pageNumber,
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
      registrationData: registrationData,
      isDublado: isDublado,
      sinopse: sinopse,
      thumbnail: thumbnail,
    );
  }

  EpisodeEntity copyWith({
    bool? isComplete,
    String? sinopse,
    int? numberEpisode,
    String? stringID,
    String? animeStringID,
    DateTime? createdAt,
    int? pageNumber,
    DateTime? updatedAt,
    DateTime? registrationData,
    String? thumbnail,
    String? slugSerie,
    String? generateID,
    String? url,
    String? title,
    List<CurrentPosition>? positions,
  }) {
    return EpisodeEntity(
      isComplete: isComplete ?? this.isComplete,
      sinopse: sinopse ?? this.sinopse,
      numberEpisode: numberEpisode ?? this.numberEpisode,
      stringID: stringID ?? this.stringID,
      animeStringID: animeStringID ?? this.animeStringID,
      createdAt: createdAt ?? this.createdAt,
      pageNumber: pageNumber ?? this.pageNumber,
      updatedAt: updatedAt ?? this.updatedAt,
      registrationData: registrationData ?? this.registrationData,
      thumbnail: thumbnail ?? this.thumbnail,
      slugSerie: slugSerie ?? this.slugSerie,
      generateID: generateID ?? this.generateID,
      url: url ?? this.url,
      title: title ?? this.title,
      positions: positions ?? this.positions,
    );
  }
}

@Embedded(ignore: {
  'props',
  'imageUrl',
  'stringify',
  'hashCode',
  'videoPercent',
  'percent'
})
class CurrentPosition with EquatableMixin {
  final int currentDuration;
  final int episodeDuration;
  final String? currentPositionBase64;
  final DateTime? createdAt;
  final double percent;

  CurrentPosition({
    this.currentDuration = 0,
    this.currentPositionBase64,
    this.createdAt,
    this.episodeDuration = 0,
  }) : percent = (currentDuration / episodeDuration).abs();

  @override
  List<Object?> get props => [
        currentPositionBase64,
        currentDuration,
      ];
}
