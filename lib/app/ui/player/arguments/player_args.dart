// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_library/content_library.dart';

class PlayerArgs {
  final Episode episode;
  final Anime anime;
  final Duration? startPossition;

  const PlayerArgs({
    required this.episode,
    required this.anime,
    this.startPossition,
  });

  PlayerArgs copyWith({
    Episode? episode,
    Anime? anime,
    Duration? startPossition,
  }) {
    return PlayerArgs(
      episode: episode ?? this.episode,
      anime: anime ?? this.anime,
      startPossition: startPossition ?? this.startPossition,
    );
  }

  @override
  bool operator ==(covariant PlayerArgs other) {
    if (identical(this, other)) return true;

    return other.episode == episode && other.anime == anime;
  }

  @override
  int get hashCode => episode.hashCode ^ anime.hashCode;
}
