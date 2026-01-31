// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

class AnrollSource extends RSource {
  const AnrollSource(super.contentRepository, {super.initialIndex = 0});

  @override
  Source get source => Source.ANROLL;

  @override
  Future<Result<List<Data>>> getContent(Release release) async {
    if (release is! Episode) {
      return Result.failure(
        AnimeGetDataException(message: "A instancia content precisa ser do tipo Episode"),
      );
    }

    final isMovie =
        (release.thumbnail?.contains("filmes") ?? false) || release.url.contains("/f/");

    final List<Data> data = [];

    final numberInt = release.numberInt;

    String stringNumber;

    if (numberInt < 10) {
      stringNumber = '00$numberInt';
    } else if (numberInt >= 10 && numberInt < 100) {
      stringNumber = '0$numberInt';
    } else {
      stringNumber = '$numberInt';
    }

    final part = isMovie ? "movies" : "animes";
    final part2 = isMovie ? "movie" : stringNumber;

    final videoContent =
        'https://cdn-zenitsu-2-gamabunta.b-cdn.net/cf/hls/$part/${release.slugSerie}/$part2.mp4/media-1/stream.m3u8';

    customLog(videoContent);

    data.add(
      Data.videoData(
        videoContent: videoContent,
        httpHeaders: {"origin": source.baseURL, "referer": "${source.baseURL}/"},
      ),
    );

    return Result.success(data);
  }

  Future<(Anime, String)> _getAnimeIDAndBuildId(Anime anime) async {
    if (anime.animeID == null || anime.buildId == null) {
      // try {
      //   final response = await contentRepository._dio
      //       .get("https://www.anroll.net/a/${anime.generateID}");
      //   final newAnime = anime.copyWith(
      //     animeID: parse(response.data)
      //         .querySelector('#anime_title a')
      //         ?.attributes['href']
      //         ?.split('/')
      //         .last,
      //   );

      //   final Element? element =
      //       parse(response.data).querySelector('#__NEXT_DATA__');

      //   String buildId = "";

      //   if (element == null) {
      //     throw AnrollGetIdException();
      //   } else {
      //     final map = jsonDecode(element.text);
      //     buildId = map['buildId'] as String;
      //   }

      //   return (newAnime.copyWith(buildId: buildId), buildId);
      // } catch (_) {
      //   final response = await contentRepository._dio
      //       .get("https://www.anroll.net/e/${anime.generateID}");

      //   final newAnime = anime.copyWith(
      //     animeID: parse(response.data)
      //         .querySelector('#anime_title a')
      //         ?.attributes['href']
      //         ?.split('/')
      //         .last,
      //   );
      //   final Element? element =
      //       parse(response.data).querySelector('#__NEXT_DATA__');

      //   String buildId = "";

      //   if (element == null) {
      //     throw AnrollGetIdException();
      //   } else {
      //     final map = jsonDecode(element.text);
      //     buildId = map['buildId'] as String;
      //   }

      //   return (newAnime.copyWith(buildId: buildId), buildId);
      // }

      final part = anime.isMovie ? "f" : "a";

      return await contentRepository._dio
          .get("https://www.anroll.net/$part/${anime.generateID}")
          .then(
            (response) {
              final newAnime = anime.copyWith(
                // animeID: parse(
                //   response.data,
                // ).querySelector('#anime_title a')?.attributes['href']?.split('/').last,
              );

              final Element? element = parse(
                response.data,
              ).querySelector('#__NEXT_DATA__');

              String buildId = "";
              String animeID = "";
              String generateId = "";

              if (element == null) {
                throw AnrollGetIdException();
              } else {
                final map = jsonDecode(element.text);
                buildId = map['buildId'].toString();
                animeID = anime.isMovie
                    ? map['props']['pageProps']['data']['data_movie']['id_filme']
                          .toString()
                    : map['props']['pageProps']['data']['id_serie'].toString();
                generateId =
                    anime.generateID ??
                    (anime.isMovie
                        ? map['props']['pageProps']['data']['data_movie']['id_filme']['generate_id']
                              .toString()
                        : map['props']['pageProps']['data']['generate_id'].toString());
              }

              return (
                newAnime.copyWith(
                  buildId: buildId,
                  generateID: generateId,
                  animeID: animeID,
                ),
                buildId,
              );
            },
            onError: (data) async {
              final part = anime.isMovie ? "f" : "e";
              final response = await contentRepository._dio.get(
                "https://www.anroll.net/$part/${anime.generateID}",
              );

              final newAnime = anime.copyWith(
                animeID: parse(
                  response.data,
                ).querySelector('#anime_title a')?.attributes['href']?.split('/').last,
              );

              final Element? element = parse(
                response.data,
              ).querySelector('#__NEXT_DATA__');

              String buildId = "";

              if (element == null) {
                throw AnrollGetIdException();
              } else {
                final map = jsonDecode(element.text);
                buildId = map['buildId'] as String;
              }

              return (newAnime.copyWith(buildId: buildId), buildId);
            },
          );
    }

    //   final Response response = await contentRepository._dio.get(
    //   BASE_URL,
    //   responseType: ResponseType.plain,
    // );

    // final Element? element =
    //     parse(response.data).querySelector('#__NEXT_DATA__');

    // if (element == null) {
    //   throw AnrollGetIdException();
    // } else {
    //   final map = jsonDecode(element.text);
    //   final String buildId = map['buildId'] as String;
    //   return buildId;
    // }

    return (anime, anime.buildId!);
  }

