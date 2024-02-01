// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/color_scheme_extensions.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/models/data_content.dart';
import 'package:app_wsrb_jsr/app/models/episode.dart';
import 'package:flutter/material.dart';

import 'package:app_wsrb_jsr/app/core/constants/source.dart';
import 'package:app_wsrb_jsr/app/models/chapter.dart';
import 'package:app_wsrb_jsr/app/models/genre.dart';

class Book extends Content {
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
  final String? largeImage;
  final String? mediumImage;

  const Book({
    super.contentColorScheme,
    super.allDataContent,
    required super.title,
    required this.source,
    required this.originalImage,
    required super.url,
    this.genres = const [],
    this.alternativeTitle,
    super.sinopse,
    this.extraLarge,
    this.type,
    this.authors = const [],
    this.score,
    this.status,
    this.largeImage,
    this.mediumImage,
    this.artists = const [],
  });

  @override
  String get imageUrl =>
      extraLarge ?? largeImage ?? mediumImage ?? originalImage;

  bool get searchNewImage {
    if ([extraLarge, largeImage, mediumImage].contains(null)) {
      return true;
    }
    return false;
  }

  @override
  List<Object?> get props => [
        id,
        url,
        title,
        status,
        genres,
        authors,
        artists,
        type,
        extraLarge,
        largeImage,
        mediumImage,
        originalImage,
        alternativeTitle,
        contentColorScheme,
        allDataContent,
      ];

  // bool get isNovel {
  //   for(final ChapterContent content in chapters.where((element) => element)){
  //     if(content is TextChapterContent) return true;
  //     continue;
  //   }
  // }

  @override
  Book copyWith({
    AllDataContent? allDataContent,
    ColorScheme? contentColorScheme,
    String? title,
    String? url,
    String? originalImage,
    Source? source,
    List<Genre>? genres,
    List<String>? authors,
    List<String>? artists,
    double? score,
    String? largeImage,
    String? extraLarge,
    String? type,
    String? sinopse,
    String? alternativeTitle,
    String? status,
    String? mediumImage,
  }) {
    return Book(
      allDataContent: allDataContent ?? this.allDataContent,
      contentColorScheme: contentColorScheme ?? this.contentColorScheme,
      type: type ?? this.type,
      extraLarge: extraLarge ?? this.extraLarge,
      title: title ?? this.title,
      url: url ?? this.url,
      alternativeTitle: alternativeTitle ?? this.alternativeTitle,
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

  @override
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
      'allDataContent': allDataContent.map((x) => x.toMap).toList(),
      'contentColorScheme': contentColorScheme?.toMap,
    };
  }

  factory Book.fromMap(Map<dynamic, dynamic> map) {
    const AllDataContent allDataContent = AllDataContent();

    final allDataContentMap = map['allDataContent'] as List<dynamic>;

    for (final contentMap in allDataContentMap) {
      DataContent dataContent;
      try {
        dataContent = Chapter.fromMap(contentMap);
      } catch (_) {
        dataContent = Episode.fromMap(contentMap);
      }
      allDataContent.add(dataContent);
    }

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
      allDataContent: allDataContent,
      contentColorScheme: map['contentColorScheme'] != null
          ? ColorSchemeExtensions.fromMap(map['contentColorScheme'])
          : null,
    );
  }
}
