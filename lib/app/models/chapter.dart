// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:app_wsrb_jsr/app/models/data_content.dart';

class Chapter extends DataContent implements Comparable<Chapter> {
  final bool read;

  const Chapter({
    this.read = false,
    required super.url,
    required super.title,
  });

  @override
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
  List<Object?> get props => [title, url, read, id];

  @override
  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'read': read,
      'url': url,
      'title': title,
    };
  }

  factory Chapter.fromMap(Map<dynamic, dynamic> map) {
    return Chapter(
      read: map['read'] as bool,
      url: map['url'] as String,
      title: map['title'] as String,
    );
  }

  @override
  int compareTo(Chapter other) {
    return number.compareTo(other.number);
  }
}
