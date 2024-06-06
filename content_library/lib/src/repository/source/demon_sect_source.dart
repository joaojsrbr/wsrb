// ignore_for_file: non_constant_identifier_names
part of '../content_repository.dart';

class DemonSect extends RSource {
  DemonSect(
    super.contentRepository,
  ) : super(initialIndex: 1);

  @override
  Source get source => Source.DEMON_SECT;

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
  Future<Result<Content>> getReleases(Content content, int page) async {
    // TODO: implement getReleases
    throw UnimplementedError();
  }

  @override
  Future<bool> loadData() async {
    try {
      final String subKey =
          'manga/page/${contentRepository.index}/?s&post_type=wp-manga&m_orderby=${contentRepository._hiveController.orderBy.label}';

      final String mainURL = '$BASE_URL/$subKey';

      final Response response = await contentRepository._dio.get(
        mainURL,
        responseType: ResponseType.plain,
        headers: App.HEADERS,
      );

      final Document document = parse(response.data);

      final element = document.querySelector('.c-tabs-item');

      if (element == null || element.children.isEmpty) return false;

      contentRepository.isSuccess = true;
      contentRepository._hasMore = true;
      return Future.value(false);
    } on DioException catch (_, __) {
      contentRepository.isSuccess = false;
      contentRepository._hasMore = false;
      customLog('Algo ruím aconteceu', error: _, stackTrace: __);
      return Future.value(false);
    }
  }
}
