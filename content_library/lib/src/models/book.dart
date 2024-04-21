// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_library/src/entities/book_entity.dart';
import 'package:content_library/src/models/content.dart';

import '../constants/source.dart';
import '../utils/releases.dart';
import 'chapter.dart';
import 'genre.dart';

class Book extends Content {
  final Source source;
  final String? alternativeTitle;
  final List<Genre> genres;
  final List<String> authors;
  final List<String> artists;
  final double? score;
  final String? status;
  final String? type;
  final String? extraLarge;
  final String originalImage;
  final String? largeImage;
  final String? mediumImage;

  const Book({
    required super.releases,
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
        releases,
      ];

  @override
  Book copyWith({
    Releases? releases,
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
      releases: releases ?? this.releases,
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
      'source': source.index,
      'alternativeTitle': alternativeTitle,
      'genres': genres.map((x) => x.toMap).toList(),
      'authors': authors,
      'artists': artists,
      'score': score,
      'status': status,
      'type': type,
      'sinopse': sinopse,
      'releases': releases.map((x) => x.toMap).toList(),
      'extraLarge': extraLarge,
      'originalImage': originalImage,
      'largeImage': largeImage,
      'mediumImage': mediumImage,
    };
  }

  factory Book.fromMap(Map<dynamic, dynamic> map) {
    final Releases releases = Releases();

    final releasesMap = map['releases'] as List<dynamic>;

    for (final contentMap in releasesMap) {
      try {
        releases.add(Chapter.fromMap(contentMap));
      } catch (_) {
        throw Exception();
      }
    }

    return Book(
      title: map['title'] as String,
      url: map['url'] as String,
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
      type: map['type'] != null ? map['type'] as String : null,
      sinopse: map['sinopse'] != null ? map['sinopse'] as String : null,
      originalImage: map['originalImage'] as String,
      extraLarge:
          map['extraLarge'] != null ? map['extraLarge'] as String : null,
      largeImage:
          map['largeImage'] != null ? map['largeImage'] as String : null,
      mediumImage:
          map['mediumImage'] != null ? map['mediumImage'] as String : null,
      releases: releases,
    );
  }

  BookEntity toEntity({
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite = false,
  }) {
    return BookEntity(
      sinopse: sinopse,
      stringID: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite,
      alternativeTitle: alternativeTitle,
      extraLarge: extraLarge,
      largeImage: largeImage,
      mediumImage: mediumImage,
      originalImage: originalImage,
      title: title,
      url: url,
      source: source,
    );
  }
}


// class Test {
//   final String test;

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'test': test,
//     };
//   }

//   factory Test.fromMap(Map<String, dynamic> map) {
//     return Test(
//       test: map['test'] as String,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory Test.fromJson(String source) => Test.fromMap(json.decode(source) as Map<String, dynamic>);
// }
