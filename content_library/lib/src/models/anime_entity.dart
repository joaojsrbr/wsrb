// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable

import 'package:content_library/src/constants/source.dart';
import 'package:content_library/src/models/anilist_media.dart';
import 'package:content_library/src/models/anime.dart';
import 'package:content_library/src/models/anime_skip_entity.dart';
import 'package:content_library/src/models/entity.dart';
import 'package:content_library/src/models/episode_entity.dart';
import 'package:content_library/src/utils/releases.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:isar/isar.dart';

part 'generated/anime_entity.g.dart';
part 'generated/anime_entity.mapper.dart';

@MappableClass()
@Collection(
  ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'toAnime', 'map', 'aniList'},
)
class AnimeEntity extends ContentEntity with AnimeEntityMappable {
  final String? animeID;
  final bool isDublado;
  final String? slugSerie;
  final String originalImage;
  final String? extraLarge;
  final String? largeImage;
  final String? mediumImage;
  final String? generateID;
  final int? totalOfEpisodes;
  final int? totalOfPages;
  final IsarLinks<EpisodeEntity> episodes;

  // @override
  // AnimeEntityCopyWith<AnimeEntity, AnimeEntity, AnimeEntity> get copyWith {
  //   return super.copyWith().$update((r) {
  //     r.episodes = episodes;
  //     r.animeSkip = animeSkip;
  //     return r;
  //   }).copyWith;
  // }

  @override
  @enumerated
  Source get source => super.source;

  AnimeEntity({
    super.id,
    required super.stringID,
    required super.url,
    required super.title,
    required super.source,
    super.anilistMedia,
    super.newReleases,
    super.createdAt,
    this.totalOfEpisodes,
    this.animeID,
    this.totalOfPages,
    this.isDublado = false,
    this.slugSerie,
    super.updatedAt,
    super.sinopse,
    this.generateID,
    super.isFavorite = false,
    required this.originalImage,
    this.extraLarge,
    this.largeImage,
    this.mediumImage,
  }) : episodes = IsarLinks<EpisodeEntity>();

  @override
  String get imageUrl => extraLarge ?? largeImage ?? mediumImage ?? originalImage;

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

    mediumImage,
    generateID,
    totalOfEpisodes,
  ];

  void addEpisode(EpisodeEntity entity) {
    episodes.add(entity);
  }

  Future<void> saveEpisode() async => await episodes.save();

  @override
  Anime toContent() {
    return Anime(
      anilistMedia: anilistMedia,
      url: url,
      totalOfPages: totalOfPages,
      animeID: animeID,
      title: title,
      generateID: generateID,

      totalOfEpisodes: totalOfEpisodes,
      slugSerie: slugSerie,
      source: source,
      sinopse: sinopse ?? "",
      releases: EpisodeReleases.from(
        episodes.map((entity) => entity.toEpisode(isDublado)).toList(),
      ),
      originalImage: originalImage,
      extraLarge: extraLarge,
      largeImage: largeImage,
      mediumImage: mediumImage,
    );
  }

  // @override
  // AnimeEntity copyWith({
  //   AniListMedia? anilistMedia,
  //   DateTime? createdAt,
  //   String? animeID,
  //   DateTime? updatedAt,
  //   String? sinopse,
  //   Source? source,
  //   bool? isDublado,
  //   bool? isFavorite,
  //   String? slugSerie,
  //   String? url,
  //   String? title,
  //   String? originalImage,
  //   String? extraLarge,
  //   String? largeImage,
  //   String? stringID,
  //   String? mediumImage,
  //   String? generateID,
  //   int? totalOfEpisodes,
  //   int? totalOfPages,
  //   List<String>? newReleases,
  // }) {
  //   final entity = AnimeEntity(
  //     stringID: stringID ?? this.stringID,
  //     newReleases: newReleases ?? this.newReleases,
  //     anilistMedia: anilistMedia ?? this.anilistMedia,
  //     createdAt: createdAt ?? this.createdAt,
  //     animeID: animeID ?? this.animeID,
  //     updatedAt: updatedAt ?? this.updatedAt,
  //     sinopse: sinopse ?? this.sinopse,
  //     source: source ?? this.source,
  //     isDublado: isDublado ?? this.isDublado,
  //     isFavorite: isFavorite ?? this.isFavorite,
  //     slugSerie: slugSerie ?? this.slugSerie,
  //     url: url ?? this.url,
  //     title: title ?? this.title,
  //     originalImage: originalImage ?? this.originalImage,
  //     extraLarge: extraLarge ?? this.extraLarge,
  //     largeImage: largeImage ?? this.largeImage,
  //     mediumImage: mediumImage ?? this.mediumImage,
  //     generateID: generateID ?? this.generateID,
  //     totalOfEpisodes: totalOfEpisodes ?? this.totalOfEpisodes,
  //     totalOfPages: totalOfPages ?? this.totalOfPages,
  //   );
  //   entity.episodes = episodes;
  //   entity.animeSkip = animeSkip;

  //   return entity;
  // }
}
