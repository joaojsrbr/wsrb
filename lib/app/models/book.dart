// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/color_scheme_extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:app_wsrb_jsr/app/core/constants/source.dart';
import 'package:app_wsrb_jsr/app/models/chapter.dart';
import 'package:app_wsrb_jsr/app/models/genre.dart';

class Book extends Equatable {
  final String title;
  final String url;
  final String originalImage;
  final Source source;
  final String? alternativeTitle;
  final List<Genre> genres;
  final List<String> authors;
  final List<String> artists;
  final double? score;
  final String? status;
  final String? extraLarge;
  final String? type;
  final String? sinopse;
  final String? largeImage;
  final String? mediumImage;
  final List<Chapter> chapters;
  final ColorScheme? bookColorScheme;

  const Book({
    required this.title,
    required this.source,
    required this.originalImage,
    required this.url,
    this.chapters = const [],
    this.genres = const [],
    this.alternativeTitle,
    this.bookColorScheme,
    this.sinopse,
    this.extraLarge,
    this.type,
    this.authors = const [],
    this.score,
    this.status,
    this.largeImage,
    this.mediumImage,
    this.artists = const [],
  });

  String get img => extraLarge ?? largeImage ?? mediumImage ?? originalImage;

  bool get searchNewImage {
    if ([extraLarge, largeImage, mediumImage].contains(null)) {
      return true;
    }
    return false;
  }

  String get id => const Uuid().v5(Uuid.NAMESPACE_URL, url);

  @override
  List<Object?> get props => [
        id,
        url,
        title,
        status,
        genres,
        chapters,
        authors,
        artists,
        type,
        extraLarge,
        largeImage,
        mediumImage,
        originalImage,
        alternativeTitle,
      ];

  // bool get isNovel {
  //   for(final ChapterContent content in chapters.where((element) => element)){
  //     if(content is TextChapterContent) return true;
  //     continue;
  //   }
  // }

  Book copyWith({
    String? title,
    String? url,
    String? originalImage,
    Source? source,
    List<Genre>? genres,
    List<String>? authors,
    List<Chapter>? chapters,
    List<String>? artists,
    double? score,
    String? largeImage,
    String? extraLarge,
    String? type,
    String? sinopse,
    String? alternativeTitle,
    String? status,
    String? mediumImage,
    ColorScheme? bookColorScheme,
  }) {
    return Book(
      bookColorScheme: bookColorScheme ?? this.bookColorScheme,
      type: type ?? this.type,
      extraLarge: extraLarge ?? this.extraLarge,
      title: title ?? this.title,
      url: url ?? this.url,
      alternativeTitle: alternativeTitle ?? this.alternativeTitle,
      chapters: chapters ?? this.chapters,
      originalImage: originalImage ?? this.originalImage,
      source: source ?? this.source,
      sinopse: sinopse ?? this.sinopse,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      authors: authors ?? this.authors,
      artists: artists ?? this.artists,
      score: score ?? this.score,
      largeImage: largeImage ?? this.largeImage,
      mediumImage: mediumImage ?? this.mediumImage,
    );
  }

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'title': title,
      'url': url,
      'originalImage': originalImage,
      'source': source.index,
      'alternativeTitle': alternativeTitle,
      'genres': genres.map((x) => x.toMap()).toList(),
      'authors': authors,
      'artists': artists,
      'score': score,
      'status': status,
      'extraLarge': extraLarge,
      'type': type,
      'sinopse': sinopse,
      'largeImage': largeImage,
      'mediumImage': mediumImage,
      'chapters': chapters.map((x) => x.toMap()).toList(),
      'bookColorScheme': bookColorScheme?.toMap,
    };
  }

  factory Book.fromMap(Map<dynamic, dynamic> map) {
    return Book(
      title: map['title'] as String,
      url: map['url'] as String,
      originalImage: map['originalImage'] as String,
      source: Source.values.elementAt(map['source'] as int),
      alternativeTitle: map['alternativeTitle'] != null
          ? map['alternativeTitle'] as String
          : null,
      genres: (map['genres'] as List<dynamic>)
          .map<Genre>((x) => Genre.fromMap(x))
          .toList(),
      authors: List<String>.from((map['authors'] as List<String>)),
      artists: List<String>.from((map['artists'] as List<String>)),
      score: map['score'] != null ? map['score'] as double : null,
      status: map['status'] != null ? map['status'] as String : null,
      extraLarge:
          map['extraLarge'] != null ? map['extraLarge'] as String : null,
      type: map['type'] != null ? map['type'] as String : null,
      sinopse: map['sinopse'] != null ? map['sinopse'] as String : null,
      largeImage:
          map['largeImage'] != null ? map['largeImage'] as String : null,
      mediumImage:
          map['mediumImage'] != null ? map['mediumImage'] as String : null,
      chapters: List<Chapter>.from(
        (map['chapters'] as List<dynamic>).map<Chapter>(
          (x) => Chapter.fromMap(x),
        ),
      ),
      bookColorScheme: map['bookColorScheme'] != null
          ? ColorSchemeExtensions.fromMap(map['bookColorScheme'])
          : null,
    );
  }

  String get toJson => json.encode(toMap);

  factory Book.fromJson(String source) => Book.fromMap(json.decode(source));
}
