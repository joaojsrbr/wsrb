// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

@SourceEntry(
  label: 'Goyabu',
  id: 'goyabu',
  baseUrl: App.GOYABU_URL,
  contentType: ContentType.ANIME,
)
class GoyabuSource extends RSource {
  GoyabuSource(super.context, {super.initialIndex = 0});

  @override
  Source get source => Source.GOYABU;

  @override
  Future<Result<List<Data>>> getReleaseData(Release release) async {
    if (release is! Episode) {
      return Result.failure(
        AnimeGetDataException(
          message: "A instancia content precisa ser do tipo Episode",
        ),
      );
    }

    try {
      final List<Data> data = [];

      final parser = await context.session.fetchDocument(
        Uri.parse(release.url),
        captchaHandler: HumanCaptchaHandler(
          context: context.anchor.currentContext,
        ),
      );

      final fremeSrc = parser.queryAttr(".metaframe.rptss", "src");

      if (fremeSrc != null) {
        final acoes = <DomAction>[
          ExecuteScriptAction(
            "document.querySelector('.play-button').click();",
          ),
          WaitAction(const Duration(seconds: 2)),
          ExecuteScriptAction("VIDEO_CONFIG;", resultKey: "VIDEO_CONFIG"),
        ];
        final result = await context.session.executeActionsAndScrape(
          url: Uri.parse(fremeSrc),
          actions: acoes,
        );

        final playURL =
            (result['VIDEO_CONFIG']['streams'] as List).first['play_url']
                as String;

        final videoData = Data.videoData(
          videoContent: playURL,
          httpHeaders: App.HEADERS,
        );
        data.add(videoData);
      }

      await context.session.closePage();

      return Result.success(data);
    } on DioException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<Result<Content>> getContentReleases(Content content, int page) async {
    if (content is! Anime) throw AnimeGetDataException();

    final EpisodeReleases cacheRelease = EpisodeReleases();

    try {
      final Response response = await context.dio.get(
        content.url,
        responseType: ResponseType.plain,
      );

      final Document document = parse(response.data);

      final Element? pageElement = document.querySelector('.rwl');

      if (pageElement == null) throw Exception('Element[rwl] == null');

      final ScrapingUtil scrapingUtil = ScrapingUtil(pageElement);

      final episodesElements = scrapingUtil.element.querySelectorAll(
        '.listaEps li',
      );

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

      return Result.success(
        content.copyWith(
          releases: cacheRelease,
          repoStatus: content.repoStatus.copyWith(getReleases: true),
        ),
      );
    } on DioException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<Result<Content>> getDetails(Content content) async {
    try {
      if (content is! Anime) throw AnimeGetDataException();

      final Response<dynamic> responseAnimeURL = await context.dio.get(
        content.releases.first.url,
        responseType: ResponseType.plain,
      );

      final Document episodeDocument = parse(responseAnimeURL.data);

      final elements = episodeDocument.querySelectorAll('.paginationEP a');
      if (elements.length < 2) {
        throw GoyabuLoadDataException(message: 'paginationEP a: expected at least 2 elements, got ${elements.length}');
      }
      final String animeURL = elements[1].attributes['href']!;

      final Anime anime = content.copyWith(
        releases: EpisodeReleases(),
        url: animeURL,
      );

      final Response response = await context.dio.get(
        anime.url,
        responseType: ResponseType.plain,
      );

      final Document document = parse(response.data);

      final Element? pageElement = document.querySelector('.rwl');

      if (pageElement == null) {
        throw AnimeGetDataException(message: 'Element[rwl] == null');
      }

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
        repoStatus: anime.repoStatus.copyWith(getData: true, getReleases: true),
      );
      return Result.success(newAnime);
    } on DioException catch (error) {
      return Result.failure(error);
    } on AnimeGetDataException catch (error, stack) {
      customLog(
        'ERROR[${error.runtimeType}]: ${error.message}',
        stackTrace: stack,
      );
      return Result.failure(error);
    }
  }

  @override
  Future<bool> loadPage([int page = 0]) async {
    final state = context.state;
    if (state.addMore) {
      state.index++;
    }

    try {
      final String subKey = "lancamentos/page/${state.index}";

      final String mainURL = '${source.baseUrl}/$subKey';

      final Response response = await context.dio.get(
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

        final episodeURL = parser.queryAttr(".boxEP a", "href");
        final thumbnail = parser.getImage('img');
        final episodeTitle = parser.queryText('.titleEP');
        final isDublado =
            (element.attributes['data-tar']?.toLowerCase().contains('dub')) ??
            false;
        final animeTitle = parser.queryText('.title');

        if (episodeURL == null || episodeTitle == null || animeTitle == null) {
          continue;
        }

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
          repoStatus: RepositoryStatus(loadData: true),
        );
        context.addIfNoContains(anime);
      }

      context.state.onSuccess();
      return true;
    } on DioException catch (error) {
      context.state.onError(error);
      return false;
    } on GoyabuLoadDataException catch (error) {
      context.state.onError(error);
      return false;
    }
  }

