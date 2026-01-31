import 'package:content_library/content_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('anime ...', () async {
    Function deepEq = const DeepCollectionEquality().equals;
    final List<Content> test = [
      Anime(
        url: "",
        title: "1",
        releases: EpisodeReleases()..add(Episode(url: "2", title: "3", isDublado: true)),
        source: Source.ANROLL,
        originalImage: "",
      ),
      Anime(
        url: "",
        title: "2",
        releases: EpisodeReleases()..add(Episode(url: "2", title: "3", isDublado: true)),
        source: Source.ANROLL,
        originalImage: "",
      ),
      Anime(
        url: "",
        title: "3",
        releases: EpisodeReleases()..add(Episode(url: "2", title: "3", isDublado: true)),
        source: Source.ANROLL,
        originalImage: "",
      ),
    ];

    final List<Content> test2 = [
      Anime(
        url: "",
        title: "1",
        releases: EpisodeReleases()..add(Episode(url: "2", title: "3", isDublado: true)),
        source: Source.ANROLL,
        originalImage: "",
      ),
      Anime(
        url: "",
        title: "2",
        releases: EpisodeReleases()..add(Episode(url: "2", title: "3", isDublado: true)),
        source: Source.ANROLL,
        originalImage: "",
      ),
      Anime(
        url: "",
        title: "3",
        releases: EpisodeReleases()..add(Episode(url: "2", title: "", isDublado: false)),
        source: Source.ANROLL,
        originalImage: "",
      ),
      // Book(
      //   url: "",
      //   title: "3",
      //   releases: ChapterReleases()..add(Chapter(url: "", bookStringID: "", title: "")),
      //   source: Source.ANROLL,
      //   originalImage: "",
      // ),
    ];

    final result = deepEq(test, test2);

    customLog(result);
  });
}
