// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

class NeoxSource extends RSource {
  NeoxSource(
    super.bookRepository, {
    super.initialIndex = 1,
  });

  @override
  Source get source => Source.NEOX_SCANS;

  @override
  String get BASE_URL => App.NEOX_URL;

  Element? _getElementOnly(List<Element> postContentItem, String contains,
      [String? querySelector]) {
    bool firstWhereGenres(Element element) {
      final result = element
          .querySelector('h5')
          ?.text
          .trim()
          .toLowerCase()
          .contains(contains);
      return result ?? false;
    }

    return postContentItem
        .firstWhereOrNull(firstWhereGenres)
        ?.querySelector(querySelector ?? '.summary-content');
  }

  /// Scraping [Book.genres].
  void _setGenres(List<Genre> genres, List<Element> postContentItem) {
    void genresForEach(String label) {
      final genreString = label.trim();
      if (!genres.contains(Genre(genreString))) {
        genres.add(Genre(genreString));
      }
    }

    _getElementOnly(postContentItem, 'genres')
        ?.text
        .split(',')
        .forEach(genresForEach);

    _getElementOnly(postContentItem, 'gênero(s)')
        ?.text
        .split(',')
        .forEach(genresForEach);
  }

  /// Scraping [Book.authors].
  void _setAuthors(List<String> authors, List<Element> postContentItem) {
    final autor = _getElementOnly(postContentItem, 'autor')?.text.trim();
    if (autor != null && !authors.contains(autor)) authors.add(autor);
  }

  /// Scraping [Book.status]
  String? _setStatus(String? oldStatus, List<Element> postContentItem) {
    if (oldStatus != null) return oldStatus;
    return _getElementOnly(
      postContentItem,
      'status',
    )?.text.trim();
  }

  /// Scraping [Book.type]
  String? _setType(String? oldType, List<Element> postContentItem) {
    if (oldType != null) return oldType;
    return _getElementOnly(
      postContentItem,
      'tipo',
    )?.text.trim();
  }

  /// Scraping [Book.alternativeTitle]
  String? _setAlternativeTitle(
      String? oldAlternativeTitle, List<Element> postContentItem) {
    if (oldAlternativeTitle != null) return oldAlternativeTitle;
    return _getElementOnly(
      postContentItem,
      'alternativo',
    )?.text.trim();
  }

  @override
  Future<Result<Content>> getData(Content content) async {
    bool isBook() {
      return content is Book;
    }

    assert(
      isBook(),
      "A instancia content precisa ser do tipo Book",
    );

    final book = content as Book;

    try {
      final response = await Future.wait([
        contentRepository._dio.get(
          book.url,
          responseType: ResponseType.plain,
        ),
        contentRepository._dio.post(
          "${book.url}ajax/chapters",
          responseType: ResponseType.plain,
        ),
      ]);

      final Document bookDocument = parse(response.first.data);

      final ScrapingUtil scrapingUtil = ScrapingUtil.bySelector(
        bookDocument,
        selector: '.site-content',
      );

      if (scrapingUtil.error) {
        return Result.failure(Exception('Error ao buscar o livro'));
      }

      final List<Element> postContentItem =
          scrapingUtil.querySelectorAll('.post-content_item');

      /// Vars
      final List<Genre> genres = [...book.genres];
      String? status;
      String? type;
      List<String> authors = [...book.authors];
      String? alternativeTitle;
      String? extraLarge;
      String? large;
      String? medium;

      if (postContentItem.isNotEmpty) {
        _setGenres(genres, postContentItem);
        status = _setStatus(book.status, postContentItem);
        type = _setType(null, postContentItem);
        _setAuthors(authors, postContentItem);
        alternativeTitle = _setAlternativeTitle(
          book.alternativeTitle,
          postContentItem,
        );

        if (book.searchNewImage && alternativeTitle != null) {
          final result = await contentRepository._jikanService
              .getMangaPictures(query: alternativeTitle);

          if (result.isNotEmpty) {
            // final first = result.first;
            final last = result.last;
            medium = last.imageUrl;
            large = last.imageUrl;
            extraLarge = last.largeImageUrl;
          }

          // final result = await contentRepository._aniListService.post(
          //   query: AniListService.queryCoverImage,
          //   variables: {"search": alternativeTitle},
          // );
          // final value = result.data?.values.last;

          // if (value != null) {
          //   medium = value['coverImage']['medium'];
          //   large = value['coverImage']['large'];
          //   extraLarge = value['coverImage']['extraLarge'];
          // }
        }
      }

      double? score =
          scrapingUtil.getScore(selector: '.post-total-rating span');

      // Image
      final String image =
          scrapingUtil.getImage(selector: '.summary_image img');
      // final String? secondImage = scrapingUtil.getImage(selector: '.summary_image img', bySrcSet: true).dataOrNull;

      // Sinopse
      final String sinopse = scrapingUtil.getByText(selector: '.manga-excerpt');

      // Chapters
      //
      // url ex: https://nexoscans.com/manga/a-ent-81_131_0-esima-regressao-do-jogador-de-nivel-maximo/ajax/chapters/
      //
      //
      final List<Element> elements =
          parse(response[1].data).querySelectorAll('.wp-manga-chapter');

      for (final element in elements) {
        final ScrapingUtil scrapingUtil = ScrapingUtil(element);
        final String url = scrapingUtil.getURL(selector: 'div a');

        final String title = scrapingUtil.element.children
            .firstWhere((element) => element.text.trim().isNotEmpty)
            .text
            .trim();

        if (url.isEmpty || title.isEmpty) continue;

        final chapter = Chapter(
          url: url,
          title: title,
        );

        book.releases.addIfNoContains(chapter);
      }

      final newBook = book.copyWith(
        originalImage: image,
        type: type,
        authors: authors,
        score: score,
        alternativeTitle: alternativeTitle,
        sinopse: sinopse,
        status: status,
        genres: genres,
        mediumImage: medium,
        largeImage: large,
        extraLarge: extraLarge,
      );

      return Result.success(newBook);
    } on DioException catch (_, __) {
      customLog('Algo ruím aconteceu', error: _, stackTrace: __);
      return Result.failure(_);
    }
  }

