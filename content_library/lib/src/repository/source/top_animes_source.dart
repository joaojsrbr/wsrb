// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

@SourceEntry(
  label: "Top Animes",
  id: 'top_animes',
  baseUrl: App.TOP_ANIMES_URL,
  contentType: ContentType.ANIME,
)
class TopAnimesSource extends RSource {
  TopAnimesSource(super.context, {super.initialIndex = 0});

  @override
  Source get source => Source.TOP_ANIMES;

  @override
  Future<Result<List<Data>>> getReleaseData(Release release) async {
    if (release is! Episode) {
      return Result.failure(
        AnimeGetDataException(
          message: "A instancia content precisa ser do tipo Episode",
        ),
      );
    }

    final List<Data> data = [];
    try {
      final releaseURL = release.url;
      final urlParts = releaseURL.split("/");

      if (urlParts.length < 2) {
        return Result.failure(
          AnimeGetDataException(message: "URL inválida: $releaseURL"),
        );
      }

      final lastPart = urlParts[urlParts.length - 2];
      final episodeMatch = RegExp(r"episodio-(\d+)").firstMatch(lastPart);

      if (episodeMatch == null) {
        return Result.failure(
          AnimeGetDataException(
            message: "Número do episódio não encontrado na URL",
          ),
        );
      }

      final episodeNum = int.tryParse(episodeMatch.group(1) ?? '');
      if (episodeNum == null) {
        return Result.failure(
          AnimeGetDataException(message: "Número do episódio inválido"),
        );
      }

      final animeSlug = lastPart.replaceAll(RegExp(r"-\bepisodio-\d+/?$"), "");

      if (animeSlug.isEmpty) {
        return Result.failure(
          AnimeGetDataException(message: "Slug do anime não encontrado"),
        );
      }

      final letra = animeSlug[0];
      final formattedNum = episodeNum < 10 ? "0$episodeNum" : "$episodeNum";

      final playURL = Uri.parse("https://cdn-s01.mywallpaper-4k-image.net")
          .replace(
            pathSegments: [
              "stream",
              letra,
              animeSlug,
              "$formattedNum.mp4",
              "index.m3u8",
            ],
          )
          .toString();

      final videoData = Data.videoData(
        videoContent: playURL,
        httpHeaders: App.HEADERS,
      );
      data.add(videoData);
      // customLog(playURL);
      return Result.success(data);
    } on AnimeGetDataException catch (error, stack) {
      customLog(
        'ERROR[${error.runtimeType}]: ${error.toString()}',
        stackTrace: stack,
      );
      return Result.failure(error);
    } on Exception catch (error, stack) {
      customLog(
        'ERROR[${error.runtimeType}]: ${error.toString()}',
        stackTrace: stack,
      );
      return Result.failure(error);
    }
  }

  @override
  Future<Result<Content>> getDetails(Content content) async {
    try {
      if (content is! Anime) throw AnimeGetDataException();

      final Response response = await context.dio.get(
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
          numberEpisode: int.tryParse(
            episodeTitle.replaceAll(RegExp("[^0-9]"), ""),
          ),
        );
        content.releases.addOrUpdateWhere(episode, episode.isEqualStringID);
      }

      return Result.success(content.copyWith(genres: genres, sinopse: sinopse));
    } on DioException catch (error) {
      return Result.failure(error);
    } on AnrollGetIdException catch (error, stack) {
      customLog(
        'ERROR[${error.runtimeType}]: ${error.message}',
        stackTrace: stack,
      );
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
  Future<Result<Content>> getContentReleases(Content content, int page) async {
    try {
      if (content is! Anime) throw AnimeGetDataException();
      final Response response = await context.dio.get(
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
          numberEpisode: int.tryParse(
            episodeTitle.replaceAll(RegExp("[^0-9]"), ""),
          ),
        );
        content.releases.addOrUpdateWhere(episode, episode.isEqualStringID);
      }
      return Result.success(content);
    } on DioException catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<bool> loadPage([int page = 0]) async {
    final state = context.state;
    try {
      if (state.addMore) {
        state.totalPerPage[source] = context.getLength();
        state.index++;
      }

      final index = state.index;
      final baseURL = source.baseUrl;

      final parts = [baseURL, "episodio/page", index];

      final Response response = await context.dio.get(
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
        final originalImage =
            article.queryAttr(".poster picture img", "data-src") ??
            article.queryAttr(".poster picture img", "src") ??
            "";
        final animeURL = episodeUrl!
            .replaceAll(RegExp(r"""-\bepisodio-\d+/?$"""), "")
            .replaceAll("episodio", "animes");

        if ({episodeUrl, episodeTitle, animeTitle, animeURL}.contains(null)) {
          continue;
        }

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

        context.addIfNoContains(anime);
      }

      context.state
        ..isSuccess = true
        ..hasMore = true
        ..fullScreenError = null;

      return true;
    } on AnrollGetIdException catch (error) {
      context.state.fullScreenError = error;
      context.state.isSuccess = false;
      context.state.hasMore = false;
      return Future.value(false);
    } on DioException catch (error) {
      context.state.fullScreenError = error;
      context.state.isSuccess = false;
      context.state.hasMore = false;
      return Future.value(false);
    }
  }

  @override
  Future<Result<SearchResult>> search(SearchFilter filter) async {
    return Result.failure(
      Exception('search() not implemented for TOP_ANIMES source'),
    );
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
          FilterOption(id: 'animation', label: 'Animação'),
          FilterOption(id: 'comedy', label: 'Comédia'),
          FilterOption(id: 'drama', label: 'Drama'),
          FilterOption(id: 'fantasy', label: 'Fantasia'),
          FilterOption(id: 'horror', label: 'Terror'),
          FilterOption(id: 'kids', label: 'Kids'),
          FilterOption(id: 'music', label: 'Música'),
          FilterOption(id: 'mystery', label: 'Mistério'),
          FilterOption(id: 'romance', label: 'Romance'),
          FilterOption(id: 'sci-fi', label: 'Ficção Científica'),
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
          FilterOption(id: 'tv', label: 'TV'),
        ],
      ),
      Filter(
        id: 'order',
        label: 'Ordenar por',
        type: FilterType.order,
        options: [
          FilterOption(id: 'date', label: 'Data'),
          FilterOption(id: 'title', label: 'Título'),
          FilterOption(id: 'views', label: 'Visualizações'),
          FilterOption(id: 'rating', label: 'Avaliação'),
        ],
      ),
      Filter(id: 'letter', label: 'Letra', type: FilterType.letter),
    ];

    return Result.success(filters);
  }
}
