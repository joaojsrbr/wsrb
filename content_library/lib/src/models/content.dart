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

  final AnilistMedia? anilistMedia;

  final String title;

  const Content(
    this._releases, {
    required this.url,
    required this.title,
    this.sinopse,
    this.anilistMedia,
  });

  Content copyWith({
    String? title,
    String? sinopse,
    AnilistMedia? anilistMedia,
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
        "anilistMedia":
            anilistMedia != null ? AnilistMedia.toJson(anilistMedia!) : null,
        "releases": _releases.toMap,
        "url": url,
        "title": title,
        "sinopse": sinopse,
      };

  @override
  List<Object?> get props => map.values.toList();
}
