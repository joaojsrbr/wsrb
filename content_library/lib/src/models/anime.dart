// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/content_library.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'generated/anime.mapper.dart';

@MappableClass()
class Anime extends Content with AnimeMappable {
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
    super.repoStatus,
    super.isMovie,
    super.genres,
  }) : super(releases);

  factory Anime.empty() {
    return Anime(
      url: "",
      title: "",
      releases: EpisodeReleases(),
      source: Source.TOP_ANIMES,
      originalImage: "",
    );
  }

  @override
  EpisodeReleases get releases => super.releases as EpisodeReleases;

  @override
  List<Object?> get props => [
    imageUrl,
    stringID,
    url,
    sinopse,
    releases,
    genres,
    title,
    source,
  ];

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
  AnimeEntity toEntity({
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite = false,
  }) {
    final entity = AnimeEntity(
      totalOfPages: totalOfPages,
      anilistMedia: anilistMedia,
      totalOfEpisodes: totalOfEpisodes,
      source: source,
      isMovie: isMovie,
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

    entity.episodes.addAll(releases.map((episode) => episode.toEntity(anime: this)));

    // entity.animeSkip.value = animeSkip?.toEntity;

    return entity;
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
