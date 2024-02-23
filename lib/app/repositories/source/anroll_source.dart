// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

class AnrollSource extends RSource {
  const AnrollSource(
    super.contentRepository, {
    super.initialIndex = 0,
  });

  @override
  String get BASE_URL => App.ANROLL_URL;

  @override
  Future<Result<List<Data>>> getContent(Release release) async {
    bool isEpisode() {
      return release is Episode;
    }

    assert(
      isEpisode(),
      "A instancia content precisa ser do tipo Episode",
    );

    final episode = release as Episode;

    final List<VideoData> data = [];

    final numberInt = int.parse(episode.number);

    String stringNumber;

    if (numberInt < 10) {
      stringNumber = '00$numberInt';
    } else if (numberInt >= 10 && numberInt < 100) {
      stringNumber = '0$numberInt';
    } else {
      stringNumber = '$numberInt';
    }

    final videoContent =
        'https://cdn-zenitsu-gamabunta.b-cdn.net/cf/hls/animes/${episode.slugSerie}/$stringNumber.mp4/media-1/stream.m3u8';

    data.add(Data.videoData(videoContent: videoContent) as VideoData);

    try {
      await contentRepository._dio.get(
        videoContent,
        headers: {
          "origin": BASE_URL,
          "referer": "$BASE_URL/",
          ..._headers,
        },
      );
      return Result.success(data);
    } on DioException catch (_, __) {
      customLog('Algo ruím aconteceu', error: _, stackTrace: __);
      return Result.failure(_);
    }
  }

  @override
  Future<Result<Content>> getData(Content content) async {
    bool isAnime() {
      return content is Anime;
    }

    assert(
      isAnime(),
      "A instancia content precisa ser do tipo Anime",
    );

    try {
      final anime = content as Anime;

      final episode = anime.releases.first as Episode;

      final Releases releases = Releases.fromList(anime.releases);

      final (buildId, success) = await getBuildId();

      if (!success) return Result.failure(Exception());

      final Response responseAnimeData = await contentRepository._dio.get(
        '$BASE_URL/_next/data/$buildId/e/${episode.generateID}.json?episode=${episode.generateID}',
        responseType: ResponseType.json,
        headers: _headers,
      );

      final animeData = responseAnimeData.data['pageProps']['data'];

      final String url = '$BASE_URL/a/${animeData['anime']['generate_id']}';

      final String originalImage =
          'https://www.anroll.net/_next/image?url=https%3A%2F%2Fstatic.anroll.net%2Fimages%2Fanimes%2Fcapas%2F${anime.slugSerie}.jpg&w=1080&q=100';

      final String animeID = (animeData['id_serie']).toString();

      String? sinopse = animeData['sinopse_episodio'];

      bool hasNextPage = false;

      int page = 1;

      do {
        final episodesResponse = await contentRepository._dio.get(
          'https://apiv3-prd.anroll.net/animes/$animeID/episodes?page=$page&order=desc',
          headers: _headers,
        );

        final episodesList = episodesResponse.data['data'] as List;

        for (final map in episodesList) {
          final n_episodio = map['n_episodio'];
          final number = int.parse(n_episodio);

          final episodeGenerateID = map['generate_id'];
          final thumbnail =
              "https://www.anroll.net/_next/image?url=https%3A%2F%2Fstatic.anroll.net%2Fimages%2Fanimes%2Fscreens%2F${anime.slugSerie}%2F$n_episodio.jpg&w=1080&q=100";

          final Episode episode = Episode(
            isDublado: anime.isDublado,
            url: '$BASE_URL/e/$episodeGenerateID',
            generateID: episodeGenerateID,
            title: 'Episódio $number',
            slugSerie: anime.slugSerie,
            thumbnail: thumbnail,
          );
          if (!releases.contains(episode)) releases.add(episode);
        }

        hasNextPage = episodesResponse.data['meta']['hasNextPage'];
        if (hasNextPage) page++;
      } while (hasNextPage);

      // final newAnime = (await _getAnimePictures(anime)).copyWith(
      final newAnime = anime.copyWith(
        url: url,
        animeID: animeID,
        releases: releases,
        originalImage: originalImage,
        sinopse: sinopse,
      );

      return Result.success(newAnime);
    } on DioException catch (_, __) {
      customLog('Algo ruím aconteceu', error: _, stackTrace: __);
      return Result.failure(_);
    }
  }

