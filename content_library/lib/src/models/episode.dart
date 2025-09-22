// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/content_library.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'generated/episode.mapper.dart';

@MappableClass()
class Episode extends Release with EpisodeMappable {
  const Episode({
    required super.url,
    required super.title,
    this.generateID,
    this.slugSerie,
    super.numberEpisode,
    this.pageNumber,
    this.registrationData,
    this.sinopse,
    this.thumbnail,
    required this.isDublado,
  });

  final String? sinopse;
  final int? pageNumber;

  final String? generateID;
  final String? thumbnail;
  final bool isDublado;
  final String? slugSerie;
  final DateTime? registrationData;

  bool isEqualStringID(Release release) => stringID.contains(release.stringID);

  String formatRegistrationData() {
    if (registrationData == null) return '';
    return timeago.format(registrationData!);
  }

  @override
  List<Object?> get props => [
    stringID,
    title,
    pageNumber,
    generateID,
    isDublado,
    thumbnail,
    numberEpisode,
    sinopse,
    slugSerie,
  ];

  EpisodeEntity toEntity({
    required Anime anime,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) => EpisodeEntity(
    registrationData: registrationData,
    title: title,
    pageNumber: pageNumber,
    contentStringID: anime.stringID,
    generateID: generateID,
    slugSerie: slugSerie,
    url: url,
    thumbnail: thumbnail,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt ?? DateTime.now(),
    stringID: stringID,
    sinopse: sinopse,
    numberEpisode: numberInt,
  );

  factory Episode.fromReleaseMap(
    Map<String, dynamic> map,
    Anime anime, [
    int? pageNumber,
  ]) {
    final number = int.parse(map['n_episodio']);
    final titleEpisode = map['titulo_episodio'] as String;
    final sinopseEpisode = map['sinopse_episodio'] as String?;
    final episodeGenerateID = map['generate_id'] as String?;
    final thumbnail =
        "https://static.anroll.net/images/animes/screens/${anime.slugSerie}/${map['n_episodio']}.jpg";
    return Episode(
      numberEpisode: number,
      registrationData: map["data_registro"] != null
          ? DateTime.parse(map["data_registro"])
          : null,
      isDublado: anime.isDublado,
      url: '${Source.ANROLL.baseURL}/e/$episodeGenerateID',
      generateID: episodeGenerateID,
      pageNumber: pageNumber,
      title: titleEpisode.contains('Episódio') ? 'N/A' : titleEpisode,
      sinopse: sinopseEpisode,
      slugSerie: anime.slugSerie,
      thumbnail: thumbnail,
    );
  }
}
