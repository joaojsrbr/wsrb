import 'package:graphql_flutter/graphql_flutter.dart';

abstract interface class AniListRepository {
  Future<QueryResult> post({
    required String query,
    Map<String, dynamic> variables = const {},
  });
}

class AniListRepositoryImpl implements AniListRepository {
  final GraphQLClient _client;

  const AniListRepositoryImpl(this._client);

  @override
  Future<QueryResult> post({
    required String query,
    Map<String, dynamic> variables = const {},
  }) async {
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables,
    );

    final QueryResult result = await _client.query(options);

    return result;
  }
}
