import 'package:content_library/content_library.dart';
import 'package:content_library/src/utils/object_utils.dart';
import 'package:equatable/equatable.dart';

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

  final List<Genre> genres;

  final AnilistMedia? anilistMedia;

  final String title;

  const Content(
    this._releases, {
    this.genres = const [],
    required this.url,
    required this.title,
    this.sinopse,
    this.anilistMedia,
  });

  Content copyWith({
    String? title,
    List<Genre>? genres,
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
