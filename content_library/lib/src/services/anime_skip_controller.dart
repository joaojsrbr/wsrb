import 'package:content_library/content_library.dart';
import 'package:isar/isar.dart';

class AnimeSkipController {
  final IsarServiceImpl _isarService;

  AnimeSkipController(this._isarService);

  final List<AnimeSkipEntity> _entities = [];

  Future<void> start() async {
    final animeSkipCollections =
        await _isarService.collection<AnimeSkipEntity>();

    final animeskips = await animeSkipCollections.where().findAll();

    _entities.addAll(animeskips);
  }

  Future<Result<(bool, int?)>> save(AnimeEntity animeEntity) async {
    if (animeEntity.animeSkip.value == null) {
      return Result.failure(Exception('animeEntity.animeSkip.value == null'));
    }

    final result = await _isarService.add(
      entity: animeEntity.animeSkip.value,
    );

    await animeEntity.animeSkip.save();

    if (!_entities.contains(animeEntity.animeSkip.value)) {
      _entities.add(animeEntity.animeSkip.value!);
    }

    return result;
  }
}
