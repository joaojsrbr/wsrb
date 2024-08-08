import 'package:equatable/equatable.dart';

import '../entities/entity.dart';
import '../extensions/custom_extensions/string_extensions.dart';
import '../utils/releases.dart';

abstract class Content extends Equatable {
  String get imageUrl;

  String get stringID => title.toUuID;

  final String url;

  final String? sinopse;

  final Releases _releases;

  Releases get releases => _releases;

  final String title;

  const Content(
    this._releases, {
    required this.url,
    required this.title,
    this.sinopse,
  });

  Content copyWith({
    String? title,
    String? sinopse,
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
        "releases": _releases.toMap,
        "url": url,
        "title": title,
        "sinopse": sinopse,
      };

  @override
  List<Object?> get props {
    final cache = map..remove("releases");
    final values = cache.values.toList()..addAll(_releases);
    return values;
  }
}
