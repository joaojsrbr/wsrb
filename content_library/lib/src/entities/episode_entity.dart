// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

part 'episode_entity.g.dart';

@Collection(
  ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'videoPercent', 'percent'},
)
class EpisodeEntity extends HistoricEntity {
  final String? sinopse;
  final int numberEpisode;
  @Index(replace: true, unique: true)
  final String stringID;
  final String animeStringID;
  final int? pageNumber;
  final DateTime? registrationData;
  final String? slugSerie;
  final String? generateID;

  @override
  double get percent {
    final percent = position?.percent;
    return isComplete == true ? 1.0 : (percent?.isNaN == true ? 0.0 : percent) ?? 0.0;
  }

  // @override
  // double getPercent() {
  //   final percent = getLastCurrentPosition()?.percent;
  //   return isComplete == true ? 1.0 : (percent?.isNaN == true ? 0.0 : percent) ?? 0.0;
  // }

  EpisodeEntity({
    super.position,
    required this.stringID,
    required super.title,
    required this.animeStringID,
    required this.sinopse,
    required this.numberEpisode,
    required super.url,
    this.slugSerie,
    this.registrationData,
    this.pageNumber,
    this.generateID,
    super.createdAt,
    super.thumbnail,
    super.updatedAt,
    super.isComplete = false,
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
    CurrentPosition? cPosition;

    final ePosition = duration != null && position != null;

    if (entity?.position != null && ePosition) {
      cPosition = entity!.position!.copyWith(
        currentPositionBase64: currentPositionBase64,
        episodeDuration: duration.inMicroseconds,
        currentDuration: position.inMicroseconds,
      );
    } else if (ePosition) {
      cPosition = CurrentPosition(
        createdAt: DateTime.now(),
        episodeDuration: duration.inMicroseconds,
        currentPositionBase64: currentPositionBase64,
        currentDuration: position.inMicroseconds,
      );
    }

    return EpisodeEntity(
      title: episode.title,
      registrationData: episode.registrationData ?? entity?.registrationData,
      animeStringID: anime.stringID,
      generateID: episode.generateID,
      slugSerie: episode.slugSerie,
      pageNumber: episode.pageNumber,
      url: episode.url,
      position: cPosition,
      thumbnail: episode.thumbnail,
      createdAt: entity?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      stringID: episode.stringID,
      isComplete: isComplete,
      sinopse: episode.sinopse,
      numberEpisode: episode.numberEpisode ?? episode.numberInt,
    );
  }

  @override
  List<Object?> get props => [
    position,
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
  int compareTo(HistoricEntity other) {
    if (other is EpisodeEntity) {
      return other.numberEpisode.compareTo(numberEpisode);
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

  @override
  EpisodeEntity copyWith({
    CurrentPosition? position,
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
      position: position,
    );
  }
}

@Embedded(
  ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'videoPercent', 'percent'},
)
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
  List<Object?> get props => [currentPositionBase64, currentDuration];

  CurrentPosition copyWith({
    int? currentDuration,
    int? episodeDuration,
    String? currentPositionBase64,
    DateTime? createdAt,
    double? percent,
  }) {
    return CurrentPosition(
      currentDuration: currentDuration ?? this.currentDuration,
      episodeDuration: episodeDuration ?? this.episodeDuration,
      currentPositionBase64: currentPositionBase64 ?? this.currentPositionBase64,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
