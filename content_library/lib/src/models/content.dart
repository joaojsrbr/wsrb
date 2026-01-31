// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_library/content_library.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

part 'generated/content.mapper.dart';

sealed class SContent {}

@MappableClass(discriminatorKey: 'type')
abstract class Content extends Equatable
    with ContentMappable
    implements SContent, Comparable<Content> {
  @override
  List<Object?> get props => [
    imageUrl,
    stringID,
    url,
    sinopse,
    releases,
    genres,
    title,
    source,
  ];

  String get imageUrl;

  String get stringID => title.toUuID;

  ObjectKey getHeroTag() => ObjectKey(stringID);

  final String url;
  final bool isMovie;

  final String sinopse;

  final Releases releases;

  final List<Genre> genres;

  final AniListMedia? anilistMedia;

  final String title;

  final Source source;

  final RepositoryStatus repoStatus;

  const Content(
    this.releases, {
    this.genres = const [],
    required this.url,
    required this.source,
    required this.title,
    this.isMovie = false,
    this.sinopse = "",
    this.anilistMedia,
    this.repoStatus = const RepositoryStatus(),
  });

  @override
  String toString() => title.trim();

  ContentEntity toEntity({
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite = false,
  });

  @override
  int compareTo(Content other) => title.compareTo(other.title);
}

@MappableClass()
class RepositoryStatus with RepositoryStatusMappable {
  final bool loadData;
  final bool getData;
  final bool getReleases;
  final bool searchContents;

  const RepositoryStatus({
    this.loadData = false,
    this.getData = false,
    this.getReleases = false,
    this.searchContents = false,
  });
}

// class RestorableContent<T extends Content> extends RestorableValue<T> {
//   RestorableContent(T defaultValue) : _defaultValue = defaultValue;

//   final T _defaultValue;

//   @override
//   T createDefaultValue() => _defaultValue;

//   @override
//   void didUpdateValue(T? oldValue) {
//     if (oldValue != null && oldValue != value) {
//       notifyListeners();
//     }
//   }

//   @override
//   Object? toPrimitives() {
//     return value.toJson();
//   }

//   @override
//   T fromPrimitives(Object? data) {
//     if (data == null) return _defaultValue;

//     try {
//       final Map<String, dynamic> decodedData =
//           jsonDecode(data as String) as Map<String, dynamic>;

//       return switch (T.runtimeType) {
//             Anime _ => AnimeMapper.fromMap(decodedData),
//             Book _ => BookMapper.fromMap(decodedData),
//             _ => _defaultValue,
//           }
//           as T;
//     } catch (_) {}
//     return _defaultValue;
//   }
// }
