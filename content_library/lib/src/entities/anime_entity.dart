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
  IsarLinks<EpisodeEntity> episodes = IsarLinks<EpisodeEntity>();
  IsarLink<AnimeSkipEntity> animeSkip = IsarLink<AnimeSkipEntity>();

  // AnilistMedia? get aniList {
  //   return anilistMedia != null
  //       ? AnilistMedia.fromJson(jsonDecode(anilistMedia!))
  //       : null;
  // }

  AniListMedia? anilistMedia;
  DateTime? createdAt;
  String? animeID;
  DateTime? updatedAt;
  String? sinopse;
  @enumerated
  Source source;
  bool isDublado;
  bool isFavorite;
  String? slugSerie;
  String url;
  String title;
  String originalImage;
  String? extraLarge;
  String? largeImage;
  String? mediumImage;
  String? generateID;
  int? totalOfEpisodes;
  int? totalOfPages;

  AnimeEntity({
    required super.stringID,
    required this.url,
    required this.totalOfEpisodes,
    required this.title,
    required this.source,
    this.anilistMedia,
    this.createdAt,
    this.animeID,
    this.totalOfPages,
    this.isDublado = false,
    this.slugSerie,
    this.updatedAt,
    this.sinopse,
    this.generateID,
    this.isFavorite = false,
    required this.originalImage,
    this.extraLarge,
    this.largeImage,
    this.mediumImage,
  });

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

  Anime get toAnime {
    return Anime(
      anilistMedia: anilistMedia,
      url: url,
      totalOfPages: totalOfPages,
      animeID: animeID,
      title: title,
      generateID: generateID,
      animeSkip: animeSkip.value?.toObj,
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
}
