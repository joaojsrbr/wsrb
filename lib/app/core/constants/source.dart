// ignore_for_file: constant_identifier_names

import 'package:app_wsrb_jsr/app/core/constants/app.dart';

enum Source {
  NEOX_SCANS('Neox Scans', App.NEOX_URL, 'Neox Scans');
  // MANGA_BTT('Manga BTT', App.MANGABTTURL);

  final String baseURL;
  final String label;
  final String name;

  const Source(this.label, this.baseURL, this.name);
}
