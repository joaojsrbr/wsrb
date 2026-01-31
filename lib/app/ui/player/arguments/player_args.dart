// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_library/content_library.dart';
import 'package:equatable/equatable.dart';

class PlayerArgs with EquatableMixin {
  final Episode episode;
  final Anime anime;
  final Duration? startPossition;
  final List<Data> data;
  final Data? firstSelectData;
  final bool forceEnterFullScreen;

  PlayerArgs({
    this.data = const [],
    this.forceEnterFullScreen = false,
    required this.episode,
    required this.anime,
    this.startPossition,
    this.firstSelectData,
  }) {
    anime.releases.sort();
  }

  PlayerArgs copyWith({
    List<Data>? data,
    Episode? episode,
    bool? forceEnterFullScreen,
    bool? getAnimeData,
    Anime? anime,
    Duration? startPossition,
  }) {
    return PlayerArgs(
      forceEnterFullScreen: forceEnterFullScreen ?? this.forceEnterFullScreen,
      data: data ?? this.data,
      episode: episode ?? this.episode,
      anime: anime ?? this.anime,
      startPossition: startPossition ?? this.startPossition,
    );
  }

  List<AnimeTimeStamp> get times {
    return (anime.animeSkip?.times ?? [])
        .where((skip) => skip.absoluteNumber == episode.numberInt)
        .toList()
        .cast();
  }

  @override
  List<Object?> get props => [episode, anime, startPossition, data, forceEnterFullScreen];
}
