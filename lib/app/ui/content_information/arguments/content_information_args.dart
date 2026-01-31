// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';

class ContentInformationArgs extends Equatable {
  final Content content;
  final bool getData;
  final bool isLibrary;
  final bool isHistoric;
  const ContentInformationArgs({
    required this.content,
    this.getData = true,
    this.isLibrary = false,
    this.isHistoric = false,
  });

  @override
  List<Object?> get props => [content, isLibrary, getData, isHistoric];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contentType': content is Anime ? "anime" : "book",
      'content': content.toJson(),
      'getData': getData,
      'isLibrary': isLibrary,
      'isHistoric': isHistoric,
    };
  }

  factory ContentInformationArgs.fromMap(Map<String, dynamic> map) {
    return ContentInformationArgs(
      content: map["contentType"] == "anime"
          ? AnimeMapper.fromMap(map['content'] as Map<String, dynamic>)
          : BookMapper.fromMap(map['content'] as Map<String, dynamic>),
      getData: map['getData'] as bool,
      isLibrary: map['isLibrary'] as bool,
      isHistoric: map['isHistoric'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContentInformationArgs.fromJson(String source) =>
      ContentInformationArgs.fromMap(json.decode(source) as Map<String, dynamic>);
}
