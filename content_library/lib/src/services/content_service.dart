import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

class ContentService {
  static Future<void> deleteNoFavoriteContent() async {
    final isarServiceImpl = IsarServiceImpl();

    await isarServiceImpl.startDatabase(inspector: false);

    final animeColetions = await isarServiceImpl.collection<AnimeEntity>();

    final bookColetions = await isarServiceImpl.collection<BookEntity>();

    final entities = await Future.wait([
      animeColetions.filter().isFavoriteEqualTo(false).findAll(),
      bookColetions.filter().isFavoriteEqualTo(false).findAll(),
    ]);

    await isarServiceImpl.removeAll(entities: entities.flattened.toList());
  }
}
