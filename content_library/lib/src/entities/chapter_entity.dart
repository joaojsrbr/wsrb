import 'package:content_library/src/entities/entity.dart';

import 'package:isar/isar.dart';

part 'chapter_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode'})
class ChapterEntity extends HistoryEntity {
  double readPercent;

  @Index(replace: true, unique: true)
  String stringID;
  String animeStringID;

  DateTime? createdAt;
  DateTime? updatedAt;

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
}
