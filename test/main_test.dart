import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikan_api/jikan_api.dart';

void main() {
  test('main ...', () async {
    const query = 'Knight of the Frozen Flower';
    final jikan = Jikan();
    final response = await jikan
        .searchManga(
      query: query,
      type: MangaType.manhwa,
    )
        .then(
      (value) {
        return value.firstWhereOrNull(
          (element) => element.titleSynonyms.contains(query),
        );
      },
    );

    if (response != null) {
      customLog(response);
      final pictureResponse = await jikan.getMangaPictures(response.malId);
      customLog(pictureResponse);
    }
  });
}
