// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

class _BetterAnimeInterceptor extends Interceptor {
  final AppConfigController appConfigController;
  _BetterAnimeInterceptor({required this.appConfigController});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final betterAnimeCookies = appConfigController.config.betterAnimeCookies;

    if (betterAnimeCookies.isNotEmpty && options.path.contains("betteranime")) {
      final betterAnimeCookieString = ContentCookie.stringifyCookies(betterAnimeCookies);
      options.headers["Cookie"] = betterAnimeCookieString;
    }

    return super.onRequest(options, handler);
  }
}

class BetterAnimeSource extends RSource {
  const BetterAnimeSource(super.contentRepository, {super.initialIndex = 1});

  @override
  String get BASE_URL => source.baseURL;

  @override
  Future<Result<Content>> getData(Content content) async {
    try {
      if (content is! Anime) throw GetDataException();
      Anime anime = content;
      if (await _needLogin()) throw GetDataException();
      final String url = anime.url;

      final response = await contentRepository._dio.get(url);
      final Document document = parse(response.data);

      final imageElement = document.querySelector(".infos-img img");

      final originalImage = imageElement != null ? "https:${imageElement.attributes["src"]}" : null;

      final animeInfoElement = document.querySelector(".anime-info");

      final genres = animeInfoElement
          ?.querySelectorAll(".anime-genres a")
          .map((element) => Genre(element.text))
          .toList();

      final title = animeInfoElement?.querySelector("h2.pt-5")?.text;

      final sinopse = animeInfoElement?.querySelector(".anime-description")?.text;

      anime = anime.copyWith(title: title, genres: genres, sinopse: sinopse, originalImage: originalImage);

      final episodesElements = document.querySelectorAll(".list-group-item.list-group-item-action");

      for (final Element episodeElement in episodesElements) {
        final url = episodeElement.querySelector("a")?.attributes["href"];
        final episodeTitle = episodeElement.querySelector("a h3")?.text.trim();
        if ({url, episodeTitle}.contains(null)) continue;
        final episode = Episode(url: url!, title: episodeTitle!, isDublado: anime.isDublado);
        anime.releases.addOrUpdateWhere(episode, episode.isEqualStringID);
      }

      return Result.success(anime);
    } on DioException catch (error) {
      return Result.failure(error);
    } on GetDataException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<bool> loadData() async {
    try {
      if (await _needLogin()) throw LoadDataException();

      if (contentRepository.addMore) {
        contentRepository.totalPerPage.add(contentRepository.length);
        contentRepository.index++;
      }

      final String url = 'https://betteranime.net/ultimosLancamentos?page=${contentRepository.index}';

      final response = await contentRepository._dio.get(url);
      final Document document = parse(response.data);

      final elements = document.querySelector("div.list-animes")?.children ?? [];

      for (final Element articleElement in elements) {
        final src = articleElement.querySelector(".card-img img")?.attributes["src"];
        final thumbnail = "https:$src";
        final cardElement = articleElement.querySelector(".card-title");

        if (cardElement == null) continue;

        final episodeUrl = articleElement.querySelector("a")?.attributes["href"];
        final episodeTitle = cardElement.querySelector("h4")?.text;

        final parts = episodeUrl?.split(RegExp(r'(?<!/)/(?!/)'));

        if ({episodeTitle, episodeUrl, parts}.contains(null)) continue;

        final isDublado = parts!.contains("dublado");

        final episodeReleases = EpisodeReleases()
          ..add(Episode(url: episodeUrl!, title: episodeTitle!, isDublado: isDublado, thumbnail: thumbnail));

        final animeTitle = cardElement.querySelector("h3")?.text;
        final slugSerie = parts[parts.length - 2];
        final animeUrl = parts.sublist(0, parts.length - 1).join("/");

        final Anime anime = Anime(
          slugSerie: slugSerie,
          url: animeUrl,
          title: animeTitle!,
          isDublado: isDublado,
          releases: episodeReleases,
          originalImage: thumbnail,
          source: source,
        );

        contentRepository.addIfNoContains(anime);
      }
      contentRepository.isSuccess = true;
      contentRepository._hasMore = true;
      contentRepository.fullScreenError = null;
      return Future.value(true);
    } on DioException catch (_) {
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    } on LoadDataException catch (_) {
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    }
  }

  @override
  Future<Result<Content>> getReleases(Content content, int page) async {
    try {
      if (content is! Anime) throw GetDataException();
      Anime anime = content;
      if (await _needLogin()) throw GetDataException();
      final String url = content.url;

      final response = await contentRepository._dio.get(url);
      final Document document = parse(response.data);

      final episodesElements = document.querySelectorAll(".list-group-item.list-group-item-action");

      for (final Element episodeElement in episodesElements) {
        final url = episodeElement.querySelector("a")?.attributes["href"];
        final episodeTitle = episodeElement.querySelector("a h3")?.text.trim();
        if ({url, episodeTitle}.contains(null)) continue;
        final episode = Episode(url: url!, title: episodeTitle!, isDublado: anime.isDublado);
        content.releases.addOrUpdateWhere(episode, episode.isEqualStringID);
      }
      return Result.success(anime);
    } on DioException catch (error) {
      return Result.failure(error);
    } on GetDataException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<Result<List<Data>>> getContent(Release release) async {
    try {
      if (await _needLogin()) throw LoadDataException();

      final url = release.url;
      final document = await _fetchHtml(url);
      final script = _findScriptWithToken(document);

      if (script == null) throw Exception("Script com token não encontrado");

      final token = _extractToken(script.text);
      final qualityMap = _extractQualities(script.text);

      if (token == null || qualityMap.isEmpty) {
        throw Exception("Token ou qualidades não encontrados");
      }

      final videoDataList = await _fetchAllQualities(qualityMap, token, url);
      final validData = videoDataList.whereType<VideoData>().toList();

      return validData.isNotEmpty ? Result.success(validData) : Result.failure(Exception("Nenhum vídeo encontrado"));
    } on DioException catch (error) {
      return Result.failure(error);
    } on LoadDataException catch (error) {
      return Result.failure(error);
    }
  }

  Future<String?> _extractVideoUrl(String? pageUrl) async {
    if (pageUrl == null) return null;
    final response = await contentRepository._dio.get(
      pageUrl,
      headers: {'referer': pageUrl, 'user-agent': 'Mozilla/5.0'},
    );

    final document = parse(response.data);

    // Pega todos os scripts e filtra os que contêm 'jwplayer' e '.m3u8'
    final scripts = document.getElementsByTagName('script');
    for (var script in scripts) {
      final text = script.text;
      if (text.contains('jwplayer') && text.contains('.m3u8')) {
        final regex = RegExp(r'"file"\s*:\s*"([^"]+\.m3u8)"');
        final match = regex.firstMatch(text);
        if (match != null) {
          final m3u8Url = match.group(1);
          return m3u8Url?.replaceAll(r'\/', '/'); // desescapar
        }
      }
    }

    return null;
  }

  @override
  Source get source => Source.BETTER_ANIME;

  void _onSolve(List<ContentCookie> cookies) async {
    await contentRepository._appConfigController?.setBetterAnimeCookies(cookies);
    contentRepository.contentChallenge.value = NoChallenge();
    await contentRepository.refresh(true);
  }

  Future<bool> _needLogin() async {
    final response = await contentRepository._dio.get("https://betteranime.net");
    final Document document = parse(response.data);

    final form = document.querySelector('form[action="https://betteranime.net/validateCaptcha"]');

    if (form != null) {
      contentRepository.contentChallenge.value = BetterAnimeChallenge(
        url: "https://betteranime.net",
        headers: App.HEADERS,
        onSolve: _onSolve,
      );
      return true;
    }

    final betterAnimeCookies = contentRepository._appConfigController?.config.betterAnimeCookies ?? [];

    final sessionCookie = betterAnimeCookies.firstWhereOrNull((cookie) => cookie.key.contains("betteranime_session"));

    if (sessionCookie == null) {
      contentRepository.contentChallenge.value = BetterAnimeChallenge(
        url: "https://betteranime.net/login",
        headers: App.HEADERS,
        onSolve: _onSolve,
      );
      return true;
    }

    return false;
  }

  @override
  Future<Result<List<Content>>> search(String query) {
    // TODO: implement search
    throw UnimplementedError();
  }

  Future<Document> _fetchHtml(String url) async {
    final response = await contentRepository._dio.get(url);
    return parse(response.data);
  }

  Element? _findScriptWithToken(Document doc) {
    final regex = RegExp(r'_token\s*:\s*"([^"]+)"');
    return doc.getElementsByTagName('script').firstWhereOrNull((el) => regex.hasMatch(el.text));
  }

  String? _extractToken(String scriptText) {
    final match = RegExp(r'_token\s*:\s*"([^"]+)"').firstMatch(scriptText);
    return match?.group(1);
  }

  Map<String, String> _extractQualities(String scriptText) {
    final qualityRegex = RegExp(r'qualityString\["(\d+p)"\]\s*=\s*"([^"]+)"');
    final map = <String, String>{};

    for (final match in qualityRegex.allMatches(scriptText)) {
      final quality = match.group(1);
      final id = match.group(2);
      if (quality != null && id != null) {
        map[quality] = id;
      }
    }

    return map;
  }

  Future<List<VideoData?>> _fetchAllQualities(Map<String, String> qualityMap, String token, String refererUrl) async {
    final futures = qualityMap.entries.map((entry) async {
      try {
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

        final videoUrl = await _extractVideoUrl(response.data["frameLink"]);
        if (videoUrl == null) return null;

        return VideoData(
          videoContent: videoUrl,
          httpHeaders: {'referer': refererUrl, 'user-agent': 'Mozilla/5.0'},
          quality:
              Quality.values.firstWhereOrNull(
                (quality) => quality.label.toLowerCase().contains(entry.key.toLowerCase()),
              ) ??
              Quality.NONE,
        );
      } catch (_) {
        return null;
      }
    });

    return await Future.wait(futures);
  }
}