  @override
  Future<Result<SearchResult>> search(SearchFilter filter) async {
    return Result.failure(Exception('UnimplementedError'));
  }

  @override
  Future<Result<List<Filter>>> getFilters() async {
    const filters = [
      Filter(
        id: 'genre',
        label: 'Gênero',
        type: FilterType.genre,
        options: [
          FilterOption(id: 'action', label: 'Ação'),
          FilterOption(id: 'adventure', label: 'Aventura'),
          FilterOption(id: 'comedy', label: 'Comédia'),
          FilterOption(id: 'drama', label: 'Drama'),
          FilterOption(id: 'ecchi', label: 'Ecchi'),
          FilterOption(id: 'fantasy', label: 'Fantasia'),
          FilterOption(id: 'horror', label: 'Terror'),
          FilterOption(id: 'magic', label: 'Magia'),
          FilterOption(id: 'mecha', label: 'Mecha'),
          FilterOption(id: 'music', label: 'Música'),
          FilterOption(id: 'mystery', label: 'Mistério'),
          FilterOption(id: 'psychological', label: 'Psicológico'),
          FilterOption(id: 'romance', label: 'Romance'),
          FilterOption(id: 'sci-fi', label: 'Ficção Científica'),
          FilterOption(id: 'slice-of-life', label: 'Slice of Life'),
          FilterOption(id: 'sports', label: 'Esportes'),
          FilterOption(id: 'supernatural', label: 'Sobrenatural'),
          FilterOption(id: 'thriller', label: 'Thriller'),
        ],
      ),
      Filter(id: 'year', label: 'Ano', type: FilterType.year),
      Filter(
        id: 'status',
        label: 'Status',
        type: FilterType.status,
        options: [
          FilterOption(id: 'ongoing', label: 'Em andamento'),
          FilterOption(id: 'completed', label: 'Concluído'),
          FilterOption(id: 'upcoming', label: 'Em breve'),
        ],
      ),
      Filter(
        id: 'type',
        label: 'Tipo',
        type: FilterType.type,
        options: [
          FilterOption(id: 'anime', label: 'Anime'),
          FilterOption(id: 'ova', label: 'OVA'),
          FilterOption(id: 'movie', label: 'Filme'),
          FilterOption(id: 'special', label: 'Especial'),
        ],
      ),
      Filter(
        id: 'order',
        label: 'Ordenar por',
        type: FilterType.order,
        options: [
          FilterOption(id: 'date', label: 'Data'),
          FilterOption(id: 'name', label: 'Nome'),
          FilterOption(id: 'views', label: 'Visualizações'),
        ],
      ),
      Filter(id: 'letter', label: 'Letra', type: FilterType.letter),
    ];

    return Result.success(filters);
  }
}
