// ignore_for_file: non_constant_identifier_names

part of '../content_repository.dart';

class SlimeReadSource extends RSource {
  const SlimeReadSource(super.contentRepository, {super.initialIndex = 0});

  @override
  String get BASE_URL => source.baseURL;

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
  Future<bool> loadData() async {
    if (contentRepository.addMore) contentRepository.index++;

    final String apiURL = 'https://morria.slimeread.com:8443/books?page=${contentRepository.index}';

    try {
      // contentRepository._dio.removeInterceptor(_DefaultAppHeadersInterceptor());
      final Response response = await contentRepository._dio.get(apiURL, headers: {'user-agent': 'PostmanRuntime/7.43.0'}, responseType: ResponseType.json);

      final SlimeReadBookResponse responseDto = SlimeReadBookResponse.fromJson(response.data);

      if (responseDto.pages == contentRepository.index || responseDto.data.isEmpty) {
        contentRepository.isSuccess = false;
        contentRepository._hasMore = false;
        return Future.value(false);
      }

      for (final responseDto in responseDto.data) {
        final bookId = responseDto.bookId;
        final slug = responseDto.bookName;
        final url = '$BASE_URL/manga/$bookId/$slug';

        final ChapterReleases releases = ChapterReleases();

        final Book book = Book(
          nsfw: responseDto.nsfw,
          slugId: url,
          alternativeTitle: responseDto.bookNameAlternatives,
          genres: responseDto.bookCategories.map((cat) => Genre(cat.categories.catNamePtBR)).toList(),
          bookId: responseDto.bookId.toString(),
          releases: releases,
          title: responseDto.bookNameOriginal,
          source: source,
          originalImage: responseDto.bookImage,
          url: url,
        );

        final firstBookTempCap = responseDto.bookTemp.first.bookTempCaps.first;

        final chapterUrl = '$BASE_URL/ler/$bookId/cap-${firstBookTempCap.btcCap}';

        releases.add(Chapter(url: chapterUrl, bookStringID: book.stringID, title: 'Cap. ${firstBookTempCap.btcCap}'));

        contentRepository.addIfNoContains(book);
      }

      contentRepository.isSuccess = true;
      contentRepository._hasMore = true;

      return Future.value(true);
    } on DioException catch (error, stack) {
      customLog(error.message, stackTrace: stack);
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    } on Exception catch (error, stack) {
      customLog(error.toString(), stackTrace: stack);
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      return Future.value(false);
    } finally {
      // contentRepository._dio.addInterceptor(_DefaultAppHeadersInterceptor());
    }
  }

  @override
  Future<Result<List<Content>>> search(String query) async {
    return const Result.empty();
  }

  @override
  Source get source => Source.SLIMEREAD;
}
