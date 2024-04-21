// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:content_library/content_library.dart';

class PlayerArgs {
  final Release episode;
  final CapturedThemes? capturedThemes;
  Anime anime;

  PlayerArgs({
    required this.episode,
    required this.anime,
    this.capturedThemes,
  });

  PlayerArgs copyWith({
    Release? episode,
    List<Release>? allEpisodes,
    Anime? anime,
    CapturedThemes? capturedThemes,
  }) {
    return PlayerArgs(
      capturedThemes: capturedThemes ?? this.capturedThemes,
      episode: episode ?? this.episode,
      anime: anime ?? this.anime,
    );
  }

  @override
  bool operator ==(covariant PlayerArgs other) {
    if (identical(this, other)) return true;

    return other.episode == episode &&
        other.capturedThemes == capturedThemes &&
        other.anime == anime;
  }

  @override
  int get hashCode =>
      episode.hashCode ^ capturedThemes.hashCode ^ anime.hashCode;
}
