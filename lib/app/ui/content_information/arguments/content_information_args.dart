// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ContentInformationArgs extends Equatable {
  final Content content;
  final bool getData;
  final bool isLibrary;
  const ContentInformationArgs({
    required this.content,
    this.getData = true,
    this.isLibrary = false,
  });

  @override
  List<Object?> get props => [content, isLibrary, getData];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contentType': content is Anime ? "anime" : "book",
      'content': content.toJson(),
      'getData': getData,
      'isLibrary': isLibrary,
    };
  }

  factory ContentInformationArgs.fromMap(Map<String, dynamic> map) {
    return ContentInformationArgs(
      content: map["contentType"] == "anime"
          ? AnimeMapper.fromMap(map['content'] as Map<String, dynamic>)
          : BookMapper.fromMap(map['content'] as Map<String, dynamic>),
      getData: map['getData'] as bool,
      isLibrary: map['isLibrary'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContentInformationArgs.fromJson(String source) =>
      ContentInformationArgs.fromMap(json.decode(source) as Map<String, dynamic>);
}

class RestorableContentInformationArgs extends RestorableValue<ContentInformationArgs> {
  RestorableContentInformationArgs()
    : _defaultValue = ContentInformationArgs(content: Anime.empty());

  final ContentInformationArgs _defaultValue;

  @override
  ContentInformationArgs createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(ContentInformationArgs? oldValue) {
    if (oldValue != null && oldValue != value) {
      notifyListeners();
    }
  }

  @override
  Object? toPrimitives() {
    return value.toJson();
  }

  @override
  ContentInformationArgs fromPrimitives(Object? data) {
    if (data == null) return _defaultValue;

    try {
      final Map<String, dynamic> decodedData =
          jsonDecode(data as String) as Map<String, dynamic>;

      return ContentInformationArgs.fromMap(decodedData);
    } catch (_) {}
    return _defaultValue;
  }
}
