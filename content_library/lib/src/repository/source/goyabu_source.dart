// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

class GoyabuSource extends RSource {
  GoyabuSource(
    super.contentRepository, {
    super.initialIndex = 0,
  });

  @override
  Future<Result<List<Data>>> getContent(Release release) async {
    bool isEpisode() {
      return release is Episode;
    }

    assert(
      isEpisode(),
      "A instancia content precisa ser do tipo [$Episode]",
    );

    try {
      final episode = release as Episode;

      final List<Data> data = [];

      final Response response = await contentRepository._dio.get(
        episode.url,
        responseType: ResponseType.plain,
      );
      final Document document = parse(response.data);

      final fremeSrc =
          document.querySelector('.metaframe.rptss')?.attributes['src'];

      if (fremeSrc != null) {
        final Completer completer = Completer();

        final controller = WebViewController()
          ..loadRequest(Uri.parse(fremeSrc), headers: {
            'Access-Control-Allow-Origin': '*',
            "Accept":
                "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
          })
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setUserAgent(
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36");

        await controller.setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) async {
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
            await controller.runJavaScript(
                r'''document.querySelector('.play-button').click();''');

            var videoConfig =
                await controller.runJavaScriptReturningResult(r"VIDEO_CONFIG;");

            final videoConfigJson = jsonDecode(videoConfig.toString());
            final playURL = (videoConfigJson['streams'] as List)
                .first['play_url'] as String;

            data.add(Data.videoData(
              videoContent: playURL,
              httpHeaders: const {
                "User-Agent":
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
              },
            ));
            completer.complete();
          },
        ));

        await completer.future;
      }

