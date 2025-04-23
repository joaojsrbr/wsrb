// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/content_library.dart';

class Episode extends Release {
  const Episode({
    required super.url,
    required super.title,
    this.generateID,
    this.slugSerie,
    this.numberEpisode,
    this.pageNumber,
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

  bool isEqualStringID(Episode episode) => episode.stringID.contains(stringID);

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
  }) =>
      EpisodeEntity(
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
      numberEpisode:
          map['numberEpisode'] != null ? map['numberEpisode'] as int : null,
      generateID:
          map['generateID'] != null ? map['generateID'] as String : null,
      thumbnail: map['thumbnail'] != null ? map['thumbnail'] as String : null,
      isDublado: map['isDublado'] as bool,
      slugSerie: map['slugSerie'] != null ? map['slugSerie'] as String : null,
    );
  }
}
