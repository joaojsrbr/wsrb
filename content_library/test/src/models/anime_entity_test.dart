import 'package:content_library/content_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('anime entity ...', () async {
    final Episode episode = Episode(url: "", title: "Episode 1", isDublado: true);
    final Anime anime = Anime(
      url: "",
      title: "",
      releases: EpisodeReleases()..add(episode),
      source: Source.TOP_ANIMES,
      originalImage: "",
    );

    final AnimeEntity animeEntity = anime.toEntity();

    animeEntity.episodes.add(episode.toEntity(anime: anime));

    final $1 = animeEntity.episodes;
    final $2 = animeEntity.copyWith().episodes;
    final $3 = anime.releases;
    final $4 = anime.copyWith().releases;

    customLog($1);

    customLog($2);

    customLog($3);

    customLog($4);
  });
}