      return Result.success(data);
    } on DioException catch (_, __) {
      return Result.failure(_);
    }
  }

  @override
  Future<Result<Content>> getReleases(Content content, int page) async {
    bool isAnime() => content is Anime;
    assert(
      isAnime(),
      "A instancia content precisa ser do tipo Anime",
    );

    final Releases cacheRelease = Releases();

    try {
      final Anime anime = content as Anime;

      final Response response = await contentRepository._dio.get(
        anime.url,
        responseType: ResponseType.plain,
      );

      final Document document = parse(response.data);

      final Element? pageElement = document.querySelector('.rwl');

      if (pageElement == null) throw Exception('Element[rwl] == null');

      final ScrapingUtil scrapingUtil = ScrapingUtil(pageElement);

      final episodesElements =
          scrapingUtil.element.querySelectorAll('.listaEps li');

      for (final episodeElement in episodesElements) {
        final ScrapingUtil episodeScrapingUtil = ScrapingUtil(episodeElement);

        final int? numberEpisode = int.tryParse(episodeScrapingUtil
            .getByText(selector: 'a')
            .trim()
            .split('-')
            .last
            .replaceAll(RegExp(r'[^0-9]'), ''));

        final String episodeURL = episodeScrapingUtil.getURL(selector: 'a');

        final Episode episode = Episode(
          url: episodeURL,
          numberEpisode: numberEpisode,
          title: 'N/A',
          isDublado: anime.isDublado,
        );

        if (!cacheRelease.contains(episode)) cacheRelease.add(episode);
      }

      return Result.success(
        anime.copyWith(
          releases: cacheRelease.partition(20)[page],
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
      final Episode episodeURL = (content as Anime).releases.first as Episode;

      final responseAnimeURL = await contentRepository._dio.get(
        episodeURL.url,
        responseType: ResponseType.plain,
      );

      final Document episodeDocument = parse(responseAnimeURL.data);

      final String animeURL = episodeDocument
          .querySelectorAll('.paginationEP a')[1]
          .attributes['href']!;

      final Anime anime = content.copyWith(
        releases: Releases(),
        url: animeURL,
      );

      final Response response = await contentRepository._dio.get(
        anime.url,
        responseType: ResponseType.plain,
      );

      final Document document = parse(response.data);

      final Element? pageElement = document.querySelector('.rwl');

      if (pageElement == null) throw Exception('Element[rwl] == null');

      final ScrapingUtil scrapingUtil = ScrapingUtil(pageElement);

      final String originalImage =
          scrapingUtil.getImage(selector: '.thumb img');
      final String sinopse = scrapingUtil.getByText(selector: '.sinopse h3');

      final List<Genre> genres = scrapingUtil.element
          .querySelectorAll('.genres a')
          .map((element) => Genre(element.text.trim()))
          .toList();

      final episodesElements =
          scrapingUtil.element.querySelectorAll('.listaEps li');

      // final bool isDublado = scrapingUtil.element
      //         .querySelector('.genres.ghs li')
      //         ?.text
      //         .trim()
      //         .toLowerCase()
      //         .contains('dub') ??
      //     false;

      for (final episodeElement in episodesElements) {
        final ScrapingUtil episodeScrapingUtil = ScrapingUtil(episodeElement);

        final int? numberEpisode = int.tryParse(episodeScrapingUtil
            .getByText(selector: 'a')
            .trim()
            .split('-')
            .last
            .replaceAll(RegExp(r'[^0-9]'), ''));

        final String episodeURL = episodeScrapingUtil.getURL(selector: 'a');

        final Episode episode = Episode(
          url: episodeURL,
          numberEpisode: numberEpisode,
          title: 'N/A',
          isDublado: anime.isDublado,
        );

        if (!anime.releases.contains(episode)) anime.releases.add(episode);
      }

      final Anime newAnime = anime.copyWith(
        totalOfEpisodes: anime.releases.length,
        originalImage: originalImage,
        genres: genres,
        sinopse: sinopse,
      );
      return Result.success(newAnime);
    } on DioException catch (_, __) {
      return Result.failure(_);
    } on Exception catch (_, __) {
      return Result.failure(_);
    }
  }

  @override
  Future<bool> loadData() async {
    if (contentRepository.addMore) contentRepository.index++;

    try {
      final subKey = "lancamentos/page/${contentRepository.index}";

      final String mainURL = '$BASE_URL/$subKey';

      final Response response = await contentRepository._dio.get(
        mainURL,
        responseType: ResponseType.plain,
      );

      final Document document = parse(response.data);

      final List<Element> elements = document.querySelectorAll('.boxEP');

      if (elements.isEmpty) {
        contentRepository.isSuccess = false;
        contentRepository._hasMore = false;
        return Future.value(false);
      }

      for (final Element element in elements) {
        final Releases releases = Releases();

        final ScrapingUtil scrapingUtil = ScrapingUtil(element);

        final String episodeURL = scrapingUtil.getURL(selector: '.boxEP a');
        final String thumbnail = scrapingUtil.getImage(selector: 'img');
        final String episodeTitle =
            scrapingUtil.getByText(selector: '.titleEP');
        final bool isDublado =
            (element.attributes['data-tar']?.toLowerCase().contains('dub')) ??
                false;

        final Episode episode = Episode(
          isDublado: isDublado,
          url: episodeURL,
          title: episodeTitle,
          thumbnail: thumbnail,
        );

        if (!releases.contains(episode)) releases.add(episode);

        final String animeTitle = scrapingUtil.getByText(selector: '.title');

        //  '$BASE_URL/anime/${animeTitle.trim().toLowerCase().replaceAll(' ', '-')}';

        final Anime anime = Anime(
          title: animeTitle,
          releases: releases,
          source: source,
          url: '',
          originalImage: thumbnail,
        );
        if (!contentRepository.contains(anime)) contentRepository.add(anime);
      }

      contentRepository.isSuccess = true;
      contentRepository._hasMore = true;
      contentRepository.fullScreenError = null;

      return Future.value(true);
    } on DioException catch (_, __) {
      contentRepository.fullScreenError = _;
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    }
  }

  @override
  Source get source => Source.GOYABU;

  @override
  String get BASE_URL => source.baseURL;
}
