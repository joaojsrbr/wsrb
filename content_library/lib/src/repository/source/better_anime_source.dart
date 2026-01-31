// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names

part of '../content_repository.dart';

class BetterAnimeSource extends RSource {
  const BetterAnimeSource(super.contentRepository, {super.initialIndex = 1});

  @override
  Source get source => Source.BETTER_ANIME;

  @override
  Future<Result<Content>> getData(Content content) async {
    try {
      if (content is! Anime) throw GetDataException();
      // if (await _requiresCaptcha()) throw GetDataException();

      final parser = await _fetchHtml(content.url);
      final updatedAnime = _extractAnimeInfo(parser.document, content);

      final episodes = _extractEpisodes(parser, content.isDublado);
      updatedAnime.releases.addOrUpdateMany(episodes, (a, b) => b.isEqualStringID(a));

      return Result.success(
        updatedAnime.copyWith(
          repoStatus: content.repoStatus.copyWith(getData: true, getReleases: true),
        ),
      );
    } on DioException catch (error) {
      return Result.failure(error);
    } on GetDataException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<Result<Content>> getReleases(Content content, int page) async {
    try {
      if (content is! Anime) throw GetDataException();
      // if (await _requiresCaptcha()) throw GetDataException();

      final parser = await _fetchHtml(content.url);
      final episodes = _extractEpisodes(parser, content.isDublado);

      content.releases.addOrUpdateMany(episodes, (a, b) => a.isEqualStringID(b));
      return Result.success(
        content.copyWith(repoStatus: content.repoStatus.copyWith(getReleases: true)),
      );
    } on DioException catch (error) {
      return Result.failure(error);
    } on GetDataException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<Result<List<Data>>> getContent(Release release) async {
    try {
      // if (await _requiresCaptcha()) throw LoadDataException();
      Element? script;

      final parser = await _fetchHtml(release.url);

      script = parser.document
          .getElementsByTagName('script')
          .firstWhereOrNull((el) => el.text.contains('_token'));

      if (script == null) {
        await contentRepository.session.closePage();
        throw Exception("Script com token não encontrado");
      }

      final token = _extractToken(script.text);
      final qualities = _extractQualities(script.text);

      if (token == null || qualities.isEmpty) {
        throw Exception("Token ou qualidades não encontrados");
      }

      final videos = await _fetchAllQualities(qualities, token, release.url);
      final result = videos.reversed.whereType<VideoData>().toList();
      await contentRepository.session.closePage();
      return result.isNotEmpty
          ? Result.success(result)
          : Result.failure(Exception("Nenhum vídeo encontrado"));
    } on DioException catch (error) {
      return Result.failure(error);
    } on LoadDataException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<bool> loadData() async {
    try {
      // if (await _requiresCaptcha()) throw LoadDataException();

      if (contentRepository.addMore) {
        contentRepository.totalPerPage.add(contentRepository.length);
        contentRepository.index++;
      }

      final url =
          'https://betteranime.net/ultimosLancamentos?page=${contentRepository.index}';
      final parser = await _fetchHtml(url);

      // final list = document.querySelector("div.list-animes")?.children ?? [];
      final list = parser.selectOne("div.list-animes")?.children ?? [];

      for (final element in list) {
        final parser = HtmlParser.fromElement(element);
        final originalImage = parser.queryAttr(".card-img img", "src");

        final episodeUrl = parser.queryAttr("a", "href");
        final episodeTitle = parser.queryText("a h4");
        final animeTitle = parser.queryText("a h3");

        if (episodeUrl == null || episodeTitle == null || animeTitle == null) continue;

        final parts = episodeUrl.split(RegExp(r'(?<!/)/(?!/)'));
        final isDublado = parts.contains("dublado");
        final animeUrl = parts.sublist(0, parts.length - 1).join("/");
        final slugSerie = parts[parts.length - 2];

        final anime = Anime(
          slugSerie: slugSerie,
          url: animeUrl,
          title: animeTitle,
          isDublado: isDublado,
          originalImage: "https:$originalImage",
          repoStatus: RepositoryStatus(loadData: true),
          releases: EpisodeReleases()
            ..add(
              Episode(
                url: episodeUrl,
                title: episodeTitle,
                isDublado: isDublado,
                thumbnail: "https:$originalImage",
              ),
            ),
          source: source,
        );

        contentRepository.addIfNoContains(anime);
      }

      contentRepository
        ..isSuccess = true
        .._hasMore = true
        ..fullScreenError = null;

      return true;
    } on Exception catch (error) {
      contentRepository
        ..isSuccess = false
        .._hasMore = false
        ..fullScreenError = error;

      return false;
    }
  }

  @override
  Future<Result<SearchResult>> search(SearchFilter filter) async {
    try {
      final query = filter.query;
      final page = filter.page;
      final List<Content> data = [];

      final url = 'https://betteranime.net/pesquisa?searchTerm=$query&page=$page';

      final parser = await _fetchHtml(url);

      final list = parser.selectOne("div.list-animes")?.children ?? [];

      final totalOfPages = parser
          .selectAll(".page-item")
          .map((e) => int.tryParse(e.text.trim()))
          .nonNulls
          .lastOrNull;

      // final activePage = int.tryParse(
      //   parser.selectOne(".page-item .active span")?.text ?? "",
      // );

      for (final element in list) {
        final parser = HtmlParser.fromElement(element);
        final originalImage = parser.queryAttr(".card-vertical-img img", "src");

        // final episodeUrl = parser.queryAttr("a", "href");
        final animeUrl = parser.queryAttr("a", "href");

        final animeTitle = parser.queryText("a h3");

        if (animeUrl == null || animeTitle == null) continue;
        final slugSerie = animeTitle.toID;

        // final parts = episodeUrl.split(RegExp(r'(?<!/)/(?!/)'));
        final isDublado = parser.queryText(".card-info")?.contains("DUB") ?? false;

        final anime = Anime(
          slugSerie: slugSerie,
          url: animeUrl,
          title: animeTitle,
          isDublado: isDublado,
          originalImage: "https:$originalImage",
          releases: EpisodeReleases(),
          repoStatus: RepositoryStatus(searchContents: true),
          source: Source.BETTER_ANIME,
        );

        data.add(anime);
      }

      await contentRepository.session.closePage();
      return Result.success(
        SearchResult(
          contents: SplayTreeSet.from(data),
          page: page,
          totalOfPages: totalOfPages,
        ),
      );
    } on Exception catch (error) {
      return Result.failure(error);
    }
  }

  // ---------------------- Métodos Privados ------------------------

  Future<HtmlParser> _fetchHtml(String url) async {
    final session = contentRepository.session;

    final parser = await session.fetchDocument(
      Uri.parse(url),
      headers: App.HEADERS,
      captchaHandler: HumanCaptchaHandler(
        context: contentRepository.anchor.currentContext,
      ),
    );

    // final response = await contentRepository._dio.get(url);

    return parser;
  }

  // Future<bool> _requiresCaptcha() async {
  //   final parser = await _fetchHtml("https://betteranime.net");

  //   // final parser = await contentRepository.session.fetchDocument(
  //   //   Uri.parse("https://betteranime.net"),
  //   //   captchaUiContext: contentRepository.loadingMoreKey.currentContext,
  //   //   captchaHandler: HumanCaptchaHandler(),
  //   // );
  //   return (parser.text('title') ?? "").contains("Captcha Page");
  // }

  // Future<void> _onSolve(List<ContentCookie> cookies) async {
  //   await contentRepository._appConfigController?.setBetterAnimeCookies(cookies);
  //   contentRepository.contentChallenge.value = NoChallenge();
  // }

  Anime _extractAnimeInfo(Document doc, Anime base) {
    final imageElement = doc.querySelector(".infos-img img");
    final animeInfo = doc.querySelector(".anime-info");

    return base.copyWith(
      title: animeInfo?.querySelector("h2.pt-5")?.text,
      sinopse: animeInfo?.querySelector(".anime-description")?.text,
      genres: animeInfo
          ?.querySelectorAll(".anime-genres a")
          .map((e) => Genre(e.text))
          .toList(),
      originalImage: imageElement != null
          ? "https:${imageElement.attributes["src"]}"
          : null,
    );
  }

  List<Episode> _extractEpisodes(HtmlParser parser, bool isDublado) {
    final elements = parser.queryAll("#episodesList li");
    final episodes = elements
        .map((e) {
          final input = e.query("input");
          if (input != null) return null;
          final url = e.queryAttr("a", "href");
          final title = e.queryText("a h3");
          if ([url, title].any((x) => x == null)) return null;

          return Episode(url: url!, title: title!, isDublado: isDublado);
        })
        .nonNulls
        .toList();
    return episodes;
  }

  String? _extractToken(String script) {
    final match = RegExp(r'_tokens*:s*"([^"]+)"').firstMatch(script);
    return match?.group(1);
  }

  Map<String, String> _extractQualities(String script) {
    // final regex = RegExp(r'qualityString["(d+p)"]s*=s*"([^"]+)"');
    final regex = RegExp(r'qualityString\["(\d+p)"\]\s*=\s*"([^"]+)"');
    return {
      for (final match in regex.allMatches(script))
        if (match.group(1) != null && match.group(2) != null)
          match.group(1)!: match.group(2)!,
    };
  }

  Future<List<VideoData?>> _fetchAllQualities(
    Map<String, String> qualityMap,
    String token,
    String refererUrl,
  ) async {
    return Future.wait(
      qualityMap.entries.map((entry) async {
        try {
          contentRepository._dio.addInterceptor(_BetterAnimeInterceptor());
          final response = await contentRepository._dio.post(
            'https://betteranime.net/changePlayer',
            data: {'_token': token, 'info': entry.value},
            headers: {
              'referer': 'https://betteranime.net',
              'origin': refererUrl,
              'x-requested-with': 'XMLHttpRequest',
              'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
              'user-agent': 'Mozilla/5.0',
            },
          );
          contentRepository._dio.removeInterceptor(_BetterAnimeInterceptor);
          final videoUrl = await _extractVideoUrl(response.data["frameLink"]);
          if (videoUrl == null) return null;

          return VideoData(
            videoContent: videoUrl.replaceAll(r'\', ''),
            httpHeaders: {'referer': refererUrl, 'user-agent': 'Mozilla/5.0'},
            quality:
                Quality.values.firstWhereOrNull(
                  (q) => q.label.toLowerCase().contains(entry.key.toLowerCase()),
                ) ??
                Quality.NONE,
          );
        } catch (_) {
          return null;
        }
      }),
    );
  }

  Future<String?> _extractVideoUrl(String? url) async {
    if (url == null) return null;
    contentRepository._dio.addInterceptor(_BetterAnimeInterceptor());

    final response = await contentRepository._dio.get(
      url,
      headers: {'referer': url, 'user-agent': 'Mozilla/5.0'},
    );
    contentRepository._dio.removeInterceptor(_BetterAnimeInterceptor);

    final doc = parse(response.data);
    final scripts = doc.getElementsByTagName('script');

    for (final script in scripts) {
      final text = script.text;
      if (text.contains('jwplayer') && text.contains('.m3u8')) {
        final match = RegExp(r'"file"s*:s*"([^"]+.m3u8)"').firstMatch(text);
        return match?.group(1)?.replaceAll(r'/', '/');
      }
    }

    return null;
  }
}
