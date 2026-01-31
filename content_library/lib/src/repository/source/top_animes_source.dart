part of '../content_repository.dart';

class TopAnimesSource extends RSource {
  TopAnimesSource(super.contentRepository, {super.initialIndex = 0});

  @override
  Future<Result<List<Data>>> getContent(Release release) async {
    if (release is! Episode) {
      return Result.failure(
        AnimeGetDataException(message: "A instancia content precisa ser do tipo Episode"),
      );
    }

    final List<Data> data = [];
    try {
      // https://cdn-s01.mywallpaper-4k-image.net/stream/y/yasei-no-last-boss-ga-arawareta/11.mp4/index.m3u8

      final releaseURL = release.url;
      final rex = RegExp(r"""-\bepisodio-\d+/?$""");
      final parts = releaseURL.split("/");
      final lastSplit = parts[parts.length - 2].replaceAll(rex, "");
      final numberEp = rex
          .stringMatch(parts[parts.length - 2])
          ?.replaceAll(RegExp("[^0-9]"), "");
      final letra = lastSplit[0];

      final partsURL = [
        "https://cdn-s01.mywallpaper-4k-image.net/stream",
        letra,
        lastSplit,
        "$numberEp.mp4",
        "index.m3u8",
      ];
      final playURL = partsURL.join("/");

      final videoData = Data.videoData(videoContent: playURL, httpHeaders: App.HEADERS);
      data.add(videoData);
      return Result.success(data);
    } catch (_) {
      return Result.failure(Exception());
    }

    // try {
    //   final List<Data> data = [];

    //   final parser = await contentRepository.session.fetchDocument(
    //     Uri.parse(release.url),
    //     captchaHandler: HumanCaptchaHandler(
    //       context: contentRepository.anchor.currentContext,
    //     ),
    //   );

    //   final url = parser.queryAttr("#dooplay_player_content a", "href");

    //   if (url != null) {
    //     final code = """
    //       var iframe = document.querySelector('#player iframe');
    //       iframe.src;
    //     """;

    //     final acoes = <DomAction>[
    //       // WaitAction(const Duration(seconds: 10)),
    //       ExecuteScriptAction(code, resultKey: "VIDEO_URL"),
    //     ];
    //     final result = await contentRepository.session.executeActionsAndScrape(
    //       url: Uri.parse(url),
    //       actions: acoes,
    //     );

    //     final playURL = result['VIDEO_CONFIG'];
    //     customLog(playURL);
    //     final videoData = Data.videoData(videoContent: playURL, httpHeaders: App.HEADERS);
    //     data.add(videoData);
    //   }

    //   await contentRepository.session.closePage();

    //   return Result.success(data);
    // } on DioException catch (error) {
    //   return Result.failure(error);
    // }
  }

  @override
  Future<Result<Content>> getData(Content content) async {
    try {
      if (content is! Anime) throw AnimeGetDataException();

      final Response response = await contentRepository._dio.get(
        content.url,
        responseType: ResponseType.plain,
      );

      final HtmlParser htmlParser = HtmlParser.fromString(response.data);

      final sinopse = htmlParser.queryText(".sbox .wp-content p") ?? "";

      final genres = htmlParser
          .queryAll(".sgeneros a")
          .map((element) => element.text)
          .nonNulls
          .map(Genre.new)
          .toList();

      final episodes = htmlParser.queryAll("#serie_contenido li");

      for (final episodeE in episodes) {
        final episodeTitle = episodeE.queryText(".episodiotitle a");
        final episodeUrl = episodeE.queryAttr(".episodiotitle a", "href");
        final originalImage = episodeE.queryAttr(".imagen img", "data-src");
        final DateFormat format = DateFormat("dd/MM/yy");
        final dateString = episodeE.queryText(".episodiotitle .date") ?? "";
        final registrationData = format.tryParse(dateString);

        if ({episodeUrl, episodeTitle}.contains(null)) continue;

        final episode = Episode(
          url: episodeUrl!,
          title: episodeTitle!,
          isDublado: content.isDublado,
          registrationData: registrationData,
          thumbnail: originalImage,
          numberEpisode: int.tryParse(episodeTitle.replaceAll(RegExp("[^0-9]"), "")),
        );
        content.releases.addOrUpdateWhere(episode, episode.isEqualStringID);
      }

      return Result.success(content.copyWith(genres: genres, sinopse: sinopse));
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

  @override
  Future<Result<Content>> getReleases(Content content, int page) async {
    try {
      if (content is! Anime) throw AnimeGetDataException();
      final Response response = await contentRepository._dio.get(
        content.url,
        responseType: ResponseType.plain,
      );

      final HtmlParser htmlParser = HtmlParser.fromString(response.data);

      final episodes = htmlParser.queryAll("#serie_contenido li");

      for (final episodeE in episodes) {
        final episodeTitle = episodeE.queryText(".episodiotitle a");
        final episodeUrl = episodeE.queryAttr(".episodiotitle a", "href");
        final originalImage = episodeE.queryAttr(".imagen img", "data-src");
        final DateFormat format = DateFormat("dd/MM/yy");
        final dateString = episodeE.queryText(".episodiotitle .date") ?? "";
        final registrationData = format.tryParse(dateString);

        if ({episodeUrl, episodeTitle}.contains(null)) continue;

        final episode = Episode(
          url: episodeUrl!,
          title: episodeTitle!,
          isDublado: content.isDublado,
          registrationData: registrationData,
          thumbnail: originalImage,
          numberEpisode: int.tryParse(episodeTitle.replaceAll(RegExp("[^0-9]"), "")),
        );
        content.releases.addOrUpdateWhere(episode, episode.isEqualStringID);
      }
      return Result.success(content);
    } on DioException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<bool> loadData() async {
    try {
      if (contentRepository.addMore) {
        contentRepository.totalPerPage.add(contentRepository.length);
        contentRepository.index++;
      }

      final index = contentRepository.index;
      final baseURL = source.baseURL;

      final parts = [baseURL, "episodio/page", index];

      final Response response = await contentRepository._dio.get(
        parts.join("/"),
        responseType: ResponseType.plain,
      );

      final HtmlParser htmlParser = HtmlParser.fromString(response.data);

      final articles = htmlParser
          .selectAll("#archive-content article")
          .map(HtmlParser.fromElement);

      for (final article in articles) {
        final episodeTitle = article.queryText(".data a h3");
        final animeTitle = article.queryText(".data a span");
        final episodeUrl = article.queryAttr("a", "href");
        final originalImage = article.queryAttr(".poster picture img", "data-src") ?? "";
        final animeURL = episodeUrl!
            .replaceAll(RegExp(r"""-\bepisodio-\d+/?$"""), "")
            .replaceAll("episodio", "animes");

        if ({episodeUrl, episodeTitle, animeTitle, animeURL}.contains(null)) continue;

        final isDublado = animeTitle!.toLowerCase().contains("dublado");

        final anime = Anime(
          url: animeURL,
          title: animeTitle,
          isDublado: isDublado,
          originalImage: originalImage,
          repoStatus: RepositoryStatus(loadData: true),
          releases: EpisodeReleases()
            ..add(
              Episode(
                url: episodeUrl,
                title: episodeTitle!,
                isDublado: isDublado,
                thumbnail: originalImage,
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
  Future<Result<SearchResult>> search(SearchFilter filter) {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  Source get source => Source.TOP_ANIMES;
}
