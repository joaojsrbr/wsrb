import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

class AnimeSkipController extends ChangeNotifier {
  final IsarServiceImpl _isarService;

  AnimeSkipController(this._isarService);

  final List<AnimeSkipEntity> _entities = [];

  Future<void> start() async {
    final animeSkipCollections =
        await _isarService.collection<AnimeSkipEntity>();

    final animeskips = await animeSkipCollections.where().findAll();

    _entities.addAll(animeskips);
  }

  Future<Result<(bool, int?)>> save(AnimeSkipEntity animeSkipEntity) async {
    final result = await _isarService.add(
      entity: animeSkipEntity,
    );

    if (!_entities.contains(animeSkipEntity)) {
      _entities.add(animeSkipEntity);
    }
    notifyListeners();

    return result;
  }
}
