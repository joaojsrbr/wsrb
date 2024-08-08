// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'release.dart';

class Chapter extends Release {
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
  List<Object?> get props => [title, url, read, stringID];

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'title': title,
      'url': url,
      'read': read,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      title: map['title'] as String,
      url: map['url'] as String,
      read: map['read'] as bool,
    );
  }
}
