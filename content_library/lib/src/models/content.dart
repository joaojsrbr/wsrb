import 'dart:convert';

import 'package:content_library/content_library.dart';
import 'package:content_library/src/entities/anilist_media.dart';
import 'package:equatable/equatable.dart';

abstract class Content extends Equatable {
  String get imageUrl;

  String get stringID => title.toUuID;

  String getHeroTag() {
    return imageUrl;
  }

  final String url;

  final String? sinopse;

  final bool cached;

  final Releases _releases;

  Releases get releases => _releases;

  final List<Genre> genres;

  final AniListMedia? anilistMedia;

  final String title;

  final Source source;

  const Content(
    this._releases, {
    this.cached = false,
    this.genres = const [],
    required this.url,
    required this.source,
    required this.title,
    this.sinopse,
    this.anilistMedia,
  });

  factory Content.fromMap(String data) {
    final map = jsonDecode(data);

    if (map['class'] == 'ANIME') {
      return Anime.fromMap(map);
    }
    return Book.fromMap(map);
  }

  Content copyWith({
    String? title,
    bool? cached,
    List<Genre>? genres,
    String? sinopse,
    AniListMedia? anilistMedia,
    Source? source,
    String? url,
    Releases? releases,
  });

  @override
  String toString() => title.trim();

  ContentEntity toEntity({
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        "anilistMedia": anilistMedia?.toJson(),
        "releases": _releases.toMap,
        "url": url,
        "cached": cached,
        "title": title,
        "sinopse": sinopse,
        "source": source.label,
      };

  @override
  List<Object?> get props => toJson().values.toList();
}
