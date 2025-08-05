import 'package:content_library/content_library.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLApiClient {
  late GraphQLClient _graphQLClient = GraphQLClient(
    cache: GraphQLCache(),
    link: HttpLink(''),
  );

  GraphQLApiClient();

  Future<Result<QueryResult>> query(QueryOptions options, {required Link link}) async {
    try {
      _graphQLClient = _graphQLClient.copyWith(link: link);

      final QueryResult result = await _graphQLClient.query(options);

      return Result.success(result);
    } on OperationException catch (error, stack) {
      customLog(error, error: error, stackTrace: stack);
      return Result.failure(error);
    }
  }
}
