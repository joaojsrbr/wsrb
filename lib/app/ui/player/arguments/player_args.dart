// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';

class PlayerArgs with EquatableMixin {
  final Episode episode;
  final Anime anime;
  final Duration? startPossition;
  final Data? data;
  final bool forceEnterFullScreen;
  final bool getAnimeData;

  PlayerArgs({
    this.data,
    this.forceEnterFullScreen = false,
    this.getAnimeData = true,
    required this.episode,
    required this.anime,
    this.startPossition,
  }) {
    anime.releases.sort();
  }

  PlayerArgs copyWith({
    Data? data,
    Episode? episode,
    bool? forceEnterFullScreen,
    bool? getAnimeData,
    Anime? anime,
    Duration? startPossition,
  }) {
    return PlayerArgs(
      forceEnterFullScreen: forceEnterFullScreen ?? this.forceEnterFullScreen,
      getAnimeData: getAnimeData ?? this.getAnimeData,
      data: data ?? this.data,
      episode: episode ?? this.episode,
      anime: anime ?? this.anime,
      startPossition: startPossition ?? this.startPossition,
    );
  }

  List<AnimeTimeStamp> get times {
    return (anime.animeSkip?.times ?? [])
        .where(
          (skip) => skip.absoluteNumber == int.parse(episode.number),
        )
        .toList()
        .cast();
  }

  @override
  List<Object?> get props => [
        episode,
        anime,
        startPossition,
        data,
        forceEnterFullScreen,
        getAnimeData
      ];
}
