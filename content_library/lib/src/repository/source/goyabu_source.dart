// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

class GoyabuSource extends RSource {
  GoyabuSource(super.contentRepository, {super.initialIndex = 0});

  @override
  Source get source => Source.GOYABU;

  @override
  String get BASE_URL => source.baseURL;

  @override
  Future<Result<List<Data>>> getContent(Release release) async {
    if (release is! Episode) {
      return Result.failure(AnimeGetDataException(message: "A instancia content precisa ser do tipo Episode"));
    }

    try {
      final List<Data> data = [];

      final Response response = await contentRepository._dio.get(release.url, responseType: ResponseType.plain);
      final Document document = parse(response.data);

      final fremeSrc = document.querySelector('.metaframe.rptss')?.attributes['src'];

      if (fremeSrc != null) {
        Completer<Data> completer = Completer();

        final controller = WebViewController()
          ..loadRequest(
            Uri.parse(fremeSrc),
            headers: {
              'Access-Control-Allow-Origin': '*',
              "Accept":
                  "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
            },
          )
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setUserAgent(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
          );

        await controller.setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
            onPageFinished: (url) async {
              if (completer.isCompleted) return;
              // await Future.wait([
              //   contentRepository._dio.post(
              //       r'https://jnn-pa.googleapis.com/$rpc/google.internal.waa.v1.Waa/Create',
              //       responseType: ResponseType.json,
              //       data: jsonEncode(["O43z0dpjhgX20SCx4KAo"]),
              //       headers: {
              //         "Content-Type": "application/json+protobuf",
              //         "X-Goog-Api-Key": "AIzaSyDyT5W0Jh49F30Pqqtyfdf7pDLFKLJoAnw"
              //       }),
              //   contentRepository._dio.post(
              //       r'https://jnn-pa.googleapis.com/$rpc/google.internal.waa.v1.Waa/GenerateIT',
              //       responseType: ResponseType.json,
              //       data: jsonEncode(["O43z0dpjhgX20SCx4KAo"]),
              //       headers: {
              //         "Content-Type": "application/json+protobuf",
              //         "X-Goog-Api-Key": "AIzaSyDyT5W0Jh49F30Pqqtyfdf7pDLFKLJoAnw"
              //       }),
              // ]);
              await controller.runJavaScript(r'''document.querySelector('.play-button').click();''');

              await Future.delayed(const Duration(seconds: 2));

              var videoConfig = await controller.runJavaScriptReturningResult(r"VIDEO_CONFIG;");

              final videoConfigJson = jsonDecode(videoConfig.toString());
              final playURL = (videoConfigJson['streams'] as List).first['play_url'] as String;
              if (completer.isCompleted) return;
              completer.complete(
                Data.videoData(
                  videoContent: playURL,
                  httpHeaders: const {
                    "User-Agent":
                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
                  },
                ),
              );
            },
          ),
        );

        data.add(await completer.future);
      }