  @override
  Future<bool> loadData() async {
    if (contentRepository.addMore) contentRepository.index++;

    try {
      final subKey =
          'page/${contentRepository.index}/?s&post_type=wp-manga&m_orderby=${contentRepository._hiveController.orderBy.label}';

      final String mainURL = '$BASE_URL/$subKey';

      final Response response = await contentRepository._dio
          .get(mainURL, responseType: ResponseType.plain);

      final Document document = parse(response.data);

      final element = document.querySelector('.c-tabs-item');

      if (element == null || element.children.isEmpty) return false;

      for (final element in element.children) {
        final ScrapingUtil scrapingUtil = ScrapingUtil(element);

        final String url = scrapingUtil.getURL(selector: 'h3 a');
        final double? score =
            scrapingUtil.getScore(selector: '.score.total_votes');
        final String title = scrapingUtil.getByText(selector: 'h3 a');
        final String originalImage = scrapingUtil.getImage(selector: 'img');
        // final String? bookType =
        //     scrapingUtil.getByText(selector: '.manga-title-badges').noEmpty;
        final String? mediumImage = scrapingUtil
            .getImage(selector: 'img', bySrcSet: true, last: true)
            .isEmptyOrNull;
        final String? largeImage = scrapingUtil
            .getImage(selector: 'img', bySrcSet: true)
            .isEmptyOrNull;

        /// Vars
        final List<Genre> genres = [];

        final List<Element> postContentItem =
            scrapingUtil.querySelectorAll('.post-content_item');

        if (postContentItem.isNotEmpty) {
          _setGenres(genres, postContentItem);
        }

        // List<Genre>? genres = scrapingUtil.getInfo<List<Genre>>(
        //   selector: '.post-content_item',
        //   whereTest: (element) =>
        //       element
        //           .querySelector('.summary-heading h5')
        //           ?.text
        //           .trim()
        //           .toLowerCase() !=
        //       'genres',
        //   endReturn: (data) =>
        //       data.split(',').map((e) => Genre(e.trim())).toList(),
        // );

        if ([originalImage, url, title].isNull) continue;

        final Book book = Book(
          releases: Releases(),
          genres: genres,
          source: source,
          url: url,
          originalImage: originalImage,
          largeImage: largeImage,
          mediumImage: mediumImage,
          title: title,
          score: score,
        );
        if (!contentRepository.contains(book)) contentRepository.add(book);
      }
      contentRepository.isSuccess = true;
      contentRepository._hasMore = true;
      return Future.value(true);
    } on DioException catch (_, __) {
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      customLog('Algo ruím aconteceu', error: _, stackTrace: __);
      return Future.value(false);
    }
  }

  @override
  Future<Result<List<Data>>> getContent(Release release) async {
    bool isChapter() {
      return release is Chapter;
    }

    assert(
      isChapter(),
      "A instancia content precisa ser do tipo Chapter",
    );

    final chapter = release as Chapter;

    try {
      final url = chapter.url;

      final Response response = await contentRepository._dio.get(
        url,
        responseType: ResponseType.plain,
      );
      final Document document = parse(response.data);

      final List<Data> data = [];

      final novelContent = document.querySelector(
        '.reading-content .text-left',
      );

      if (novelContent != null) {
        for (var element in novelContent.children) {
          final text = element.text.trim();
          if (text.isEmpty) continue;
          data.add(Data.textData(text: text));
        }
      }

      final imageList = document.querySelectorAll('.reading-content img');

      for (final img in imageList) {
        final imageURL = ScrapingUtil(img).getImage();
        if (imageURL.isEmpty || !imageURL.contains('nexoscans')) continue;

        data.add(Data.imageData(imageURL: imageURL));
      }

      return Result.success(data);
    } on DioException catch (_, __) {
      customLog('DioError', error: _, stackTrace: __);
      return Result.failure(_);
    }
  }
}
