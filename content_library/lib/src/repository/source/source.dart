// ignore_for_file: non_constant_identifier_names

import '../../constants/source.dart';
import '../../models/content.dart';
import '../../models/data.dart';
import '../../models/release.dart';
import '../../utils/result.dart';
import '../content_repository.dart';

abstract class RSource {
  final int initialIndex;

  final ContentRepository contentRepository;

  const RSource(
    this.contentRepository, {
    required this.initialIndex,
  });

  Source get source;

  String get BASE_URL;

  Future<bool> loadData();

  Future<Result<Content>> getData(Content content);

  Future<Result<List<Data>>> getContent(Release release);

  Future<Result<Content>> getReleases(Content content, int page);

  Future<Result<List<Content>>> search(String query);
}