  // static Future<Anime> _getAnimePictures(Anime anime) async {
  //   return await compute(
  //     (Anime anime) async {
  //       final result =
  //           await JikanService().getAnimePictures(query: anime.title.trim());
  //       if (result.isNotEmpty) {
  //         final last = result.last;
  //         final medium = last.imageUrl;
  //         final large = last.imageUrl;
  //         final extraLarge = last.largeImageUrl;
  //         return anime.copyWith(
  //           extraLarge: extraLarge,
  //           largeImage: large,
  //           mediumImage: medium,
  //         );
  //       }
  //       return anime;
  //     },
  //     anime,
  //   );
  // }

  Map<String, String> get _headers => {
        "user-agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0"
      };

  Future<(String, bool)> getBuildId() async {
    final Response responseTest = await contentRepository._dio.get(
      BASE_URL,
      headers: _headers,
      responseType: ResponseType.plain,
    );

    final Element? element =
        parse(responseTest.data).querySelector('#__NEXT_DATA__');

    if (element == null) {
      return Future.value(('', false));
    } else {
      final map = jsonDecode(element.text);

      final buildId = map['buildId'] as String;
      return (buildId, true);
    }
  }

  @override
  Future<bool> loadData() async {
    try {
      final (buildId, success) = await getBuildId();

      if (!success) {
        contentRepository.isSuccess = false;
        contentRepository._hasMore = false;
        return Future.value(false);
      }

      final subKey = "_next/data/$buildId/lancamentos.json";

      final String mainURL = '$BASE_URL/$subKey';

      final Response response = await contentRepository._dio.get(
        mainURL,
        headers: _headers,
        responseType: ResponseType.json,
      );

      final releases =
          response.data['pageProps']['data']['data_releases'] as List<dynamic>;

      for (final release in releases) {
        final title = release['episode']['anime']['titulo'] as String;
        final slugSerie = release['episode']['anime']['slug_serie'];
        final episodeGenerateID = release['episode']['generate_id'];
        final isDublado =
            (release['episode']['anime']['dub'] as int) == 0 ? false : true;
        final n_episodio = release['episode']['n_episodio'];
        final number = int.parse(n_episodio);

        final thumbnail =
            "https://www.anroll.net/_next/image?url=https%3A%2F%2Fstatic.anroll.net%2Fimages%2Fanimes%2Fscreens%2F$slugSerie%2F$n_episodio.jpg&w=1080&q=100";

        final Episode episode = Episode(
          slugSerie: slugSerie,
          isDublado: isDublado,
          url: '$BASE_URL/e/$episodeGenerateID',
          generateID: episodeGenerateID,
          title: 'Episódio $number',
          thumbnail: thumbnail,
        );

        // final haveAnime = contentRepository.firstWhereOrNull(
        //   (element) =>
        //       element.title.contains(title.replaceAll('- Dublado', '').trim()),
        // );

        // if (haveAnime != null &&
        //     !haveAnime.releases
        //         .any((element) => episode.title.contains(element.title))) {
        //   haveAnime.releases.add(episode);
        // } else {
        final releases = Releases();
        final subKey =
            '_next/data/$buildId/e/$episodeGenerateID.json?episode=$episodeGenerateID';

        final String mainURL = '$BASE_URL/$subKey';
        final anime = Anime(
          originalImage: '',
          url: mainURL,
          isDublado: isDublado,
          slugSerie: slugSerie,
          title: title,
          releases: releases,
        );
        if (!releases.contains(episode)) releases.add(episode);

        if (!contentRepository.contains(anime)) contentRepository.add(anime);
        // }
      }

      contentRepository.isSuccess = true;
      contentRepository._hasMore = false;
      return Future.value(false);
    } on DioException catch (_, __) {
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      customLog('Algo ruím aconteceu', error: _, stackTrace: __);
      return Future.value(false);
    }
  }

  @override
  Source get source => Source.ANROLL;
}
