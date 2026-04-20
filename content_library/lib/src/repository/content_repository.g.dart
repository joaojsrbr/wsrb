// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// SourceGenerator
// **************************************************************************

part of 'content_repository.dart';
// GENERATED CODE - DO NOT MODIFY

@MappableEnum()
enum Source {
  GOYABU(
    id: 'goyabu',
    label: 'Goyabu',
    baseUrl: 'https://goyabu.to',
    contentType: ContentType.ANIME,
  ),
  TOP_ANIMES(
    id: 'top_animes',
    label: 'Top Animes',
    baseUrl: 'https://topanimes.net',
    contentType: ContentType.ANIME,
  ),
  ;

  const Source({
    required this.id,
    required this.baseUrl,
    required this.contentType,
    required this.label,
  });

  final String id;
  final String baseUrl;
  final ContentType contentType;
  final String label;

  RSource create(SourceContext ctx, {int initialIndex = 0}) {
    switch (this) {
      case Source.GOYABU:
        return GoyabuSource(ctx, initialIndex: initialIndex);

      case Source.TOP_ANIMES:
        return TopAnimesSource(ctx, initialIndex: initialIndex);
    }
  }

  static Source fromId(String id) {
    return switch (id.toLowerCase()) {
      'goyabu' => Source.GOYABU,
      'top_animes' => Source.TOP_ANIMES,
      _ => throw Exception('Source not found: $id'),
    };
  }

  @override
  String toString() => label;
}
