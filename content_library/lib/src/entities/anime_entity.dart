import 'package:content_library/src/constants/source.dart';
import 'package:content_library/src/entities/entity.dart';
import 'package:content_library/src/entities/episode_entity.dart';
import 'package:content_library/src/models/anime.dart';
import 'package:content_library/src/utils/releases.dart';
import 'package:isar/isar.dart';

part 'anime_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'toAnime'})
class AnimeEntity extends ContentEntity {
  @Index(replace: true, unique: true)
  String stringID;

  IsarLinks<EpisodeEntity> episodes = IsarLinks<EpisodeEntity>();

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

  AnimeEntity({
    required this.stringID,
    required this.url,
    required this.title,
    required this.source,
    this.createdAt,
    this.animeID,
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
  Map<String, dynamic> get map => {
        "stringID": stringID,
        "animeID": animeID,
        "episodes": episodes,
        "createdAt": createdAt?.toString(),
        "updatedAt": updatedAt?.toString(),
        "sinopse": sinopse,
        "source": source,
        "isDublado": isDublado,
        "isFavorite": isFavorite,
        "slugSerie": slugSerie,
        "url": url,
        "title": title,
        "originalImage": originalImage,
        "extraLarge": extraLarge,
        "largeImage": largeImage,
        "mediumImage": mediumImage,
        "generateID": generateID,
      };

  @override
  List<Object?> get props => [
        animeID,
        stringID,
        episodes,
        createdAt,
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
      ];

  Anime get toAnime {
    return Anime(
      url: url,
      animeID: animeID,
      title: title,
      generateID: generateID,
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
