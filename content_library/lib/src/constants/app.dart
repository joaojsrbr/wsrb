// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_auto_cache/flutter_auto_cache.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class App {
  const App._();

  static const String NEOX_URL = 'https://nexoscans.com';

  static const String ANIME_SKIP_API = 'https://api.anime-skip.com/graphql';

  static const String DEMON_SECT_URL = 'https://demonsect.com.br';

  static const String GOYABU_URL = 'https://goyabu.to';

  static const String SLIME_READ_URL = 'https://slimeread.com';

  static const String BETTER_ANIME_URL = 'https://betteranime.net';

  static const String ANROLL_URL = 'https://www.anroll.net';

  static const String REMANGAS_URL = 'https://remangas.net';

  static const String ANROLL_USER_URL = 'https://api-user.anroll.net';

  static final String? ANIME_SKIP_API_KEY = dotenv.env['ANIME_SKIP_API_KEY'];

  static Map<String, String> HEADERS = {
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0",
  };

  static const CONTENT_APP_CACHE_CONFIG = CacheConfiguration(
    sizeOptions: CacheSizeOptions(maxMb: 20),
    dataCacheOptions: DataCacheOptions(
      substitutionPolicy: SubstitutionPolicies.lru,
      invalidationMethod: TTLInvalidationMethod(maxDuration: Duration(days: 2)),
    ),
  );

  static CacheManager APP_IMAGE_CACHE = CacheManager(
    Config(
      "WSRB_IMAGE",
      stalePeriod: const Duration(days: 1),
      repo: JsonCacheInfoRepository(databaseName: "WSRB_IMAGE"),
      fileSystem: IOFileSystem("WSRB_IMAGE"),
      fileService: HttpFileService(),
    ),
  );

  static const String ANI_LIST = 'https://graphql.anilist.co';

  static const ImageProvider DEFAULT_IMAGE_PLACEHOLDER = AssetImage(
    'assets/default-placeholder.png',
  );

  static const ImageProvider IMAGE_GRAY = AssetImage('assets/gray_color.png');
  static const ImageProvider IMAGE_BLACK = AssetImage('assets/black_color.jpg');

  static const String APP_MAIN_BOX_NAME = 'WSRB_HIVE';
  static const String APP_CACHE_BOX_NAME = 'WSRB_HIVE_CACHE';

  static const String APP_DIRECTORY = "/storage/emulated/0/Wsrb";
  static const String APP_WORK_NEW_RELEASE = 'APP_WORK_NEW_RELEASE';
  // static const String APP_CACHE_TASK_DELETE_ALL = 'TASK_CLEAR_CACHE_ALL';
}
