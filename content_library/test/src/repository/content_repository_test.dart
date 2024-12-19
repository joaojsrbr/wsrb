import 'package:content_library/src/constants/source.dart';
import 'package:content_library/src/repository/anime_skip_imp.dart';
import 'package:content_library/src/repository/content_repository.dart';
import 'package:content_library/src/services/dio_client.dart';
import 'package:content_library/src/services/graphql_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('content repository ...', () async {
    final DioClient client = DioClient();
    final GraphQLApiClient graphQLApiClient = GraphQLApiClient();
    final AnimeSkipRepository animeSkipRepository =
        AnimeSkipRepository(graphQLApiClient);
    final ContentRepository contentRepository = ContentRepository.test(
      client,
      animeSkipRepository,
      Source.ANROLL,
    );

    await contentRepository.loadMore();

    animeSkipRepository;
  });
}
