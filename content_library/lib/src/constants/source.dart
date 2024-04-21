// ignore_for_file: constant_identifier_names

import 'package:content_library/src/constants/app.dart';

enum Source {
  ANROLL('Anroll', App.ANROLL_URL, 'Anroll'),
  NEOX_SCANS('Neox Scans', App.NEOX_URL, 'Neox Scans'),
  DEMON_SECT('Demon Sect', App.DEMON_SECT_URL, 'Demon Sect');
  // MANGA_BTT('Manga BTT', App.MANGABTTURL);

  final String baseURL;
  final String label;
  final String name;

  const Source(this.label, this.baseURL, this.name);

  @override
  String toString() => label;
}
