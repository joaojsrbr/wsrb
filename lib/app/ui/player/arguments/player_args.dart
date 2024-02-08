// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app_wsrb_jsr/app/models/anime.dart';
import 'package:app_wsrb_jsr/app/models/data_content.dart';

class PlayerArgs {
  final DataContent episode;
  Anime anime;
  PlayerArgs({
    required this.episode,
    required this.anime,
  });

  PlayerArgs copyWith({
    DataContent? episode,
    List<DataContent>? allEpisodes,
    Anime? anime,
  }) {
    return PlayerArgs(
      episode: episode ?? this.episode,
      anime: anime ?? this.anime,
    );
  }
}
