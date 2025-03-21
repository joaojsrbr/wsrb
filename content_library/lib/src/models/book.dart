// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_library/content_library.dart';
import 'package:content_library/src/entities/anilist_media.dart';

class Book extends Content {
  final String? alternativeTitle;
  final List<String> authors;
  final List<String> artists;
  final double? score;
  final String? status;
  final String? type;
  final String? extraLarge;
  final String originalImage;
  final String? largeImage;
  final String? mediumImage;
  final String? bookId;
  final String? slugId;
  final bool nsfw;

  const Book({
    super.anilistMedia,
    required ChapterReleases releases,
    required super.title,
    required super.source,
    required this.originalImage,
    required super.url,
    super.genres,
    this.alternativeTitle,
    super.sinopse,
    this.extraLarge,
    this.nsfw = false,
    this.bookId,
    this.slugId,
    this.type,
    this.authors = const [],
    this.score,
    this.status,
    this.largeImage,
    this.mediumImage,
    super.cached,
    this.artists = const [],
  }) : super(releases);

  @override
  ChapterReleases get releases => super.releases as ChapterReleases;

  @override
  String get imageUrl =>
      extraLarge ?? largeImage ?? mediumImage ?? originalImage;

  bool get searchNewImage {
    if ([extraLarge, largeImage, mediumImage].contains(null)) {
      return true;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'class': 'BOOK',
        "stringID": stringID,
        "source": source,
        "bookId": bookId,
        "nsfw": nsfw,
        "slugId": slugId,
        "originalImage": originalImage,
        "genres": genres,
        "alternativeTitle": alternativeTitle,
        "extraLarge": extraLarge,
        "type": type,
        "authors": authors,
        "score": score,
        "status": status,
        "largeImage": largeImage,
        "mediumImage": mediumImage,
        "artists": artists,
      };

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      anilistMedia: map['anilistMedia'] != null
          ? AniListMedia.fromJson(map['anilistMedia'])
          : null,
      title: map['title'],
      bookId: map['bookId'],
      nsfw: map['nsfw'],
      slugId: map['slugId'],
      cached: map['cached'] ?? false,
      releases: map['releases'] is ChapterReleases
          ? map['releases']
          : ChapterReleases.from(
              (map['releases'] as List).map((e) => Chapter.fromMap(e)),
            ),
      source: map['source'],
      originalImage: map['originalImage'],
      url: map['url'],
      genres: map['genres'] != null
          ? (map['genres'] as List).map((e) => Genre(e)).toList()
          : [],
      alternativeTitle: map['alternativeTitle'],
      sinopse: map['sinopse'],
      extraLarge: map['extraLarge'],
      type: map['type'],
      authors: map['authors'],
      score: map['score'],
      status: map['status'],
      largeImage: map['largeImage'],
      mediumImage: map['mediumImage'],
      artists: map['artists'],
    );
  }

  @override
  Book copyWith({
    AniListMedia? anilistMedia,
    Releases? releases,
    String? title,
    String? url,
    bool? nsfw,
    String? bookId,
    String? slugId,
    String? originalImage,
    Source? source,
    bool? cached,
    List<Genre>? genres,
    List<String>? authors,
    List<String>? artists,
    double? score,
    String? largeImage,
    String? extraLarge,
    String? type,
    String? sinopse,
    String? alternativeTitle,
    String? status,
    String? mediumImage,
  }) {
    return Book(
      releases: ChapterReleases.from(releases ?? this.releases),
      cached: cached ?? this.cached,
      bookId: bookId ?? this.bookId,
      nsfw: nsfw ?? this.nsfw,
      slugId: slugId ?? this.slugId,
      type: type ?? this.type,
      anilistMedia: anilistMedia ?? this.anilistMedia,
      extraLarge: extraLarge ?? this.extraLarge,
      title: title ?? this.title,
      url: url ?? this.url,
      alternativeTitle: alternativeTitle ?? this.alternativeTitle,
      originalImage: originalImage ?? this.originalImage,
      source: source ?? this.source,
      sinopse: sinopse ?? this.sinopse,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      authors: authors ?? this.authors,
      artists: artists ?? this.artists,
      score: score ?? this.score,
      largeImage: largeImage ?? this.largeImage,
      mediumImage: mediumImage ?? this.mediumImage,
    );
  }

  @override
  BookEntity toEntity({
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite = false,
  }) {
    final book = BookEntity(
      sinopse: sinopse,
      anilistMedia: anilistMedia,
      stringID: stringID,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite,
      alternativeTitle: alternativeTitle,
      extraLarge: extraLarge,
      largeImage: largeImage,
      mediumImage: mediumImage,
      originalImage: originalImage,
      title: title,
      url: url,
      source: source,
    );

    book.chapters.addAll(
      releases.map(
        (chapter) => chapter.toEntity(
          0.0,
          createdAt,
          updatedAt,
        ),
      ),
    );

    return book;
  }
}
