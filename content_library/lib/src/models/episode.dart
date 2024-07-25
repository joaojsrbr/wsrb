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

  EpisodeEntity toEntity({
    required Anime anime,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) =>
      EpisodeEntity(
        title: title,
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
}
