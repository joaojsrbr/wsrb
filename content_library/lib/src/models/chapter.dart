// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_library/content_library.dart';

class Chapter extends Release {
  final bool read;
  final String bookStringID;

  const Chapter({
    this.read = false,
    required super.url,
    required this.bookStringID,
    required super.title,
  });

  String get number {
    final rgx = RegExp(r'Cap.+[0-9].-');
    final rgx2 = RegExp(r'Cap.+[0-9]');

    final match = rgx.stringMatch(title) ?? rgx2.stringMatch(title) ?? '';

    return match
        .replaceAll(RegExp(r'\([0-9]\)|\(\)|\([0-9]'), '')
        .replaceFirst('-', '')
        .replaceAll(RegExp('[^0-9]'), '')
        .trim();
  }

  @override
  List<Object?> get props => [title, url, read, stringID, bookStringID];

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'title': title,
      'url': url,
      'read': read,
      'bookStringID': bookStringID,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      title: map['title'] as String,
      bookStringID: map['bookStringID'] as String,
      url: map['url'] as String,
      read: map['read'] as bool,
    );
  }

  ChapterEntity toEntity(
    double readPercent,
    DateTime? createdAt,
    DateTime? updatedAt, [
    bool isComplete = false,
  ]) {
    return ChapterEntity(
      url: url,
      title: title,
      bookStringID: bookStringID,
      readPercent: readPercent,
      stringID: stringID,
      isComplete: isComplete,
    );
  }
}
