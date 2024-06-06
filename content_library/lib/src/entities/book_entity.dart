import 'package:content_library/src/constants/source.dart';
import 'package:content_library/src/entities/chapter_entity.dart';
import 'package:content_library/src/entities/entity.dart';
import 'package:content_library/src/models/book.dart';

import 'package:content_library/src/utils/releases.dart';
import 'package:isar/isar.dart';
part 'book_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'toBook'})
class BookEntity extends ContentEntity {
  @Index(replace: true, unique: true)
  String stringID;
  String title;
  String url;
  DateTime? createdAt;
  DateTime? updatedAt;

  @enumerated
  Source source;
  String? sinopse;
  String? alternativeTitle;
  bool isFavorite;
  String originalImage;
  String? extraLarge;
  String? largeImage;
  String? mediumImage;

  final IsarLinks<ChapterEntity> chapters = IsarLinks<ChapterEntity>();

  BookEntity({
    required this.stringID,
    required this.title,
    required this.url,
    required this.source,
    required this.originalImage,
    this.createdAt,
    this.sinopse,
    this.updatedAt,
    this.alternativeTitle,
    this.extraLarge,
    this.largeImage,
    this.mediumImage,
    this.isFavorite = false,
  });

  String get imageUrl =>
      extraLarge ?? largeImage ?? mediumImage ?? originalImage;

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

  Book get toBook {
    return Book(
      sinopse: sinopse,
      source: source,
      url: url,
      title: title,
      releases: Releases(),
      extraLarge: extraLarge,
      largeImage: largeImage,
      mediumImage: mediumImage,
      originalImage: originalImage,
    );
  }
}
