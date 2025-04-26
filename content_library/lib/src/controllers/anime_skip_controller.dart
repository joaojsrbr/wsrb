import 'package:content_library/content_library.dart';
import 'package:content_library/src/repository/anime_skip_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

class AnimeSkipController extends ChangeNotifier {
  final IsarServiceImpl _isarService;
  final Debouncer _debouncer = Debouncer(
    duration: const Duration(milliseconds: 200),
  );

  late final InAnimeSkipRepository _inAnimeSkipRepository;

  final Subscriptions _subscriptions = Subscriptions();

  AnimeSkipController(this._isarService) {
    _inAnimeSkipRepository = InAnimeSkipRepository();
  }

  InAnimeSkipRepository get repo => _inAnimeSkipRepository;

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

    repo.updateRepository([animeskips]);

    elapsed.printAndStop(runtimeType.toString());
  }

  void _watchColletion(data) async {
    final animeSkipCollections =
        await _isarService.collection<AnimeSkipEntity>();
    final animeskips = await animeSkipCollections.where().findAll();

    repo.updateRepository([animeskips]);

    _debouncer.call(notifyListeners);
  }

  Future<Result<(bool, int?)>> save(AnimeSkipEntity animeSkipEntity) async {
    final result = await _isarService.add(
      entity: animeSkipEntity,
    );

    return result;
  }
}
