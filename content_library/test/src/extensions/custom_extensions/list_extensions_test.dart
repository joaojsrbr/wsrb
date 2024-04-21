import 'package:content_library/content_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('list extensions ...', () async {
    final List<Entity> test = [];
    final AnimeEntity animeEntity = AnimeEntity(
      stringID: 'asdasd',
      url: 'asdasd',
      title: "asdasd",
      source: Source.ANROLL,
      originalImage: "",
    );
    final BookEntity bookEntity = BookEntity(
      stringID: 'asdasd',
      url: 'asdasd',
      title: "asdasd",
      source: Source.ANROLL,
      originalImage: "",
    );

    test.add(animeEntity);
    test.add(bookEntity);

    final index = test.eIndexWhere({
      AnimeEntity: (element, element1) {
        final e1 = element as AnimeEntity;
        final e2 = element1 as AnimeEntity;
        return e1.stringID.contains(e2.stringID);
      },
    }, animeEntity);

    final index2 = test.eIndexWhere({
      BookEntity: (element, element1) {
        final e1 = element as BookEntity;
        final e2 = element1 as BookEntity;
        return e1.stringID.contains(e2.stringID);
      },
    }, bookEntity);

    customLog(index);
    customLog(index2);
  });
}
