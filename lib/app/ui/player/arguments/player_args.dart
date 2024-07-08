// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_library/content_library.dart';

class PlayerArgs {
  final Episode episode;
  final Anime anime;
  final Duration? startPossition;
  final Data? data;

  const PlayerArgs({
    this.data,
    required this.episode,
    required this.anime,
    this.startPossition,
  });

  PlayerArgs copyWith({
    Data? data,
    Episode? episode,
    Anime? anime,
    Duration? startPossition,
  }) {
    return PlayerArgs(
      data: data ?? this.data,
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
