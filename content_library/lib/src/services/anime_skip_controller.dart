import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

class AnimeSkipController extends ChangeNotifier {
  final IsarServiceImpl _isarService;
  final Debouncer _debouncer = Debouncer(
    duration: const Duration(milliseconds: 200),
  );

  final Subscriptions _subscriptions = Subscriptions();

  AnimeSkipController(this._isarService);

  final List<AnimeSkipEntity> _entities = [];

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
  }

  Future<void> start() async {
    final Elapsed elapsed = Elapsed()..start();

    final animeSkipCollections =
        await _isarService.collection<AnimeSkipEntity>();

    final animeskips = await animeSkipCollections.where().findAll();
    _subscriptions.addAll(
      [
        animeSkipCollections.watchLazy().listen(_watchColletion),
      ],
    );

    _entities.addAll(animeskips);
    elapsed.printAndStop(runtimeType.toString());
  }

  void _watchColletion(data) async {
    final animeSkipCollections =
        await _isarService.collection<AnimeSkipEntity>();
    final animeskips = await animeSkipCollections.where().findAll();

    _entities
      ..clear()
      ..addAll(animeskips);
    _debouncer.call(notifyListeners);
  }

  Future<Result<(bool, int?)>> save(AnimeSkipEntity animeSkipEntity) async {
    final result = await _isarService.add(
      entity: animeSkipEntity,
    );

    return result;
  }
}
