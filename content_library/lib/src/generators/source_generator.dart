import 'package:build/build.dart';
import 'package:content_library/src/annotations/source_annotation.dart';
import 'package:source_gen/source_gen.dart';

Builder sourceGenerator(BuilderOptions options) => LibraryBuilder(
  SourceGenerator(),
  generatedExtension: '.g.dart',
  options: BuilderOptions({'target': 'lib/src/repository/source/source_enum.dart'}),
);

class SourceGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final buffer = StringBuffer();

    final sourceChecker = TypeChecker.fromRuntime(SourceEntry);

    final sources = <_SourceData>[];

    for (final element in library.classes) {
      if (element.name == 'RSource') continue;

      final annotation = sourceChecker.firstAnnotationOf(element);
      if (annotation == null) continue;

      final reader = ConstantReader(annotation);

      final id = reader.read('id').stringValue;
      final baseUrl = reader.read('baseUrl').stringValue;
      final contentType = reader.read('contentType').revive().accessor;
      final label = reader.read('label').stringValue;

      sources.add(
        _SourceData(
          className: element.name,
          id: id,
          baseUrl: baseUrl,
          contentType: contentType,
          label: label,
        ),
      );
    }

    if (sources.isEmpty) return '';

    sources.sort((a, b) => a.className.compareTo(b.className));

    // buffer.writeln("import 'package:dart_mappable/dart_mappable.dart';");
    // buffer.writeln("import 'package:content_library/content_library.dart';");
    buffer.writeln("part of 'content_repository.dart';");
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY\n');

    buffer.writeln('@MappableEnum()');
    buffer.writeln('enum Source {');

    for (final s in sources) {
      final enumName = _toEnumName(s.className);

      buffer.writeln('  $enumName(');
      buffer.writeln("    id: '${s.id}',");
      buffer.writeln("    label: '${s.label}',");
      buffer.writeln("    baseUrl: '${s.baseUrl}',");
      buffer.writeln("    contentType: ${s.contentType},");
      buffer.writeln('  ),');
    }

    buffer.writeln('  ;\n');

    buffer.writeln('''
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
''');

    // 🔥 Factory automática
    buffer.writeln('''
  RSource create(SourceContext ctx, {int initialIndex = 0}) {
    switch (this) {
''');

    for (final s in sources) {
      final enumName = _toEnumName(s.className);

      buffer.writeln('''
      case Source.$enumName:
        return ${s.className}(ctx, initialIndex: initialIndex);
''');
    }

    buffer.writeln('''
    }
  }
''');

    buffer.writeln('}');

    return buffer.toString();
  }

  String _toEnumName(String className) {
    return className
        .replaceAll('Source', '')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
        .toUpperCase();
  }
}

class _SourceData {
  final String className;
  final String id;
  final String baseUrl;
  final String contentType;
  final String label;

  _SourceData({
    required this.className,
    required this.id,
    required this.baseUrl,
    required this.contentType,
    required this.label,
  });
}