  @override
  Future<Result<Anime>> getReleases(Content content, int page) async {
    if (content is! Anime) throw AnimeGetDataException();
    Anime anime = content;
    try {
      String? animeID = anime.animeID ?? (await _getAnimeIDAndBuildId(anime)).$1.animeID;

      final episodesResponse = await contentRepository._dio.get(
        'https://apiv3-prd.anroll.net/animes/$animeID/episodes?order=asc${page == -1 ? '' : '&page=$page'}',
      );

      final episodesList = episodesResponse.data['data'] as List;

      int? totalOfEpisodes = episodesResponse.data['meta']['totalOfEpisodes'] as int?;
      int? totalOfPages = episodesResponse.data['meta']['totalOfPages'] as int?;

      final lastENumber = int.parse(episodesList.last['n_episodio']);

      anime.releases.removeWhere((element) => element.numberInt > lastENumber);

      for (final map in episodesList) {
        // final number = int.parse(map['n_episodio']);
        // final titleEpisode = map['titulo_episodio'] as String;
        final pageNumber = episodesResponse.data['meta']['pageNumber'] as int?;
        // final sinopseEpisode = map['sinopse_episodio'] as String?;
        // final episodeGenerateID = map['generate_id'] as String?;
        // final thumbnail =
        //     "https://static.anroll.net/images/animes/screens/${content.slugSerie}/${map['n_episodio']}.jpg";

        // final Episode episode = Episode(
        //   numberEpisode: number,
        //   isDublado: content.isDublado,
        //   url: '$BASE_URL/e/$episodeGenerateID',
        //   generateID: episodeGenerateID,
        //   pageNumber: pageNumber,
        //   title: titleEpisode.contains('Episódio') ? 'N/A' : titleEpisode,
        //   sinopse: sinopseEpisode,
        //   slugSerie: content.slugSerie,
        //   thumbnail: thumbnail,
        // );

        // content.releases.add(Episode.fromReleaseMap(map, content, pageNumber));
        final episode = Episode.fromReleaseMap(map, content, pageNumber);
        anime.releases.addOrUpdateWhere(episode, episode.isEqualStringID);
      }

      if (anime.animeSkip == null && anime.anilistMedia?.title?.english != null) {
        final title = anime.anilistMedia!.title!.english!;

        final result = await contentRepository._animeSkipRepository.getTimeStampsByName(
          search: title,
        );

        if (result is Success<List<AnimeSkip>>) {
          final skip = result.data.firstWhereOrNull((skip) => title.contains(skip.name));
          anime = anime.copyWith(animeSkip: skip);
        }
      }

      return Result.success(
        anime.copyWith(
          totalOfPages: totalOfPages,
          totalOfEpisodes: totalOfEpisodes,
          repoStatus: content.repoStatus.copyWith(getReleases: true),
        ),
      );
    } on DioException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<Result<Anime>> getData(Content content) async {
    try {
      if (content is! Anime) throw AnimeGetDataException();

      // String? animeID = content.animeID ?? (await _getAnimeID(content)).animeID;

      var (newAnime, _) = await _getAnimeIDAndBuildId(content);

      final String generateID =
          content.releases.firstOrNull?.generateID ?? content.generateID!;

      final animeApiUrl = 'https://apiv3-prd.anroll.net/animes/${newAnime.animeID}';
      final catchUrl =
          '${source.baseURL}/_next/data/${newAnime.buildId}/e/$generateID.json?episode=$generateID';

      final Response responseAnimeData = await contentRepository._dio
          .get(animeApiUrl, responseType: ResponseType.json)
          .catchError(
            (error) =>
                contentRepository._dio.get(catchUrl, responseType: ResponseType.json),
          );

      final animeData =
          responseAnimeData.data['data'] ??
          responseAnimeData.data['pageProps']['data'] as Map;

      final String url =
          '${source.baseURL}/a/${animeData.containsKey('anime') ? animeData['anime']['generate_id'] : animeData['generate_id']}';

      final String originalImage = newAnime.isMovie
          ? "https://static.anroll.net/images/filmes/capas/${newAnime.slugSerie}.jpg"
          : 'https://static.anroll.net/images/animes/capas/${newAnime.slugSerie}.jpg';

      final String animeID = (animeData['id_serie']).toString();

      String? sinopse = animeData['sinopse_episodio'] ?? animeData['sinopse'];

      List<Genre>? generos = animeData['generos']
          ?.toString()
          .split(',')
          .map(Genre.new)
          .toList();

      int? totalOfEpisodes = animeData['episodes'];

      newAnime = newAnime.copyWith(
        url: url,
        animeID: newAnime.animeID ?? animeID,
        genres: generos,
        totalOfEpisodes: totalOfEpisodes,
        originalImage: originalImage,
        sinopse: sinopse,
      );

      if (!newAnime.isMovie) {
        final result = await getReleases(newAnime, -1);
        result.fold(onSuccess: (data) => newAnime = data);
      }

      // Future<void> getAniListData() async {
      //   final anilistMedia = await contentRepository.getAnilistMedia(newAnime);

      //   if (anilistMedia != null) {
      //     newAnime = newAnime.copyWith(
      //       sinopse:
      //           newAnime.sinopse?.isEmpty == true || newAnime.sinopse == null
      //               ? anilistMedia.description
      //               : null,
      //       anilistMedia: AniListMedia.fromJson(
      //         AnilistMedia.toJson(anilistMedia),
      //       ),
      //       largeImage: anilistMedia.coverImage?.large,
      //       mediumImage: anilistMedia.coverImage?.medium,
      //     );
      //   }
      // }

      return Result.success(
        newAnime.copyWith(
          repoStatus: content.repoStatus.copyWith(getData: true, getReleases: true),
        ),
      );
    } on DioException catch (error) {
      return Result.failure(error);
    } on AnrollGetIdException catch (error, stack) {
      customLog('ERROR[${error.runtimeType}]: ${error.message}', stackTrace: stack);
      return Result.failure(error);
    } on AnimeGetDataException catch (error, stack) {
      customLog('ERROR[${error.runtimeType}]: ${error.message}', stackTrace: stack);
      return Result.failure(error);
    }
  }

  Future<String> getBuildId() async {
    final Response response = await contentRepository._dio.get(
      source.baseURL,
      responseType: ResponseType.plain,
    );

    final Element? element = parse(response.data).querySelector('#__NEXT_DATA__');

    if (element == null) {
      throw AnrollGetIdException();
    } else {
      final map = jsonDecode(element.text);
      final String buildId = map['buildId'] as String;
      return buildId;
    }
  }

  Map<dynamic, dynamic> _getMap(Map<dynamic, dynamic> map) {
    final responseMap = <dynamic, dynamic>{};
    if (map.containsKey("episode") && map['episode'] != null) {
      responseMap.addAll((map['episode'] as Map));
    }
    if (map.containsKey("movie") && map['movie'] != null) {
      responseMap.addAll((map['movie'] as Map));
    }

    responseMap.removeWhere((a, b) => b == null);
    return responseMap;
  }

  @override
  Future<bool> loadData() async {
    try {
      final String buildId = await getBuildId();

      final String subKey = "_next/data/$buildId/lancamentos.json";

      final String mainURL = '${source.baseURL}/$subKey';

      final Response response = await contentRepository._dio.get(
        mainURL,
        responseType: ResponseType.json,
      );

      final List<dynamic> releases =
          response.data['pageProps']['data']['data_releases'] as List<dynamic>;

      // final futures = releases.map((release) {
      //   final String title = release['episode']['anime']['titulo'] as String;
      //   final String slugSerie = release['episode']['anime']['slug_serie'];
      //   final String episodeGenerateID = release['episode']['generate_id'];
      //   final bool isDublado =
      //       ((release['episode']['anime']['dub'] as int) == 0 ? false : true) ||
      //       title.toLowerCase().contains('dublado');
      //   final String thumbnail =
      //       "https://static.anroll.net/images/animes/screens/$slugSerie/${release['episode']['n_episodio']}.jpg";
      //   final Anime anime = Anime(
      //     generateID: episodeGenerateID,
      //     originalImage: thumbnail,
      //     source: source,
      //     url: mainURL,
      //     isDublado: isDublado,
      //     slugSerie: slugSerie,
      //     title: title,
      //     releases: EpisodeReleases(),
      //     // releases: EpisodeReleases()..add(episode),
      //   );
      //   return getData(anime);
      // });

      // for (var anime in (await Future.wait(
      //   futures,
      // )).map((result) => result.fold(onSuccess: (success) => success)).nonNulls) {
      //   contentRepository.addIfNoContains(
      //     anime,
      //     (other) => other.stringID == anime.stringID,
      //   );
      // }

      for (final release in releases) {
        final map = Map.from(release);
        final responseMap = _getMap(map);

        // final episodeMap = release['episode'] as Map;
        // final movieMap = release['movie'] as Map;
        final String title = responseMap.containsKey("anime")
            ? responseMap['anime']['titulo']
            : responseMap['nome_filme'];
        final String slugSerie = responseMap.containsKey("anime")
            ? responseMap['anime']['slug_serie']
            : responseMap['slug_filme'];
        final String episodeGenerateID =
            responseMap['generate_id'] ?? responseMap['generate_id'];
        final bool isDublado = responseMap.containsKey("anime")
            ? ((responseMap['anime']['dub'] as int?) == 0 ? false : true) ||
                  title.toLowerCase().contains('dublado')
            : false;
        final int nEpisodio =
            int.tryParse(release['episode']['n_episodio'].toString()) ?? 1;
        // https://www.anroll.net/_next/image?url=
        // https://static.anroll.net/images/filmes/capas/kimetsu-no-yaiba-mugenjou-hen-akaza-sairai.jpg?w=384&q=75
        // https://static.anroll.net/images/filmes/capas/kimetsu-no-yaiba-mugenjou-hen-akaza-sairai.jpg&w=384&q=75
        String thumbnail = "";

        if (responseMap.containsKey("anime")) {
          thumbnail =
              "https://static.anroll.net/images/animes/screens/$slugSerie/${release['episode']['n_episodio']}.jpg?w=384&q=75";
        } else if (responseMap.containsKey("nome_filme")) {
          thumbnail =
              "https://static.anroll.net/images/filmes/capas/$slugSerie.jpg?w=384&q=75";
        }

        final part = responseMap.containsKey("nome_filme") ? "f" : "e";

        final Episode episode = Episode(
          slugSerie: slugSerie,
          isDublado: isDublado,
          url: '${source.baseURL}/$part/$episodeGenerateID',
          generateID: episodeGenerateID,
          title: 'Episódio $nEpisodio',
          thumbnail: thumbnail,
        );

        final part2 = responseMap.containsKey("nome_filme") ? "f" : "a";

        final String subKey =
            '_next/data/$buildId/$part2/$episodeGenerateID.json?episode=$episodeGenerateID';

        final String mainURL = '${source.baseURL}/$subKey';

        final Anime anime = Anime(
          generateID: episodeGenerateID,
          originalImage: thumbnail,
          source: source,
          url: mainURL,
          isMovie: responseMap.containsKey("nome_filme"),
          isDublado: isDublado,
          slugSerie: slugSerie,
          title: title,
          repoStatus: RepositoryStatus(loadData: true),
          releases: EpisodeReleases()..add(episode),
        );

        // await getData(anime);

        contentRepository.addIfNoContains(
          anime,
          (other) => other.stringID == anime.stringID,
        );
      }
      contentRepository.isSuccess = true;
      contentRepository._hasMore = false;
      contentRepository.fullScreenError = null;
      return Future.value(true);
    } on AnrollGetIdException catch (error) {
      contentRepository.fullScreenError = error;
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    } on DioException catch (error) {
      contentRepository.fullScreenError = error;
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    }
  }

  @override
  Future<Result<SearchResult>> search(SearchFilter filter) async {
    try {
      final query = filter.query;
      final listByRepository = contentRepository
          .where((anime) => anime.title.contains(query))
          .toList()
          .cast<Anime>();

      if (listByRepository.isNotEmpty) {
        return Result.success(
          SearchResult(contents: SplayTreeSet.from(listByRepository), page: 0),
        );
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
        final String url = 'www.anroll.net${map['friendly_path'] ?? map['generic_path']}';
        final String originalImage =
            'https://static.anroll.net/images/animes/capas/$slugSerie.jpg';

        final String title = map['title'];
        final bool isDublado = title.toLowerCase().contains('dublado');
        final String animeID = (map['id']).toString();

        Anime anime = Anime(
          animeID: animeID,
          isDublado: isDublado,
          totalOfEpisodes: totalOfEpisodes ?? 0,
          url: url,
          title: title,
          sinopse: synopsis,
          slugSerie: slugSerie,
          generateID: generateID,
          releases: EpisodeReleases(),
          source: source,
          repoStatus: RepositoryStatus(searchContents: true),
          originalImage: originalImage,
        );

        animes.add(anime);
      }

      return Result.success(SearchResult(contents: SplayTreeSet.from(animes), page: 0));
    } on DioException catch (error) {
      return Result.failure(error);
    }
  }
}
