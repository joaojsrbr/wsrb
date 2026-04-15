// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable

import 'package:content_library/content_library.dart';
import 'package:content_library/src/models/anilist_media.dart';
import 'package:content_library/src/models/book.dart';
import 'package:content_library/src/models/chapter_entity.dart';
import 'package:content_library/src/models/entity.dart';
import 'package:content_library/src/utils/releases.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:isar/isar.dart';

part 'generated/book_entity.g.dart';
part 'generated/book_entity.mapper.dart';

@MappableClass()
@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'toBook', 'map'})
class BookEntity extends ContentEntity with BookEntityMappable {
  final String? alternativeTitle;
  final String originalImage;
  final String? extraLarge;
  final String? largeImage;
  final String? mediumImage;

  IsarLinks<ChapterEntity> chapters = IsarLinks<ChapterEntity>();

  // @override
  // BookEntityCopyWith<BookEntity, BookEntity, BookEntity> get copyWith {
  //   return super.copyWith.$update((r) {
  //     r.chapters = chapters;
  //     return r;
  //   }).copyWith;
  // }

  @override
  @enumerated
  Source get source => super.source;

  BookEntity({
    super.id,
    required super.stringID,
    required super.title,
    required super.url,
    required super.source,
    required this.originalImage,
    super.createdAt,
    super.anilistMedia,
    super.sinopse,
    super.updatedAt,
    super.isMovie = false,
    this.alternativeTitle,
    super.newReleases,
    this.extraLarge,
    this.largeImage,
    this.mediumImage,
    super.isFavorite = false,
  });

  @override
  String get imageUrl => extraLarge ?? largeImage ?? mediumImage ?? originalImage;

  @override
  List<Object?> get props => [
    stringID,
    title,
    url,
    createdAt,
    updatedAt,
    source,
    sinopse,
    alternativeTitle,
    isFavorite,
    originalImage,
    extraLarge,
    largeImage,
    mediumImage,
    chapters,
  ];

  void addChapter(ChapterEntity entity) {
    chapters.add(entity);
  }

  Future<void> saveChapter() async => await chapters.save();

  @override
  Book toContent() {
    return Book(
      anilistMedia: anilistMedia,
      sinopse: sinopse ?? "",
      source: source,
      url: url,
      title: title,
      releases: ChapterReleases.from(chapters.map((entity) => entity.toChapter())),
      extraLarge: extraLarge,
      largeImage: largeImage,
      mediumImage: mediumImage,
      originalImage: originalImage,
    );
  }

  // @override
  // BookEntity copyWith({
  //   AniListMedia? anilistMedia,
  //   List<String>? newReleases,
  //   bool? isFavorite,
  //   String? title,
  //   String? url,
  //   DateTime? createdAt,
  //   DateTime? updatedAt,
  //   Source? source,
  //   String? sinopse,
  //   String? alternativeTitle,
  //   String? originalImage,
  //   String? extraLarge,
  //   String? stringID,
  //   String? largeImage,
  //   String? mediumImage,
  // }) {
  //   final entity = BookEntity(
  //     anilistMedia: anilistMedia ?? this.anilistMedia,
  //     newReleases: newReleases ?? this.newReleases,
  //     title: title ?? this.title,
  //     url: url ?? this.url,
  //     createdAt: createdAt ?? this.createdAt,
  //     updatedAt: updatedAt ?? this.updatedAt,
  //     source: source ?? this.source,
  //     stringID: stringID ?? this.stringID,
  //     sinopse: sinopse ?? this.sinopse,
  //     alternativeTitle: alternativeTitle ?? this.alternativeTitle,
  //     isFavorite: isFavorite ?? this.isFavorite,
  //     originalImage: originalImage ?? this.originalImage,
  //     extraLarge: extraLarge ?? this.extraLarge,
  //     largeImage: largeImage ?? this.largeImage,
  //     mediumImage: mediumImage ?? this.mediumImage,
  //   );

  //   entity.chapters = chapters;
  //   return entity;
  // }
}
