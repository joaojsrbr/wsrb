import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

part 'book_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'toBook'})
class BookEntity extends Entity {
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

  @override
  String get imageUrl =>
      extraLarge ?? largeImage ?? mediumImage ?? originalImage;

  @override
  List<Object?> get props => [
        title,
        url,
        sinopse,
        source,
        alternativeTitle,
        extraLarge,
        originalImage,
        largeImage,
        mediumImage,
        chapters,
        isFavorite,
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
