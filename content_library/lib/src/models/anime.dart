// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/content_library.dart';

class Anime extends Content {
  const Anime({
    required super.url,
    required super.title,
    super.anilistMedia,
    required EpisodeReleases releases,
    required super.source,
    required this.originalImage,
    this.slugSerie,
    this.buildId,
    this.extraLarge,
    this.mediumImage,
    this.animeID,
    this.totalOfEpisodes,
    this.animeSkip,
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
  final String? buildId;
  final String? animeID;
  final String? extraLarge;
  final String originalImage;
  final String? largeImage;
  final String? mediumImage;
  final String? slugSerie;
  final AnimeSkip? animeSkip;
  final bool isDublado;
  final int? totalOfEpisodes;
  final int? totalOfPages;

  @override
  Anime copyWith({
    Releases? releases,
    String? title,
    String? buildId,
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
    AniListMedia? anilistMedia,
    int? totalOfPages,
    String? sinopse,
    List<Genre>? genres,
    AnimeSkip? animeSkip,
  }) {
    return Anime(
      animeSkip: animeSkip ?? this.animeSkip,
      buildId: buildId ?? this.buildId,
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
      anilistMedia: anilistMedia,
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

    content.episodes.addAll(releases.map((episode) => episode.toEntity(anime: this)));

    content.animeSkip.value = animeSkip?.toEntity;

    return content;
  }

  @override
  String get imageUrl {
    return {
          anilistMedia?.bannerImage?.medium,
          anilistMedia?.coverImage?.large,
          anilistMedia?.coverImage?.medium,
          extraLarge,
          largeImage,
          mediumImage,
        }.firstWhereOrNull((img) => img != null) ??
        originalImage;
  }
}
