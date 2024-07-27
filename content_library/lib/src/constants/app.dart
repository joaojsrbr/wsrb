// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';

class App {
  const App._();

  static const String NEOX_URL = 'https://nexoscans.com';

  static const String DEMON_SECT_URL = 'https://demonsect.com.br';

  static const String GOYABU_URL = 'https://goyabu.to';

  static const String ANROLL_URL = 'https://www.anroll.net';

  static const String ANROLL_USER_URL = 'https://api-user.anroll.net';

  static Map<String, String> HEADERS = {
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
  };

  static const String ANI_LIST = 'https://graphql.anilist.co';

  static const ImageProvider DEFAULT_IMAGE_PLACEHOLDER =
      AssetImage('assets/default-placeholder.png');

  static const ImageProvider IMAGE_GRAY = AssetImage('assets/gray_color.png');
  static const ImageProvider IMAGE_BLACK = AssetImage('assets/black_color.jpg');

  static const String APP_MAIN_BOX_NAME = 'WSRB_HIVE';
  static const String APP_CACHE_BOX_NAME = 'WSRB_HIVE_CACHE';

  static const String APP_DIRECTORY = "/storage/emulated/0/Wsrb";
  // static const String APP_CACHE_TASK_DELETE_BY_ID = 'TASK_CLEAR_CACHE_BY_ID';
  // static const String APP_CACHE_TASK_DELETE_ALL = 'TASK_CLEAR_CACHE_ALL';
}
