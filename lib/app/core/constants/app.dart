// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';

class App {
  const App._();

  /// [URL] do site da NeoxScan [SCAN].
  static const String NEOX_URL = 'https://nexoscans.com';

  /// [URL] do site da Anroll [ANIME].
  static const String ANROLL_URL = 'https://www.anroll.net';

  static Map<String, String> HEADERS = {
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
  };

  /// [URL] da api da AniList.
  static const String ANI_LIST = 'https://graphql.anilist.co';

  /// default [Image] placehold
  static const ImageProvider DEFAULT_IMAGE_PLACEHOLDER =
      AssetImage('assets/default-placeholder.png');
}
