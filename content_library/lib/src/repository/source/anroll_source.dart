// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

class AnrollSource extends RSource {
  const AnrollSource(
    super.contentRepository, {
    super.initialIndex = 0,
  });

  @override
  String get BASE_URL => source.baseURL;

  @override
  Source get source => Source.ANROLL;

  @override
  Future<Result<List<Data>>> getContent(Release release) async {
    bool isEpisode() {
      return release is Episode;
    }

    assert(
      isEpisode(),
      "A instancia content precisa ser do tipo [$Episode]",
    );

    final episode = release as Episode;

    final List<Data> data = [];

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

    data.add(Data.videoData(videoContent: videoContent));

    return Result.success(data);
  }

  @override
  Future<Result<Content>> getReleases(Content content, int page) async {
    bool isAnime() => content is Anime;
    assert(
      isAnime(),
      "A instancia content precisa ser do tipo Anime",
    );
    try {
      final Anime anime = content as Anime;

      final releases = anime.releases;

      final episodesResponse = await contentRepository._dio.get(
        'https://apiv3-prd.anroll.net/animes/${anime.animeID}/episodes?page=$page&order=asc',
      );

      final episodesList = episodesResponse.data['data'] as List;

      int? totalOfEpisodes =
          episodesResponse.data['meta']['totalOfEpisodes'] as int?;
      int? totalOfPages = episodesResponse.data['meta']['totalOfPages'] as int?;

      for (final map in episodesList) {
        final n_episodio = map['n_episodio'];
        final number = int.parse(n_episodio);
        final title_episode = map['titulo_episodio'] as String;
        final pageNumber = episodesResponse.data['meta']['pageNumber'] as int?;
        final sinopse_episode = map['sinopse_episodio'] as String?;
        final episodeGenerateID = map['generate_id'];
        final thumbnail =
            "https://www.anroll.net/_next/image?url=https%3A%2F%2Fstatic.anroll.net%2Fimages%2Fanimes%2Fscreens%2F${anime.slugSerie}%2F$n_episodio.jpg&w=1080&q=100";

        final Episode episode = Episode(
          numberEpisode: number,
          isDublado: anime.isDublado,
          url: '$BASE_URL/e/$episodeGenerateID',
          generateID: episodeGenerateID,
          pageNumber: pageNumber,
          title: title_episode.contains('Episódio') ? 'N/A' : title_episode,
          sinopse: sinopse_episode,
          slugSerie: anime.slugSerie,
          thumbnail: thumbnail,
        );
        if (!releases.contains(episode)) releases.add(episode);
      }
      return Result.success(
        anime.copyWith(
          totalOfPages: totalOfPages,
          totalOfEpisodes: totalOfEpisodes,
        ),
      );
    } on DioException catch (_, __) {
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
      Anime anime = content as Anime;

      final String generateID =
          (anime.releases.firstOrNull as Episode?)?.generateID ??
              anime.generateID!;

      final Releases releases = Releases();

      final buildId = await getBuildId();

      final Response responseAnimeData = await contentRepository._dio.get(
        '$BASE_URL/_next/data/$buildId/e/$generateID.json?episode=$generateID',
        responseType: ResponseType.json,
      );

      final animeData = responseAnimeData.data['pageProps']['data'];

      final String url = '$BASE_URL/a/${animeData['anime']['generate_id']}';

      final String originalImage =
          'https://www.anroll.net/_next/image?url=https%3A%2F%2Fstatic.anroll.net%2Fimages%2Fanimes%2Fcapas%2F${anime.slugSerie}.jpg&w=1080&q=100';

      final String animeID = (animeData['id_serie']).toString();

      String? sinopse = animeData['sinopse_episodio'];

      int? totalOfEpisodes;

      int? totalOfPages;

      Anime newAnime = anime.copyWith(
        url: url,
        animeID: animeID,
        releases: releases,
        totalOfEpisodes: totalOfEpisodes,
        totalOfPages: totalOfPages,
        originalImage: originalImage,
        sinopse: sinopse,
      );

      if (anime.totalOfEpisodes == null) {
        bool hasNextPage = false;

        int page = 1;

        do {
          final result = await getReleases(newAnime, page);
          result.when(onSucess: (data) => newAnime = data as Anime);
          hasNextPage = anime.totalOfEpisodes == anime.releases.length;
          if (hasNextPage) page++;
        } while (hasNextPage);
      }

      return Result.success(newAnime);
    } on DioException catch (_, __) {
      return Result.failure(_);
    } on AnrollGetIdException catch (_, __) {
      customLog('ERROR[${_.runtimeType}]: ${_.message}', stackTrace: __);
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

  Future<String> getBuildId() async {
    final Response responseTest = await contentRepository._dio.get(
      BASE_URL,
      responseType: ResponseType.plain,
    );

    final Element? element =
        parse(responseTest.data).querySelector('#__NEXT_DATA__');

    if (element == null) {
      throw AnrollGetIdException();
    } else {
      final map = jsonDecode(element.text);
      final buildId = map['buildId'] as String;
      return buildId;
    }
  }

  @override
  Future<bool> loadData() async {
    try {
      final buildId = await getBuildId();

      final subKey = "_next/data/$buildId/lancamentos.json";

      final String mainURL = '$BASE_URL/$subKey';

      final Response response = await contentRepository._dio.get(
        mainURL,
        responseType: ResponseType.json,
      );

      final releases =
          response.data['pageProps']['data']['data_releases'] as List<dynamic>;

      for (final release in releases) {
        final title = release['episode']['anime']['titulo'] as String;
        final slugSerie = release['episode']['anime']['slug_serie'];
        final episodeGenerateID = release['episode']['generate_id'];
        final isDublado =
            ((release['episode']['anime']['dub'] as int) == 0 ? false : true) |
                title.toLowerCase().contains('dublado');
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

        final releases = Releases();
        final subKey =
            '_next/data/$buildId/e/$episodeGenerateID.json?episode=$episodeGenerateID';

        final String mainURL = '$BASE_URL/$subKey';
        final anime = Anime(
          generateID: episodeGenerateID,
          originalImage: thumbnail,
          source: source,
          url: mainURL,
          isDublado: isDublado,
          slugSerie: slugSerie,
          title: title,
          releases: releases,
        );
        if (!releases.contains(episode)) releases.add(episode);

        if (!contentRepository.contains(anime)) contentRepository.add(anime);
      }
      contentRepository.isSuccess = true;
      contentRepository._hasMore = false;
      contentRepository.fullScreenError = null;
      return Future.value(false);
    } on AnrollGetIdException catch (_, __) {
      contentRepository.fullScreenError = _;
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      customLog('ERROR[${_.runtimeType}]: ${_.message}', stackTrace: __);
      return Future.value(false);
    } on DioException catch (_, __) {
      contentRepository.fullScreenError = _;
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    }
  }
}
