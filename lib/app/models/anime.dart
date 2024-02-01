import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/color_scheme_extensions.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:flutter/material.dart';

class Anime extends Content {
  const Anime({
    required super.url,
    required super.sinopse,
    required super.title,
    super.contentColorScheme,
    super.allDataContent,
  });

  @override
  List<Object?> get props => [
        url,
        sinopse,
        title,
        contentColorScheme,
        allDataContent,
      ];

  @override
  String get imageUrl => title;

  @override
  Anime copyWith({
    AllDataContent? allDataContent,
    String? title,
    String? url,
    String? sinopse,
    ColorScheme? contentColorScheme,
  }) {
    return Anime(
      sinopse: sinopse ?? this.sinopse,
      allDataContent: allDataContent ?? this.allDataContent,
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
      'sinopse': sinopse,
      'contentColorScheme': contentColorScheme?.toMap,
    };
  }

  factory Anime.fromMap(Map<dynamic, dynamic> map) {
    return Anime(
      sinopse: map['sinopse'] != null ? map['sinopse'] as String : null,
      title: map['title'] as String,
      url: map['url'] as String,
      contentColorScheme: map['contentColorScheme'] != null
          ? ColorSchemeExtensions.fromMap(map['contentColorScheme'])
          : null,
    );
  }
}
