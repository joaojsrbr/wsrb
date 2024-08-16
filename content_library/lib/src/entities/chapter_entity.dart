import 'package:content_library/src/entities/entity.dart';
import 'package:content_library/src/models/chapter.dart';
import 'package:isar/isar.dart';

part 'chapter_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'toChapter'})
class ChapterEntity extends HistoryEntity {
  double readPercent;

  @Index(replace: true, unique: true)
  String stringID;
  String animeStringID;
  String title;

  DateTime? createdAt;
  DateTime? updatedAt;
  String url;
  bool isComplete;

  @override
  List<Object?> get props => [
        readPercent,
        stringID,
        isComplete,
        createdAt,
        updatedAt,
      ];

  ChapterEntity({
    required this.readPercent,
    required this.stringID,
    required this.animeStringID,
    required this.url,
    required this.title,
    this.createdAt,
    this.updatedAt,
    this.isComplete = false,
  });

  @override
  int compareTo(HistoryEntity other) {
    if (createdAt != null && (other as ChapterEntity).createdAt != null) {
      return createdAt!.compareTo(other.createdAt!);
    }
    return -1;
  }

  Chapter get toChapter {
    return Chapter(
      read: isComplete,
      title: title,
      url: url,
      animeStringID: animeStringID,
    );
  }
}
