// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:app_wsrb_jsr/app/my_app.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_audio_handler.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auto_cache/flutter_auto_cache.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final DioClient dioClient = DioClient();

  final IsarServiceImpl isarServiceImpl = IsarServiceImpl();
  final ConnectionChecker connectionChecker = ConnectionChecker();
  final ValueNotifierList valueNotifierList = ValueNotifierList();

  final HiveService hiveServiceImpl = HiveServiceImpl();
  final HiveController hiveController = HiveController(hiveServiceImpl);
  // late final AnrollLoginService anrollLoginService;
  final ThemeController themeController = ThemeController(hiveServiceImpl);

  final HiveCacheServiceImpl hiveCacheServiceImpl = HiveCacheServiceImpl();
  final LibraryController libraryController =
      LibraryController(isarServiceImpl, hiveController);

  final GraphQLApiClient graphQLApiClient = GraphQLApiClient();
  final AnimeSkipRepository animeSkipRepository =
      AnimeSkipRepository(graphQLApiClient);

  final AnimeSkipController animeSkipController =
      AnimeSkipController(isarServiceImpl);

  final HistoricController historicController =
      HistoricController(isarServiceImpl);

  final CategoryController categoryController =
      CategoryController(isarServiceImpl);

  await isarServiceImpl.startDatabase();

  await Future.wait([
    PermissionUtils.manageExternalStorage(),
    themeController.loadAll(),
    hiveController.loadAll(),
    historicController.start(),
    categoryController.start(),
    animeSkipController.start(),
    libraryController.start(),
    hiveServiceImpl.init(),
    AutoCacheInitializer.initialize(configuration: App.APP_CACHE_CONFIG),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true),
    hiveCacheServiceImpl.init(),
    PlayerAudioHandlerMixin.startPlayerAudio(),
    connectionChecker.start(),
    dotenv.load(fileName: "assets/.env"),
  ]);

  final ContentRepository contentRepository = ContentRepository(
    hiveController,
    dioClient,
    animeSkipRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        // Provider(create: (context) => anrollLoginService),
        Provider(create: (context) => dioClient),
        ChangeNotifierProvider(create: (context) => connectionChecker),
        ChangeNotifierProvider(create: (context) => themeController),
        ChangeNotifierProvider(create: (context) => hiveController),
        ChangeNotifierProvider(create: (context) => libraryController),
        ChangeNotifierProvider(create: (context) => categoryController),
        ChangeNotifierProvider(create: (context) => historicController),
        ChangeNotifierProvider(create: (context) => valueNotifierList),
        ChangeNotifierProvider(create: (context) => DownloadService()),
        Provider(
          create: (context) => contentRepository,
          dispose: (context, repository) => repository.dispose(),
        ),
        ProxyProvider(
          updateShouldNotify: (previous, current) => true,
          update: (context, value, previous) {
            return LibraryService(
              context.watch(),
              context.watch(),
            );
          },
          create: (context) => LibraryService(
            context.read(),
            context.read(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, inputData) async {
    customLog('running $task');

    // if ([App.APP_CACHE_TASK_DELETE_BY_ID, App.APP_CACHE_TASK_DELETE_ALL]
    //         .contains(task) &&
    //     inputData != null) {
    //   return Future.value(false);
    // }

    return Future.value(false);
  });
}
