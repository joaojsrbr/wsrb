import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

part 'anime_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'toAnime'})
class AnimeEntity extends Entity {
  @Index(replace: true, unique: true)
  String stringID;

  final IsarLinks<EpisodeEntity> episodes = IsarLinks<EpisodeEntity>();

  DateTime? createdAt;
  String? sinopse;
  DateTime? updatedAt;
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

  @override
  String get imageUrl =>
      extraLarge ?? largeImage ?? mediumImage ?? originalImage;

  @override
  List<Object?> get props => [
        stringID,
        generateID,
        title,
        sinopse,
        episodes,
        url,
        slugSerie,
        isFavorite,
        originalImage,
        extraLarge,
        largeImage,
        mediumImage,
      ];

  Anime get toAnime {
    return Anime(
      url: url,
      title: title,
      generateID: generateID,
      slugSerie: slugSerie,
      source: source,
      sinopse: sinopse,
      releases: Releases(),
      originalImage: originalImage,
      extraLarge: extraLarge,
      largeImage: largeImage,
      mediumImage: mediumImage,
    );
  }
}
