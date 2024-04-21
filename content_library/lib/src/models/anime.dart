import 'package:content_library/content_library.dart';

class Anime extends Content {
  const Anime({
    required super.url,
    required super.title,
    required super.releases,
    required this.source,
    required this.originalImage,
    this.slugSerie,
    this.extraLarge,
    this.mediumImage,
    this.animeID,
    this.largeImage,
    this.generateID,
    this.isDublado = false,
    super.sinopse,
  });
  final String? generateID;
  final String? animeID;
  final Source source;
  final String? extraLarge;
  final String originalImage;
  final String? largeImage;
  final String? mediumImage;
  final String? slugSerie;
  final bool isDublado;

  @override
  List<Object?> get props => [
        title,
        url,
        source,
        sinopse,
        releases,
        slugSerie,
        isDublado,
        originalImage,
        extraLarge,
        generateID,
        largeImage,
        mediumImage,
        animeID,
        releases,
      ];

  @override
  String get imageUrl =>
      extraLarge ?? largeImage ?? mediumImage ?? originalImage;

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
    String? sinopse,
  }) {
    return Anime(
      source: source ?? this.source,
      generateID: generateID ?? this.generateID,
      animeID: animeID ?? this.animeID,
      originalImage: originalImage ?? this.originalImage,
      mediumImage: mediumImage ?? this.mediumImage,
      largeImage: largeImage ?? this.largeImage,
      extraLarge: extraLarge ?? this.extraLarge,
      sinopse: sinopse ?? this.sinopse,
      isDublado: isDublado ?? this.isDublado,
      slugSerie: slugSerie ?? this.slugSerie,
      releases: releases ?? this.releases,
      title: title ?? this.title,
      url: url ?? this.url,
    );
  }

  @override
  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'title': title,
      'source': source.index,
      'url': url,
      'isDublado': isDublado,
      'slugSerie': slugSerie,
      'generateID': generateID,
      'sinopse': sinopse,
      'releases': releases.map((x) => x.toMap).toList(),
      'extraLarge': extraLarge,
      'originalImage': originalImage,
      'largeImage': largeImage,
      'mediumImage': mediumImage,
    };
  }

  factory Anime.fromMap(Map<dynamic, dynamic> map) {
    final Releases releases = Releases();

    final releaseMap = map['releases'] as List<dynamic>;

    for (final contentMap in releaseMap) {
      try {
        releases.add(Episode.fromMap(contentMap));
      } catch (_) {
        customLog(contentMap, error: _);
      }
    }

    return Anime(
      source: Source.values.elementAt(map['source'] as int),
      isDublado: map['isDublado'] as bool,
      slugSerie: map['slugSerie'] != null ? map['slugSerie'] as String : null,
      originalImage: map['originalImage'] as String,
      extraLarge:
          map['extraLarge'] != null ? map['extraLarge'] as String : null,
      generateID:
          map['generateID'] != null ? map['generateID'] as String : null,
      largeImage:
          map['largeImage'] != null ? map['largeImage'] as String : null,
      mediumImage:
          map['mediumImage'] != null ? map['mediumImage'] as String : null,
      releases: releases,
      sinopse: map['sinopse'] != null ? map['sinopse'] as String : null,
      title: map['title'] as String,
      url: map['url'] as String,
    );
  }

  AnimeEntity toEntity({
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite = false,
  }) {
    return AnimeEntity(
      source: source,
      stringID: id,
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
          ? (releases.firstOrNull as Episode?)?.thumbnail ?? ''
          : originalImage,
    );
  }
}
