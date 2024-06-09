import 'package:content_library/content_library.dart';

class Anime extends Content {
  const Anime({
    required super.url,
    required super.title,
    required super.releases,
    required this.source,
    required this.originalImage,
    this.slugSerie,
    this.genres,
    this.extraLarge,
    this.mediumImage,
    this.animeID,
    this.totalOfEpisodes,
    this.totalOfPages,
    this.largeImage,
    this.generateID,
    this.isDublado = false,
    super.sinopse,
  });
  final List<Genre>? genres;
  final String? generateID;
  final String? animeID;
  final Source source;
  final String? extraLarge;
  final String originalImage;
  final String? largeImage;
  final String? mediumImage;
  final String? slugSerie;
  final bool isDublado;

  final int? totalOfEpisodes;
  final int? totalOfPages;

  @override
  Anime copyWith({
    Releases? releases,
    String? title,
    String? url,
    String? animeID,
    String? slugSerie,
    String? originalImage,
    String? extraLarge,
    String? largeImage,
    String? generateID,
    String? mediumImage,
    bool? isDublado,
    Source? source,
    int? totalOfEpisodes,
    int? totalOfPages,
    String? sinopse,
    List<Genre>? genres,
  }) {
    return Anime(
      source: source ?? this.source,
      genres: genres ?? this.genres,
      totalOfPages: totalOfPages ?? this.totalOfPages,
      totalOfEpisodes: totalOfEpisodes ?? this.totalOfEpisodes,
      generateID: generateID ?? this.generateID,
      animeID: animeID ?? this.animeID,
      originalImage: originalImage ?? this.originalImage,
      mediumImage: mediumImage ?? this.mediumImage,
      largeImage: largeImage ?? this.largeImage,
      extraLarge: extraLarge ?? this.extraLarge,
      sinopse: sinopse ?? this.sinopse,
      isDublado: isDublado ?? this.isDublado,
      slugSerie: slugSerie ?? this.slugSerie,
      releases: releases ?? this.releases,
      title: title ?? this.title,
      url: url ?? this.url,
    );
  }

  @override
  AnimeEntity toEntity({
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite = false,
  }) {
    return AnimeEntity(
      source: source,
      animeID: animeID,
      stringID: stringID,
      slugSerie: slugSerie,
      sinopse: sinopse,
      isDublado: isDublado,
      generateID: generateID,
      url: url,
      title: title,
      isFavorite: isFavorite,
      extraLarge: extraLarge,
      mediumImage: mediumImage,
      largeImage: largeImage,
      createdAt: createdAt,
      updatedAt: updatedAt,
      originalImage: originalImage.isEmpty
          ? (releases.firstOrNull as Episode?)?.thumbnail ?? ''
          : originalImage,
    );
  }

  @override
  List<Object?> get props => [
        title,
        genres,
        url,
        stringID,
        source,
        sinopse,
        releases,
        slugSerie,
        isDublado,
        originalImage,
        extraLarge,
        generateID,
        largeImage,
        mediumImage,
        animeID,
        releases,
      ];

  @override
  String get imageUrl =>
      extraLarge ?? largeImage ?? mediumImage ?? originalImage;
}
