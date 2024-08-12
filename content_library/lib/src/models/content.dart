import 'package:anilist_dart/anilist.dart';
import 'package:content_library/src/utils/object_utils.dart';
import 'package:equatable/equatable.dart';

import '../entities/entity.dart';
import '../extensions/custom_extensions/string_extensions.dart';
import '../utils/releases.dart';

abstract class Content extends Equatable with MergeClass<Content> {
  String get imageUrl;

  String get stringID => title.toUuID;

  String getHeroTag() {
    return imageUrl;
  }

  final String url;

  final String? sinopse;

  final Releases _releases;

  Releases get releases => _releases;

  final AnilistMedia? animeMedia;

  final String title;

  const Content(
    this._releases, {
    required this.url,
    required this.title,
    this.sinopse,
    this.animeMedia,
  });

  Content copyWith({
    String? title,
    String? sinopse,
    AnilistMedia? animeMedia,
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

  Map<String, dynamic> get map => {
        "animeMedia":
            animeMedia != null ? AnilistMedia.toJson(animeMedia!) : null,
        "releases": _releases.toMap,
        "url": url,
        "title": title,
        "sinopse": sinopse,
      };

  @override
  List<Object?> get props => map.values.toList();
}
