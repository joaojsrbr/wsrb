// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app_wsrb_jsr/app/models/anime.dart';
import 'package:app_wsrb_jsr/app/models/release.dart';

class PlayerArgs {
  final Release episode;
  Anime anime;
  PlayerArgs({
    required this.episode,
    required this.anime,
  });

  PlayerArgs copyWith({
    Release? episode,
    List<Release>? allEpisodes,
    Anime? anime,
  }) {
    return PlayerArgs(
      episode: episode ?? this.episode,
      anime: anime ?? this.anime,
    );
  }
}
