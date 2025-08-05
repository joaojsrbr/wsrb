// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable

import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

part 'chapter_entity.g.dart';

@Collection(ignore: {'props', 'imageUrl', 'stringify', 'hashCode', 'toChapter'})
class ChapterEntity extends HistoricEntity {
  final double readPercent;

  @Index(replace: true, unique: true)
  final String stringID;
  final String bookStringID;

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
    required super.url,
    required super.title,
    super.createdAt,
    super.updatedAt,
    super.percent = 0.0,
    super.isComplete = false,
    super.positions = const [],
  });

  @override
  int compareTo(HistoricEntity other) {
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

  @override
  ChapterEntity copyWith({
    List<CurrentPosition>? positions,
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
      positions: positions ?? this.positions,
    );
  }
}
