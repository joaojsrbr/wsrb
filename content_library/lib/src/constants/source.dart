// ignore_for_file: constant_identifier_names

import 'package:content_library/src/constants/app.dart';
import 'package:content_library/src/constants/content_type.dart';

abstract class _DisableEnum {
  bool get disable;
}

enum Source implements _DisableEnum {
  ANROLL('Anroll', App.ANROLL_URL, 'Anroll', ContentType.ANIME),
  NEOX_SCANS('Neox Scans', App.NEOX_URL, 'Neox Scans', ContentType.BOOK),
  DEMON_SECT('Demon Sect', App.DEMON_SECT_URL, 'Demon Sect', ContentType.BOOK),
  GOYABU('Goyabu', App.GOYABU_URL, 'Goyabu', ContentType.ANIME),
  SLIMEREAD('SlimeRead', App.SLIME_READ_URL, 'SlimeRead', ContentType.BOOK);

  static final Set<Source> _disableSource = {
    Source.NEOX_SCANS,
    Source.DEMON_SECT,
    Source.SLIMEREAD,
  };

  static bool disableSourceMenuFilter(Source source) {
    return {
      Source.ANROLL,
      Source.GOYABU,
    }.contains(source);
  }

  final String baseURL;
  final String label;
  final String name;
  final ContentType contentType;

  const Source(
    this.label,
    this.baseURL,
    this.name,
    this.contentType,
  );

  @override
  String toString() => label;

  @override
  bool get disable => _disableSource.contains(this);

  static List<Source> list =
      Source.values.where((source) => !source.disable).toList();
}
