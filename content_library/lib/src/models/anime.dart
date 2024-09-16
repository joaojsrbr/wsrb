// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:content_library/content_library.dart';

class Anime extends Content {
  const Anime({
    required super.url,
    required super.title,
    super.anilistMedia,
    required EpisodeReleases releases,
    required this.source,
    required this.originalImage,
    this.slugSerie,
    this.extraLarge,
    this.mediumImage,
    this.animeID,
    this.totalOfEpisodes,
    this.totalOfPages,
    this.largeImage,
    this.generateID,
    this.isDublado = false,
    super.sinopse,
    super.genres,
    super.cached,
  }) : super(releases);

  @override
  EpisodeReleases get releases => super.releases as EpisodeReleases;

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
    bool? cached,
    Source? source,
    int? totalOfEpisodes,
    AnilistMedia? anilistMedia,
    int? totalOfPages,
    String? sinopse,
    List<Genre>? genres,
  }) {
    return Anime(
      anilistMedia: anilistMedia ?? this.anilistMedia,
      source: source ?? this.source,
      genres: genres ?? this.genres,
      totalOfPages: totalOfPages ?? this.totalOfPages,
      totalOfEpisodes: totalOfEpisodes ?? this.totalOfEpisodes,
      generateID: generateID ?? this.generateID,
      cached: cached ?? this.cached,
      animeID: animeID ?? this.animeID,
      originalImage: originalImage ?? this.originalImage,
      mediumImage: mediumImage ?? this.mediumImage,
      largeImage: largeImage ?? this.largeImage,
      extraLarge: extraLarge ?? this.extraLarge,
      sinopse: sinopse ?? this.sinopse,
      isDublado: isDublado ?? this.isDublado,
      slugSerie: slugSerie ?? this.slugSerie,
      releases: EpisodeReleases.from(releases ?? this.releases),
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
    final content = AnimeEntity(
      totalOfPages: totalOfPages,
      anilistMedia: anilistMedia != null
          ? jsonEncode(AnilistMedia.toJson(anilistMedia!))
          : null,
      totalOfEpisodes: totalOfEpisodes,
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
          ? releases.firstOrNull?.thumbnail ?? ''
          : originalImage,
    );

    content.episodes.addAll(
      releases.map((episode) => episode.toEntity(anime: this)),
    );

    return content;
  }

  @override
  String get imageUrl {
    if (originalImage.isEmpty && releases.isEmpty) {
      return releases.first.thumbnail ?? '';
    }
    return extraLarge ?? largeImage ?? mediumImage ?? originalImage;
  }

  factory Anime.fromMap(Map<String, dynamic> map) {
    return Anime(
      anilistMedia: map['anilistMedia'] != null
          ? AnilistMedia.fromJson(map['anilistMedia'])
          : null,
      title: map['title'],
      cached: map['cached'] ?? false,
      url: map['url'],
      releases: map['releases'] is EpisodeReleases
          ? map['releases']
          : EpisodeReleases.from(
              (map['releases'] as List).map((e) => Episode.fromMap(e)),
            ),
      genres: map['genres'] != null
          ? (map['genres'] as List).map((e) => Genre(e)).toList()
          : [],
      generateID: map['generateID'],
      animeID: map['animeID'],
      source: Source.values.elementAt(map['source'] as int),
      extraLarge: map['extraLarge'],
      originalImage: map['originalImage'],
      largeImage: map['largeImage'],
      mediumImage: map['mediumImage'],
      slugSerie: map['slugSerie'],
      sinopse: map['sinopse'],
      isDublado: map['isDublado'],
      totalOfEpisodes: map['totalOfEpisodes'],
      totalOfPages: map['totalOfPages'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'class': 'ANIME',
        "genres": genres.map((e) => e.label).toList(),
        "generateID": generateID,
        "animeID": animeID,
        "source": source.index,
        "extraLarge": extraLarge,
        "originalImage": originalImage,
        "largeImage": largeImage,
        "mediumImage": mediumImage,
        "slugSerie": slugSerie,
        "isDublado": isDublado,
        "totalOfEpisodes": totalOfEpisodes,
        "totalOfPages": totalOfPages,
      };

  @override
  Anime merge(Content other) => super.merge(other) as Anime;
}
