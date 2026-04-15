import 'package:content_library/src/constants/content_type.dart';

/// Annotation to mark a source class.
/// When running `dart run build_runner build`, this will automatically
/// generate the Source enum and source factories.
class SourceEntry {
  final String id;
  final String baseUrl;
  final ContentType contentType;
  final String label;

  const SourceEntry({
    required this.label,
    required this.id,
    required this.baseUrl,
    required this.contentType,
  });
}
