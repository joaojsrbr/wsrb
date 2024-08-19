// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';

class ContentInformationArgs extends Equatable {
  final Content content;
  final bool getData;

  const ContentInformationArgs({
    required this.content,
    this.getData = true,
  });

  @override
  List<Object?> get props => [content];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': content is Anime ? 'anime' : 'book',
      'content': content.toJson(),
      'getData': getData,
    };
  }

  factory ContentInformationArgs.fromMap(Map<String, dynamic> map) {
    return ContentInformationArgs(
      content: map['type'] == 'anime'
          ? Anime.fromMap(map['content'])
          : Book.fromMap(map['content']),
      getData: map['getData'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContentInformationArgs.fromJson(String source) =>
      ContentInformationArgs.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
