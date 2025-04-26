// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable

import 'package:content_library/src/entities/entity.dart';
import 'package:content_library/src/models/chapter.dart';
import 'package:isar/isar.dart';

part 'chapter_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'toChapter'})
class ChapterEntity extends HistoryEntity {
  final double readPercent;

  @Index(replace: true, unique: true)
  final String stringID;
  final String bookStringID;
  final String title;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String url;
  @override
  final bool isComplete;

  @override
  final double percent;

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
    required this.bookStringID,
    required this.url,
    required this.title,
    this.createdAt,
    this.updatedAt,
    this.percent = 0.0,
    this.isComplete = false,
  });

  @override
  int compareTo(HistoryEntity other) {
    if (createdAt != null && (other as ChapterEntity).createdAt != null) {
      return createdAt!.compareTo(other.createdAt!);
    }
    return -1;
  }

  Chapter toChapter() {
    return Chapter(
      read: isComplete,
      title: title,
      url: url,
      bookStringID: bookStringID,
    );
  }

  ChapterEntity copyWith({
    double? readPercent,
    String? stringID,
    String? bookStringID,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? url,
    bool? isComplete,
    double? percent,
  }) {
    return ChapterEntity(
      readPercent: readPercent ?? this.readPercent,
      stringID: stringID ?? this.stringID,
      bookStringID: bookStringID ?? this.bookStringID,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      url: url ?? this.url,
      isComplete: isComplete ?? this.isComplete,
      percent: percent ?? this.percent,
    );
  }
}
