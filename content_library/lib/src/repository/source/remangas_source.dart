// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

class RemangasSource extends RSource {
  RemangasSource(super.contentRepository, {super.initialIndex = 1});

  @override
  Future<bool> loadData() async {
    if (contentRepository.addMore) {
      contentRepository.totalPerPage.add(contentRepository.length);
      contentRepository.index++;
    }

    try {
      // https://remangas.net/manga/page/2/?m_orderby=new-manga
      final urlParts = [
        "https://remangas.net/manga/page",
        contentRepository.index.toString(),
        "?m_orderby=new-manga",
      ];

      final uri = Uri.parse(urlParts.join("/"));

      final parser = await contentRepository.session.fetchDocument(
        uri,
        captchaHandler: HumanCaptchaHandler(
          userAgent: "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Mobile",
          context: contentRepository.anchor.currentContext,
        ),
      );

      final element = parser.query(".tab-content-wrap");

      if (element == null) return false;

      final elements = element.queryAll(".page-item-detail.manga");

      for (final parser in elements) {
        final title = parser.queryText(".post-title.font-title a");
        final url = parser.queryAttr(".post-title.font-title a", "href");
        final image = parser.getImage(".item-thumb.c-image-hover img");

        if (url == null || title == null) continue;

        final book = Book(
          releases: ChapterReleases(),
          title: title,
          source: source,
          originalImage: image,
          url: url,
        );
        contentRepository.addIfNoContains(book);
      }
      await contentRepository.session.closePage();
      contentRepository.isSuccess = true;
      contentRepository._hasMore = true;
      contentRepository.fullScreenError = null;
      return Future.value(true);
    } on Exception catch (error) {
      contentRepository
        ..isSuccess = false
        .._hasMore = false
        ..fullScreenError = error;

      return false;
    }
  }

  @override
  Future<Result<List<Data>>> getContent(Release release) {
    // TODO: implement getContent
    throw UnimplementedError();
  }

  @override
  Future<Result<Content>> getData(Content content) {
    // TODO: implement getData
    throw UnimplementedError();
  }

  @override
  Future<Result<Content>> getReleases(Content content, int page) {
    // TODO: implement getReleases
    throw UnimplementedError();
  }

  @override
  Future<Result<SearchResult>> search(SearchFilter filter) {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  Source get source => Source.REMANGAS;
}
