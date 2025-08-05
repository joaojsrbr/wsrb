import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class Content extends Equatable {
  @override
  List<Object?> get props => [
    imageUrl,
    stringID,
    url,
    sinopse,
    _releases,
    genres,
    title,
    source,
  ];

  String get imageUrl;

  String get stringID => title.toUuID;

  ObjectKey getHeroTag() => ObjectKey(stringID);

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
}
