import 'package:content_library/src/constants/source.dart';
import 'package:content_library/src/entities/anime_entity.dart';
import 'package:content_library/src/models/content.dart';
import 'package:content_library/src/models/genre.dart';
import 'package:content_library/src/utils/object_utils.dart';
import 'package:content_library/src/utils/releases.dart';

class Anime extends Content with MergeClass<Content> {
  const Anime({
    required super.url,
    required super.title,
    required EpisodeReleases releases,
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
  }) : super(releases);

  @override
  EpisodeReleases get releases => super.releases as EpisodeReleases;

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
          ? releases.firstOrNull?.thumbnail ?? ''
          : originalImage,
    );
  }

  @override
  String get imageUrl =>
      extraLarge ?? largeImage ?? mediumImage ?? originalImage;

  factory Anime.fromMap(Map<String, dynamic> map) {
    return Anime(
      title: map['title'],
      url: map['url'],
      releases: map['releases'],
      genres: map['genres'],
      generateID: map['generateID'],
      animeID: map['animeID'],
      source: map['source'],
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
  Map<String, dynamic> get map => {
        ...super.map,
        "genres": genres,
        "generateID": generateID,
        "animeID": animeID,
        "source": source,
        "extraLarge": extraLarge,
        "originalImage": originalImage,
        "largeImage": largeImage,
        "mediumImage": mediumImage,
        "slugSerie": slugSerie,
        "isDublado": isDublado,
        "totalOfEpisodes": totalOfEpisodes,
        "totalOfPages": totalOfPages,
      };
}
