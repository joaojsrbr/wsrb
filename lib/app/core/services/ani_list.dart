import 'package:app_wsrb_jsr/app/core/constants/app.dart';
import 'package:app_wsrb_jsr/app/repositories/ani_list_repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AniListService implements AniListRepository {
  late final AniListRepository _aniListRepository;

  late final GraphQLClient _client;

  AniListService() {
    final HttpLink httpLink = HttpLink(App.ANI_LIST);

    _client = GraphQLClient(cache: GraphQLCache(), link: httpLink);

    _aniListRepository = AniListRepositoryImpl(_client);
  }

  static const String queryCoverImage = r"""
    query ($search: String){
          Media (search: $search) {
              id
              title {
                  romaji
              }
              bannerImage
              coverImage {
                  medium
                  large
                  extraLarge
              }
          }
      }
    """;

  @override
  Future<QueryResult> post({
    required String query,
    Map<String, dynamic> variables = const {},
  }) async {
    return await _aniListRepository.post(
      query: query,
      variables: variables,
    );
  }
}
