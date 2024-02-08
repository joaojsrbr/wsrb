import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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

class Test extends ChangeNotifier {
  late final Test2 _test2;
  late final Test2 _test3;
  late final Test2 _test4;

  Listenable? _listenable;

  Test() {
    _test2 = Test2();
    _test3 = Test2();
    _test4 = Test2();
    _listenable = Listenable.merge([_test2, _test3, _test4])
      ..addListener(notifyListeners);
  }

  @override
  void dispose() {
    _listenable?.removeListener(notifyListeners);
    _listenable = null;
    super.dispose();
  }
}

class Test2 extends ChangeNotifier {}
