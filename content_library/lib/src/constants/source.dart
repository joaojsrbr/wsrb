// ignore_for_file: constant_identifier_names

import 'package:content_library/src/constants/app.dart';

abstract class _DisableEnum {
  bool get disable;
}

enum Source implements _DisableEnum {
  ANROLL('Anroll', App.ANROLL_URL, 'Anroll'),
  NEOX_SCANS('Neox Scans', App.NEOX_URL, 'Neox Scans'),
  DEMON_SECT('Demon Sect', App.DEMON_SECT_URL, 'Demon Sect'),
  GOYABU('Goyabu', App.GOYABU_URL, 'Goyabu');

  static final Set<Source> _disableSource = {
    Source.NEOX_SCANS,
    Source.DEMON_SECT,
  };

  final String baseURL;
  final String label;
  final String name;

  const Source(this.label, this.baseURL, this.name);

  @override
  String toString() => label;

  @override
  bool get disable => _disableSource.contains(this);

  static List<Source> get list =>
      Source.values.where((source) => !source.disable).toList();
}
