import 'package:content_library/content_library.dart';
import 'package:content_library/src/repository/anime_skip.dart';
import 'package:content_library/src/repository/anime_skip_query.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AnimeSkipRepository implements IAnimeSkip {
  final GraphQLApiClient _graphQLClient;

  AnimeSkipRepository(this._graphQLClient);

  @override
  Future<Result<List<AnimeSkip>>> getTimeStampsByName({
    required String search,
    int offset = 0,
    int limit = 10,
    String sort = "DESC",
  }) async {
    final apiKey = App.ANIME_SKIP_API_KEY;

    if (apiKey == null) {
      final error = Exception('ANIME_SKIP_API_KEY está vazia');
      customLog(error);
      return Result.failure(error);
    }
    final result = await _graphQLClient.query(
      QueryOptions(
        document: gql(AnimeSkipQuery.TIMESTAMPSBYNAME),
        variables: {
          'search': search,
          'offset': offset,
          'limit': limit,
          'sort': sort,
        },
      ),
      link: HttpLink(
        defaultHeaders: {'x-client-id': apiKey},
        App.ANIME_SKIP_API,
      ),
    );

    return switch (result) {
      Empty<QueryResult<Object?>> _ => const Empty(),
      Success<QueryResult<Object?>> data
          when data.data.data?.isEmpty != false =>
        const Empty(),
      Success<QueryResult<Object?>> data => _getSuccess(data),
      Failure<QueryResult<Object?>> error => Result.failure(error.error),
      Cancel<QueryResult<Object?>> _ => const Empty(),
    };
  }

  Result<List<AnimeSkip>> _getSuccess(Success<QueryResult<Object?>> data) {
    final shows = (data.data.data!['searchShows'] as List)
        .map(AnimeSkip.fromMapApi)
        .toList();

    return Result.success(shows);
  }
}
