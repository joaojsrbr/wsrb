import 'package:content_library/src/repository/anime_skip_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gql/ast.dart';
import "package:gql/language.dart" as lang;

void main() {
  test('anime skip query ...', () async {
    final DocumentNode doc = lang.parseString(AnimeSkipQuery.TIMESTAMPSBYNAME);

    final DocumentNode withTypenames = transform(
      doc,
      [
        // AddTypenames(),
      ],
    );

    print(
      lang.printNode(withTypenames),
    );
  });
}
