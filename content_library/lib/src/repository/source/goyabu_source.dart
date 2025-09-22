// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

class GoyabuSource extends RSource {
  GoyabuSource(super.contentRepository, {super.initialIndex = 0});

  @override
  Source get source => Source.GOYABU;

  @override
  Future<Result<List<Data>>> getContent(Release release) async {
    if (release is! Episode) {
      return Result.failure(
        AnimeGetDataException(message: "A instancia content precisa ser do tipo Episode"),
      );
    }

    try {
      final List<Data> data = [];

      final parser = await contentRepository.session.fetchDocument(
        Uri.parse(release.url),
        captchaHandler: HumanCaptchaHandler(
          context: contentRepository.anchor.currentContext,
        ),
      );

      final fremeSrc = parser.queryAttr(".metaframe.rptss", "src");

      if (fremeSrc != null) {
        final acoes = <DomAction>[
          ExecuteScriptAction("document.querySelector('.play-button').click();"),
          WaitAction(const Duration(seconds: 2)),
          ExecuteScriptAction("VIDEO_CONFIG;", resultKey: "VIDEO_CONFIG"),
        ];
        final result = await contentRepository.session.executeActionsAndScrape(
          url: Uri.parse(fremeSrc),
          actions: acoes,
        );

        final playURL =
            (result['VIDEO_CONFIG']['streams'] as List).first['play_url'] as String;

        final videoData = Data.videoData(videoContent: playURL, httpHeaders: App.HEADERS);
        data.add(videoData);
      }

      await contentRepository.session.closePage();

      return Result.success(data);
    } on DioException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<Result<Content>> getReleases(Content content, int page) async {
    if (content is! Anime) throw AnimeGetDataException();

    final EpisodeReleases cacheRelease = EpisodeReleases();

    try {
      final Response response = await contentRepository._dio.get(
        content.url,
        responseType: ResponseType.plain,
      );

      final Document document = parse(response.data);

      final Element? pageElement = document.querySelector('.rwl');

      if (pageElement == null) throw Exception('Element[rwl] == null');

      final ScrapingUtil scrapingUtil = ScrapingUtil(pageElement);

      final episodesElements = scrapingUtil.element.querySelectorAll('.listaEps li');

      for (final episodeElement in episodesElements) {
        final ScrapingUtil episodeScrapingUtil = ScrapingUtil(episodeElement);

        final int? numberEpisode = int.tryParse(
          episodeScrapingUtil
              .getByText(selector: 'a')
              .trim()
              .split('-')
              .last
              .replaceAll(RegExp(r'[^0-9]'), ''),
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

      final String animeURL = episodeDocument
          .querySelectorAll('.paginationEP a')
          .elementAt(1)
          .attributes['href']!;

      final Anime anime = content.copyWith(releases: EpisodeReleases(), url: animeURL);

      final Response response = await contentRepository._dio.get(
        anime.url,
        responseType: ResponseType.plain,
      );

      final Document document = parse(response.data);

      final Element? pageElement = document.querySelector('.rwl');

      if (pageElement == null) {
        throw AnimeGetDataException(message: 'Element[rwl] == null');
      }

      // final ScrapingUtil scrapingUtil = ScrapingUtil(pageElement);

      final parser = HtmlParser.fromElement(pageElement);

      final String originalImage = parser.getImage('.thumb img');
      final sinopse = parser.query('.sinopse h3')?.text;

      final List<Genre> genres = parser
          .queryAll(".genres a")
          .map((e) => e.text)
          .nonNulls
          .map(Genre.new)
          .toList();

      final List<HtmlParser> episodesElements = parser.queryAll('.listaEps li');

      for (final HtmlParser parser in episodesElements) {
        // final ScrapingUtil episodeScrapingUtil = ScrapingUtil(episodeElement);
        // final parser = HtmlParser.fromElement(parser);

        final int? numberEpisode = int.tryParse(
          parser
                  .queryText('a')
                  ?.trim()
                  .split('-')
                  .last
                  .replaceAll(RegExp(r'[^0-9]'), '') ??
              "",
        );

        final episodeURL = parser.queryAttr('a', "href");

        if (episodeURL == null) continue;

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

      final String mainURL = '${source.baseURL}/$subKey';

      final Response response = await contentRepository._dio.get(
        mainURL,
        responseType: ResponseType.plain,
      );

      final Document document = parse(response.data);

      final List<Element> elements = document.querySelectorAll('.boxEP');

      if (elements.isEmpty) {
        throw GoyabuLoadDataException(message: 'elements é vazio');
      }

      for (final Element element in elements) {
        final parser = HtmlParser.fromElement(element);
        // final ScrapingUtil scrapingUtil = ScrapingUtil(element);

        // final String episodeURL = scrapingUtil.getURL(selector: '.boxEP a');
        // final String thumbnail = scrapingUtil.getImage(selector: 'img');
        // final String episodeTitle = scrapingUtil.getByText(selector: '.titleEP');
        // final String animeTitle = scrapingUtil.getByText(selector: '.title');

        final episodeURL = parser.queryAttr(".boxEP a", "href");
        final thumbnail = parser.getImage('img');
        final episodeTitle = parser.queryText('.titleEP');
        final isDublado =
            (element.attributes['data-tar']?.toLowerCase().contains('dub')) ?? false;
        final animeTitle = parser.queryText('.title');

        if (episodeURL == null || episodeTitle == null || animeTitle == null) continue;

        final Episode episode = Episode(
          isDublado: isDublado,
          url: episodeURL,
          title: episodeTitle,
          thumbnail: thumbnail,
        );

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
  Future<Result<SearchResult>> search(SearchFilter filter) async {
    return Result.failure(Exception('UnimplementedError'));
  }
}
