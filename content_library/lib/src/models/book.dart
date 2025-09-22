// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_library/content_library.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'generated/book.mapper.dart';

@MappableClass()
class Book extends Content with BookMappable {
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
    this.artists = const [],
  }) : super(releases);

  @override
  ChapterReleases get releases => super.releases as ChapterReleases;

  @override
  String get imageUrl => extraLarge ?? largeImage ?? mediumImage ?? originalImage;

  bool get searchNewImage => [extraLarge, largeImage, mediumImage].contains(null);

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
      releases.map((chapter) => chapter.toEntity(0.0, createdAt, updatedAt)),
    );

    return book;
  }
}
