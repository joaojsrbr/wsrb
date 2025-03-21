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
    if (release is! Episode) {
      return Result.failure(
        AnimeGetDataException(
          message: "A instancia content precisa ser do tipo Episode",
        ),
      );
    }

    final List<Data> data = [];

    final numberInt = int.parse(release.number);

    String stringNumber;

    if (numberInt < 10) {
      stringNumber = '00$numberInt';
    } else if (numberInt >= 10 && numberInt < 100) {
      stringNumber = '0$numberInt';
    } else {
      stringNumber = '$numberInt';
    }

    final videoContent =
        'https://cdn-zenitsu-2-gamabunta.b-cdn.net/cf/hls/animes/${release.slugSerie}/$stringNumber.mp4/media-1/stream.m3u8';

    data.add(
      Data.videoData(
        videoContent: videoContent,
        httpHeaders: {
          "origin": BASE_URL,
          "referer": "$BASE_URL/",
        },
      ),
    );

    return Result.success(data);
  }

  Future<Anime> _getAnimeID(Anime anime) async {
    if (anime.animeID == null) {
      return await contentRepository._dio
          .get("https://www.anroll.net/e/${anime.generateID}")
          .then(
        (response) {
          return anime.copyWith(
            animeID: parse(response.data)
                .querySelector('#anime_title a')
                ?.attributes['href']
                ?.split('/')
                .last,
          );
        },
      );
    }
    return anime;
  }

  @override
  Future<Result<Anime>> getReleases(Content content, int page) async {
    if (content is! Anime) throw AnimeGetDataException();

    try {
      String? animeID = content.animeID ?? (await _getAnimeID(content)).animeID;

      final episodesResponse = await contentRepository._dio.get(
        'https://apiv3-prd.anroll.net/animes/$animeID/episodes?order=asc${page == -1 ? '' : '&page=$page'}',
      );

      final episodesList = episodesResponse.data['data'] as List;

      int? totalOfEpisodes =
          episodesResponse.data['meta']['totalOfEpisodes'] as int?;
      int? totalOfPages = episodesResponse.data['meta']['totalOfPages'] as int?;

      final lastENumber = int.parse(episodesList.last['n_episodio']);

      content.releases.removeWhere(
          (element) => (int.tryParse(element.number) ?? 0) > lastENumber);

      for (final map in episodesList) {
        final number = int.parse(map['n_episodio']);
        final titleEpisode = map['titulo_episodio'] as String;
        final pageNumber = episodesResponse.data['meta']['pageNumber'] as int?;
        final sinopseEpisode = map['sinopse_episodio'] as String?;
        final episodeGenerateID = map['generate_id'] as String?;
        final thumbnail =
            "https://static.anroll.net/images/animes/screens/${content.slugSerie}/${map['n_episodio']}.jpg";

        final Episode episode = Episode(
          numberEpisode: number,
          isDublado: content.isDublado,
          url: '$BASE_URL/e/$episodeGenerateID',
          generateID: episodeGenerateID,
          pageNumber: pageNumber,
          title: titleEpisode.contains('Episódio') ? 'N/A' : titleEpisode,
          sinopse: sinopseEpisode,
          slugSerie: content.slugSerie,
          thumbnail: thumbnail,
        );

        content.releases.addOrUpdateWhere(episode, episode.isEqualStringID);
      }

      if (content.animeSkip == null &&
          content.anilistMedia?.title?.english != null) {
        final title = content.anilistMedia!.title!.english!;

        final result =
            await contentRepository._animeSkipRepository.getTimeStampsByName(
          search: title,
        );

        if (result is Success<List<AnimeSkip>>) {
          final skip =
              result.data.firstWhereOrNull((skip) => title.contains(skip.name));
          content = content.copyWith(animeSkip: skip);
        }
      }

      return Result.success(
        content.copyWith(
          animeID: animeID,
          totalOfPages: totalOfPages,
          totalOfEpisodes: totalOfEpisodes,
        ),
      );
    } on DioException catch (_, __) {
      return Result.failure(_);
    }
  }

  @override
  Future<Result<Anime>> getData(Content content) async {
    try {
      if (content is! Anime) throw AnimeGetDataException();

      Anime newAnime = await _getAnimeID(content);

      final String generateID =
          content.releases.firstOrNull?.generateID ?? content.generateID!;

      final String buildId = await getBuildId();

      Future<void> getData() async {
        final animeApiUrl =
            'https://apiv3-prd.anroll.net/animes/${newAnime.animeID}';

        final Response responseAnimeData = await contentRepository._dio
            .get(animeApiUrl, responseType: ResponseType.json)
            .catchError(
              (error) => contentRepository._dio.get(
                '$BASE_URL/_next/data/$buildId/e/$generateID.json?episode=$generateID',
                responseType: ResponseType.json,
              ),
            );

        final animeData = responseAnimeData.data['data'] ??
            responseAnimeData.data['pageProps']['data'] as Map;

        final String url =
            '$BASE_URL/a/${animeData.containsKey('anime') ? animeData['anime']['generate_id'] : animeData['generate_id']}';

        final String originalImage =
            'https://static.anroll.net/images/animes/capas/${newAnime.slugSerie}.jpg';

        final String animeID = (animeData['id_serie']).toString();

        String? sinopse = animeData['sinopse_episodio'] ?? animeData['sinopse'];

        List<Genre>? generos = animeData['generos']
            ?.toString()
            .split(',')
            .map((gen) => Genre(gen.capitalize))
            .toList();

        int? totalOfEpisodes = animeData['episodes'];

        newAnime = newAnime.copyWith(
          url: url,
          animeID: animeID,
          genres: generos,
          totalOfEpisodes: totalOfEpisodes,
          originalImage: originalImage,
          sinopse: sinopse,
        );
      }

      Future<void> getEpisodes() async {
        await getReleases(newAnime, -1).then(
            (result) => result.fold(onSuccess: (data) => newAnime = data));
      }

      Future<void> getAniListData() async {
        final anilistMedia = await contentRepository.getAnilistMedia(newAnime);

        if (anilistMedia != null) {
          newAnime = newAnime.copyWith(
            anilistMedia: AniListMedia.fromJson(
              AnilistMedia.toJson(anilistMedia),
            ),
            largeImage: anilistMedia.coverImage?.large,
            mediumImage: anilistMedia.coverImage?.medium,
          );
        }
      }

      await getData();
      await getAniListData();

      await getEpisodes();

      return Result.success(newAnime);
    } on DioException catch (_, __) {
      return Result.failure(_);
    } on AnrollGetIdException catch (_, __) {
      customLog('ERROR[${_.runtimeType}]: ${_.message}', stackTrace: __);
      return Result.failure(_);
    } on AnimeGetDataException catch (_, __) {
      customLog('ERROR[${_.runtimeType}]: ${_.message}', stackTrace: __);
      return Result.failure(_);
    }
  }

  Future<String> getBuildId() async {
    final Response response = await contentRepository._dio.get(
      BASE_URL,
      responseType: ResponseType.plain,
    );

    final Element? element =
        parse(response.data).querySelector('#__NEXT_DATA__');

    if (element == null) {
      throw AnrollGetIdException();
    } else {
      final map = jsonDecode(element.text);
      final String buildId = map['buildId'] as String;
      return buildId;
    }
  }

  @override
  Future<bool> loadData() async {
    try {
      final String buildId = await getBuildId();

      final String subKey = "_next/data/$buildId/lancamentos.json";

      final String mainURL = '$BASE_URL/$subKey';

      final Response response = await contentRepository._dio.get(
        mainURL,
        responseType: ResponseType.json,
      );

      final List<dynamic> releases =
          response.data['pageProps']['data']['data_releases'] as List<dynamic>;

      for (final release in releases) {
        final String title = release['episode']['anime']['titulo'] as String;
        final String slugSerie = release['episode']['anime']['slug_serie'];
        final String episodeGenerateID = release['episode']['generate_id'];
        final bool isDublado =
            ((release['episode']['anime']['dub'] as int) == 0 ? false : true) ||
                title.toLowerCase().contains('dublado');
        final int nEpisodio = int.parse(release['episode']['n_episodio']);

        final String thumbnail =
            "https://static.anroll.net/images/animes/screens/$slugSerie/${release['episode']['n_episodio']}.jpg";

        final Episode episode = Episode(
          slugSerie: slugSerie,
          isDublado: isDublado,
          url: '$BASE_URL/e/$episodeGenerateID',
          generateID: episodeGenerateID,
          title: 'Episódio $nEpisodio',
          thumbnail: thumbnail,
        );

        final String subKey =
            '_next/data/$buildId/e/$episodeGenerateID.json?episode=$episodeGenerateID';

        final String mainURL = '$BASE_URL/$subKey';

        final Anime anime = Anime(
          generateID: episodeGenerateID,
          originalImage: thumbnail,
          source: source,
          url: mainURL,
          isDublado: isDublado,
          slugSerie: slugSerie,
          title: title,
          releases: EpisodeReleases()..add(episode),
        );

        contentRepository.addIfNoContains(
            anime, (other) => other.stringID == anime.stringID);
      }
      contentRepository.isSuccess = true;
      contentRepository._hasMore = false;
      contentRepository.fullScreenError = null;
      return Future.value(false);
    } on AnrollGetIdException catch (_, __) {
      contentRepository.fullScreenError = _;
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    } on DioException catch (_, __) {
      contentRepository.fullScreenError = _;
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    }
  }

  @override
  Future<Result<List<Anime>>> search(String query) async {
    try {
      final listByRepository = contentRepository
          .where((anime) => anime.title.contains(query))
          .toList()
          .cast<Anime>();

      if (listByRepository.isNotEmpty) {
        return Result.success(listByRepository);
      }

      final Response response = await contentRepository._dio.get(
        'https://api-search.anroll.net/data?q=$query',
        responseType: ResponseType.json,
      );

      final data = response.data['data'] as List;

      final List<Anime> animes = [];

      for (final map in data) {
        final String generateID = map['gen_id'];
        final String slugSerie = map['slug'];
        final int? totalOfEpisodes = map['total_eps'];
        final String synopsis = map['synopsis'];
        final String url =
            'www.anroll.net${map['friendly_path'] ?? map['generic_path']}';
        final String originalImage =
            'https://static.anroll.net/images/animes/capas/$slugSerie.jpg';

        final String title = map['title'];
        final bool isDublado = title.toLowerCase().contains('dublado');
        final String animeID = (map['id']).toString();

        Anime anime = Anime(
          animeID: animeID,
          isDublado: isDublado,
          totalOfEpisodes: totalOfEpisodes,
          url: url,
          title: title,
          sinopse: synopsis,
          slugSerie: slugSerie,
          generateID: generateID,
          releases: EpisodeReleases(),
          source: source,
          originalImage: originalImage,
        );

        animes.add(anime);
      }

      return Result.success(animes);
    } on DioException catch (_, __) {
      return Result.failure(_);
    }
  }
}
