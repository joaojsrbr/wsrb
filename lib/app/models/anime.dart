import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/color_scheme_extensions.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/models/episode.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:flutter/material.dart';

class Anime extends Content {
  const Anime({
    required super.url,
    required super.title,
    required super.releases,
    required this.originalImage,
    this.slugSerie,
    this.extraLarge,
    this.mediumImage,
    this.animeID,
    this.largeImage,
    this.dublado = false,
    super.sinopse,
    super.contentColorScheme,
  });
  final String? animeID;
  final String? extraLarge;
  final String originalImage;
  final String? largeImage;
  final String? mediumImage;
  final String? slugSerie;
  final bool dublado;

  @override
  List<Object?> get props => [
        title,
        url,
        sinopse,
        contentColorScheme,
        releases,
        slugSerie,
        dublado,
        originalImage,
        extraLarge,
        largeImage,
        mediumImage,
        animeID,
      ];

  @override
  String get imageUrl =>
      extraLarge ?? largeImage ?? mediumImage ?? originalImage;

  @override
  Anime copyWith({
    Releases? releases,
    String? title,
    String? url,
    String? animeID,
    String? slugSerie,
    String? originalImage,
    String? extraLarge,
    String? largeImage,
    String? mediumImage,
    bool? dublado,
    String? sinopse,
    ColorScheme? contentColorScheme,
  }) {
    return Anime(
      animeID: animeID ?? this.animeID,
      originalImage: originalImage ?? this.originalImage,
      mediumImage: mediumImage ?? this.mediumImage,
      largeImage: largeImage ?? this.largeImage,
      extraLarge: extraLarge ?? this.extraLarge,
      sinopse: sinopse ?? this.sinopse,
      dublado: dublado ?? this.dublado,
      slugSerie: slugSerie ?? this.slugSerie,
      releases: releases ?? this.releases,
      title: title ?? this.title,
      url: url ?? this.url,
      contentColorScheme: contentColorScheme ?? this.contentColorScheme,
    );
  }

  @override
  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'title': title,
      'url': url,
      'dublado': dublado,
      'slugSerie': slugSerie,
      'sinopse': sinopse,
      'releases': releases.map((x) => x.toMap).toList(),
      'contentColorScheme': contentColorScheme?.toMap,
      'extraLarge': extraLarge,
      'originalImage': originalImage,
      'largeImage': largeImage,
      'mediumImage': mediumImage,
    };
  }

  factory Anime.fromMap(Map<dynamic, dynamic> map) {
    final Releases releases = Releases();

    final releaseMap = map['releases'] as List<dynamic>;

    for (final contentMap in releaseMap) {
      try {
        releases.add(Episode.fromMap(contentMap));
      } catch (_) {
        customLog(contentMap, error: _);
      }
    }

    return Anime(
      dublado: map['dublado'] as bool,
      slugSerie: map['slugSerie'] != null ? map['slugSerie'] as String : null,
      originalImage: map['originalImage'] as String,
      extraLarge:
          map['extraLarge'] != null ? map['extraLarge'] as String : null,
      largeImage:
          map['largeImage'] != null ? map['largeImage'] as String : null,
      mediumImage:
          map['mediumImage'] != null ? map['mediumImage'] as String : null,
      releases: releases,
      sinopse: map['sinopse'] != null ? map['sinopse'] as String : null,
      title: map['title'] as String,
      url: map['url'] as String,
      contentColorScheme: map['contentColorScheme'] != null
          ? ColorSchemeExtensions.fromMap(map['contentColorScheme'])
          : null,
    );
  }
}
