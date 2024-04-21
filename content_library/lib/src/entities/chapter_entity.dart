import 'package:content_library/src/entities/entity.dart';
import 'package:isar/isar.dart';

part 'chapter_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode'})
class ChapterEntity extends Entity {
  double readPercent;

  @Index(replace: true, unique: true)
  String stringID;

  DateTime? createdAt;
  DateTime? updatedAt;

  bool isComplete;

  @override
  List<Object?> get props => [
        readPercent,
        stringID,
        isComplete,
      ];

  ChapterEntity({
    required this.readPercent,
    required this.stringID,
    this.createdAt,
    this.updatedAt,
    this.isComplete = false,
  });

  @override
  String get imageUrl => '';
}
