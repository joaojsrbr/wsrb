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
  IsarLinks<EpisodeEntity> episodes = IsarLinks<EpisodeEntity>();
  IsarLink<AnimeSkipEntity> animeSkip = IsarLink<AnimeSkipEntity>();

  // AnilistMedia? get aniList {
  //   return anilistMedia != null
  //       ? AnilistMedia.fromJson(jsonDecode(anilistMedia!))
  //       : null;
  // }

  final AniListMedia? anilistMedia;
  final DateTime? createdAt;
  final String? animeID;
  final DateTime? updatedAt;
  final String? sinopse;
  @enumerated
  final Source source;
  final bool isDublado;
  final bool isFavorite;
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

  AnimeEntity populeIfItWasCreated({
    AnimeEntity? other,
  }) {
    final entity = copyWith(
      // stringID: other?.stringID,
      // anilistMedia: other?.anilistMedia,
      createdAt: other?.createdAt,
      // animeID: other?.animeID,
      // updatedAt: other?.updatedAt,
      // sinopse: other?.sinopse,
      // source: other?.source,
      // isDublado: other?.isDublado,
      isFavorite: other?.isFavorite,
      // slugSerie: other?.slugSerie,
      // url: other?.url,
      // title: other?.title,
      // originalImage: other?.originalImage,
      // extraLarge: other?.extraLarge,
      // largeImage: other?.largeImage,
      // mediumImage: other?.mediumImage,
      // generateID: other?.generateID,
      // totalOfEpisodes: other?.totalOfEpisodes,
      // totalOfPages: other?.totalOfPages,
    );

    // if (other?.episodes != null) {
    //   entity.episodes = other!.episodes;
    // }
    // if (other?.animeSkip != null) {
    //   entity.animeSkip = other!.animeSkip;
    // }

    return entity;
  }

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
