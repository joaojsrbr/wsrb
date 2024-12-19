import 'package:content_library/content_library.dart';
import 'package:content_library/src/models/anime_skip.dart';

abstract interface class IAnimeSkip {
  Future<Result<List<AnimeSkip>>> getTimeStampsByName({
    required String search,
    int offset = 0,
    int limit = 10,
    String sort = "DESC",
  });
}
