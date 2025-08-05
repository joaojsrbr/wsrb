// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/content_library.dart';
import 'package:timeago/timeago.dart' as timeago;

class Episode extends Release {
  const Episode({
    required super.url,
    required super.title,
    this.generateID,
    this.slugSerie,
    this.numberEpisode,
    this.pageNumber,
    this.registrationData,
    this.sinopse,
    this.thumbnail,
    required this.isDublado,
  });

  final String? sinopse;
  final int? pageNumber;
  final int? numberEpisode;
  final String? generateID;
  final String? thumbnail;
  final bool isDublado;
  final String? slugSerie;
  final DateTime? registrationData;

  bool isEqualStringID(Release release) => release.stringID.contains(stringID);

  String formatRegistrationData() {
    if (registrationData == null) return '';
    return timeago.format(registrationData!);
  }

  @override
  List<Object?> get props => [
    stringID,
    title,
    url,
    pageNumber,
    generateID,
    isDublado,
    thumbnail,
    numberEpisode,
    sinopse,
    slugSerie,
  ];

  @override
  String get number {
    return numberEpisode?.toString() ??
        title.replaceAll(RegExp(r'[^0-9]'), '').trim();
  }

  int get numberInt {
    return int.parse(number);
  }

  EpisodeEntity toEntity({
    required Anime anime,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) => EpisodeEntity(
    registrationData: registrationData,
    title: title,
    pageNumber: pageNumber,
    animeStringID: anime.stringID,
    generateID: generateID,
    slugSerie: slugSerie,
    url: url,
    thumbnail: thumbnail,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt ?? DateTime.now(),
    stringID: stringID,
    sinopse: sinopse,
    numberEpisode: int.tryParse(number),
  );

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'title': title,
      'url': url,
      'sinopse': sinopse,
      'pageNumber': pageNumber,
      'numberEpisode': numberEpisode,
      'generateID': generateID,
      'thumbnail': thumbnail,
      'isDublado': isDublado,
      'slugSerie': slugSerie,
    };
  }

  factory Episode.fromMap(Map<String, dynamic> map) {
    return Episode(
      title: map['title'],
      url: map['url'],
      sinopse: map['sinopse'] != null ? map['sinopse'] as String : null,
      pageNumber: map['pageNumber'] != null ? map['pageNumber'] as int : null,
      numberEpisode: map['numberEpisode'] != null
          ? map['numberEpisode'] as int
          : null,
      generateID: map['generateID'] != null
          ? map['generateID'] as String
          : null,
      thumbnail: map['thumbnail'] != null ? map['thumbnail'] as String : null,
      isDublado: map['isDublado'] as bool,
      slugSerie: map['slugSerie'] != null ? map['slugSerie'] as String : null,
    );
  }
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
