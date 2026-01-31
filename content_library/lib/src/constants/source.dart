// ignore_for_file: constant_identifier_names

import 'package:content_library/src/constants/app.dart';
import 'package:content_library/src/constants/content_type.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'generated/source.mapper.dart';

@MappableEnum()
enum Source {
  ANROLL('Anroll', App.ANROLL_URL, 'Anroll', ContentType.ANIME),
  GOYABU('Goyabu', App.GOYABU_URL, 'Goyabu', ContentType.ANIME),
  TOP_ANIMES("TopAnimes", App.TOP_ANIMES_URL, 'TopAnimes', ContentType.ANIME),
  BETTER_ANIME('BetterAnime', App.BETTER_ANIME_URL, 'Better Anime', ContentType.ANIME);

  const Source(this.label, this.baseURL, this.name, this.contentType);

  final String baseURL;
  final String label;
  final String name;
  final ContentType contentType;

  @override
  String toString() => label;

  bool get disable => false;

  static bool disableSourceMenuFilter(Source source) {
    return {Source.ANROLL, Source.GOYABU, Source.BETTER_ANIME}.contains(source);
  }

  static List<Source> list = Source.values.where((source) => !source.disable).toList();
}
