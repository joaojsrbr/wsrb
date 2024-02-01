// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Chapter extends Equatable {
  final bool read;

  final String url;

  final String chapterName;

  String get id => const Uuid().v5(Uuid.NAMESPACE_URL, url);

  const Chapter({
    this.read = false,
    required this.url,
    required this.chapterName,
  });

  String get number {
    final rgx = RegExp(r'Cap.+[0-9].-');
    final rgx2 = RegExp(r'Cap.+[0-9]');

    final match =
        rgx.stringMatch(chapterName) ?? rgx2.stringMatch(chapterName) ?? '';

    return match
        .replaceAll(RegExp(r'\([0-9]\)|\(\)|\([0-9]'), '')
        .replaceFirst('-', '')
        .replaceAll(RegExp('[^0-9]'), '')
        .trim();
  }

  @override
  List<Object?> get props => [chapterName, url, read, id];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'read': read,
      'url': url,
      'chapterName': chapterName,
    };
  }

  factory Chapter.fromMap(Map<dynamic, dynamic> map) {
    return Chapter(
      read: map['read'] as bool,
      url: map['url'] as String,
      chapterName: map['chapterName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Chapter.fromJson(String source) =>
      Chapter.fromMap(json.decode(source) as Map<String, dynamic>);
}
