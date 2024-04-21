// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';

class App {
  const App._();

  /// [URL] do site da NeoxScan [SCAN].
  static const String NEOX_URL = 'https://nexoscans.net';

  /// [URL] do site da Demonsect [SCAN].
  static const String DEMON_SECT_URL = 'https://demonsect.com.br';

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

  static const String APP_MAIN_BOX_NAME = 'WSRB_HIVE';
  static const String APP_CACHE_BOX_NAME = 'WSRB_HIVE_CACHE';
  static const String APP_CACHE_TASK_DELETE_BY_ID = 'TASK_CLEAR_CACHE_BY_ID';
  static const String APP_CACHE_TASK_DELETE_ALL = 'TASK_CLEAR_CACHE_ALL';
}