      return Result.success(data);
    } on DioException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<Result<Content>> getReleases(Content content, int page) async {
    if (content is! Anime) throw AnimeGetDataException();

    final Releases cacheRelease = Releases();

    try {
      final Response response = await contentRepository._dio.get(content.url, responseType: ResponseType.plain);

      final Document document = parse(response.data);

      final Element? pageElement = document.querySelector('.rwl');

      if (pageElement == null) throw Exception('Element[rwl] == null');

      final ScrapingUtil scrapingUtil = ScrapingUtil(pageElement);

      final episodesElements = scrapingUtil.element.querySelectorAll('.listaEps li');

      for (final episodeElement in episodesElements) {
        final ScrapingUtil episodeScrapingUtil = ScrapingUtil(episodeElement);

        final int? numberEpisode = int.tryParse(
          episodeScrapingUtil.getByText(selector: 'a').trim().split('-').last.replaceAll(RegExp(r'[^0-9]'), ''),
        );

        final String episodeURL = episodeScrapingUtil.getURL(selector: 'a');

        final Episode episode = Episode(
          url: episodeURL,
          numberEpisode: numberEpisode,
          title: 'N/A',
          isDublado: content.isDublado,
        );

        if (!cacheRelease.contains(episode)) cacheRelease.add(episode);
      }

      return Result.success(content.copyWith(releases: cacheRelease));
    } on DioException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<Result<Content>> getData(Content content) async {
    try {
      if (content is! Anime) throw AnimeGetDataException();

      final Response<dynamic> responseAnimeURL = await contentRepository._dio.get(
        content.releases.first.url,
        responseType: ResponseType.plain,
      );

      final Document episodeDocument = parse(responseAnimeURL.data);

      final String animeURL = episodeDocument.querySelectorAll('.paginationEP a').elementAt(1).attributes['href']!;

      final Anime anime = content.copyWith(releases: EpisodeReleases(), url: animeURL);

      final Response response = await contentRepository._dio.get(anime.url, responseType: ResponseType.plain);

      final Document document = parse(response.data);

      final Element? pageElement = document.querySelector('.rwl');

      if (pageElement == null) {
        throw AnimeGetDataException(message: 'Element[rwl] == null');
      }

      final ScrapingUtil scrapingUtil = ScrapingUtil(pageElement);

      final String originalImage = scrapingUtil.getImage(selector: '.thumb img');
      final String sinopse = scrapingUtil.getByText(selector: '.sinopse h3');

      final List<Genre> genres = scrapingUtil.element
          .querySelectorAll('.genres a')
          .map((element) => Genre(element.text.trim()))
          .toList();

      final List<Element> episodesElements = scrapingUtil.element.querySelectorAll('.listaEps li');

      for (final Element episodeElement in episodesElements) {
        final ScrapingUtil episodeScrapingUtil = ScrapingUtil(episodeElement);

        final int? numberEpisode = int.tryParse(
          episodeScrapingUtil.getByText(selector: 'a').trim().split('-').last.replaceAll(RegExp(r'[^0-9]'), ''),
        );

        final String episodeURL = episodeScrapingUtil.getURL(selector: 'a');

        final Episode episode = Episode(
          url: episodeURL,
          numberEpisode: numberEpisode,
          title: 'N/A',
          isDublado: anime.isDublado,
        );

        anime.releases.addIfNoContains(episode);
      }

      final Anime newAnime = anime.copyWith(
        totalOfEpisodes: anime.releases.length,
        originalImage: originalImage,
        genres: genres,
        sinopse: sinopse,
      );
      return Result.success(newAnime);
    } on DioException catch (error) {
      return Result.failure(error);
    } on AnimeGetDataException catch (error, stack) {
      customLog('ERROR[${error.runtimeType}]: ${error.message}', stackTrace: stack);
      return Result.failure(error);
    }
  }

  @override
  Future<bool> loadData() async {
    if (contentRepository.addMore) contentRepository.index++;

    try {
      final String subKey = "lancamentos/page/${contentRepository.index}";

      final String mainURL = '$BASE_URL/$subKey';

      final Response response = await contentRepository._dio.get(mainURL, responseType: ResponseType.plain);

      final Document document = parse(response.data);

      final List<Element> elements = document.querySelectorAll('.boxEP');

      if (elements.isEmpty) {
        throw GoyabuLoadDataException(message: 'elements é vazio');
      }

      for (final Element element in elements) {
        final ScrapingUtil scrapingUtil = ScrapingUtil(element);

        final String episodeURL = scrapingUtil.getURL(selector: '.boxEP a');
        final String thumbnail = scrapingUtil.getImage(selector: 'img');
        final String episodeTitle = scrapingUtil.getByText(selector: '.titleEP');
        final bool isDublado = (element.attributes['data-tar']?.toLowerCase().contains('dub')) ?? false;

        final Episode episode = Episode(
          isDublado: isDublado,
          url: episodeURL,
          title: episodeTitle,
          thumbnail: thumbnail,
        );

        final String animeTitle = scrapingUtil.getByText(selector: '.title');

        final Anime anime = Anime(
          title: animeTitle,
          releases: EpisodeReleases()..add(episode),
          source: source,
          url: '',
          originalImage: thumbnail,
        );
        contentRepository.addIfNoContains(anime);
      }

      contentRepository.isSuccess = true;
      contentRepository._hasMore = true;
      contentRepository.fullScreenError = null;
      return Future.value(true);
    } on DioException catch (error) {
      contentRepository.fullScreenError = error;
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    } on GoyabuLoadDataException catch (error) {
      contentRepository.fullScreenError = error;
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    }
  }

  @override
  Future<Result<List<Content>>> search(String query) async {
    return Result.failure(Exception('UnimplementedError'));
  }
}
