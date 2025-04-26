// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable

import 'package:content_library/src/constants/source.dart';
import 'package:content_library/src/entities/anilist_media.dart';
import 'package:content_library/src/entities/anime_skip_entity.dart';
import 'package:content_library/src/entities/entity.dart';
import 'package:content_library/src/entities/episode_entity.dart';
import 'package:content_library/src/models/anime.dart';
import 'package:content_library/src/utils/releases.dart';
import 'package:isar/isar.dart';

part 'anime_entity.g.dart';

@Collection(ignore: {
  'props',
  'imageUrl',
  'stringify',
  'hashCode',
  'toAnime',
  'map',
  'aniList',
})
class AnimeEntity extends ContentEntity {
  final DateTime? createdAt;
  final String? animeID;
  final DateTime? updatedAt;
  final String? sinopse;
  @enumerated
  final Source source;
  final bool isDublado;

  final String? slugSerie;
  final String url;
  final String title;
  final String originalImage;
  final String? extraLarge;
  final String? largeImage;
  final String? mediumImage;
  final String? generateID;
  final int? totalOfEpisodes;
  final int? totalOfPages;

  IsarLinks<EpisodeEntity> episodes;
  IsarLink<AnimeSkipEntity> animeSkip;

  AnimeEntity({
    required super.stringID,
    required this.url,
    required this.totalOfEpisodes,
    required this.title,
    required this.source,
    super.anilistMedia,
    this.createdAt,
    this.animeID,
    this.totalOfPages,
    this.isDublado = false,
    this.slugSerie,
    this.updatedAt,
    this.sinopse,
    this.generateID,
    super.isFavorite = false,
    required this.originalImage,
    this.extraLarge,
    this.largeImage,
    this.mediumImage,
  })  : episodes = IsarLinks<EpisodeEntity>(),
        animeSkip = IsarLink<AnimeSkipEntity>();

  String get imageUrl =>
      extraLarge ?? largeImage ?? mediumImage ?? originalImage;

  @override
  List<Object?> get props => [
        animeID,
        stringID,
        episodes,
        createdAt,
        totalOfPages,
        sinopse,
        updatedAt,
        source,
        isDublado,
        isFavorite,
        slugSerie,
        url,
        title,
        originalImage,
        extraLarge,
        largeImage,
        animeSkip.value,
        mediumImage,
        generateID,
        totalOfEpisodes,
      ];

  void addEpisode(EpisodeEntity entity) {
    episodes.add(entity);
  }

  Future<void> saveEpisode() async => await episodes.save();

  Future<void> saveAnimeSkip() async {
    if (animeSkip.value != null) await animeSkip.save();
  }

  Anime toAnime() {
    return Anime(
      anilistMedia: anilistMedia,
      url: url,
      totalOfPages: totalOfPages,
      animeID: animeID,
      title: title,
      generateID: generateID,
      animeSkip: animeSkip.value?.toObj(),
      totalOfEpisodes: totalOfEpisodes,
      slugSerie: slugSerie,
      source: source,
      sinopse: sinopse,
      releases: EpisodeReleases.from(
        episodes.map((entity) => entity.toEpisode(isDublado)).toList(),
      ),
      originalImage: originalImage,
      extraLarge: extraLarge,
      largeImage: largeImage,
      mediumImage: mediumImage,
    );
  }

  AnimeEntity copyWith({
    AniListMedia? anilistMedia,
    DateTime? createdAt,
    String? animeID,
    DateTime? updatedAt,
    String? sinopse,
    Source? source,
    bool? isDublado,
    bool? isFavorite,
    String? slugSerie,
    String? url,
    String? title,
    String? originalImage,
    String? extraLarge,
    String? largeImage,
    String? stringID,
    String? mediumImage,
    String? generateID,
    int? totalOfEpisodes,
    int? totalOfPages,
  }) {
    final entity = AnimeEntity(
      stringID: stringID ?? this.stringID,
      anilistMedia: anilistMedia ?? this.anilistMedia,
      createdAt: createdAt ?? this.createdAt,
      animeID: animeID ?? this.animeID,
      updatedAt: updatedAt ?? this.updatedAt,
      sinopse: sinopse ?? this.sinopse,
      source: source ?? this.source,
      isDublado: isDublado ?? this.isDublado,
      isFavorite: isFavorite ?? this.isFavorite,
      slugSerie: slugSerie ?? this.slugSerie,
      url: url ?? this.url,
      title: title ?? this.title,
      originalImage: originalImage ?? this.originalImage,
      extraLarge: extraLarge ?? this.extraLarge,
      largeImage: largeImage ?? this.largeImage,
      mediumImage: mediumImage ?? this.mediumImage,
      generateID: generateID ?? this.generateID,
      totalOfEpisodes: totalOfEpisodes ?? this.totalOfEpisodes,
      totalOfPages: totalOfPages ?? this.totalOfPages,
    );
    entity.episodes = episodes;
    entity.animeSkip = animeSkip;

    return entity;
  }
}
