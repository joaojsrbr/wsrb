// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

import 'package:app_wsrb_jsr/app/my_app.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_audio_handler.dart';

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  late final HiveController hiveController;
  late final AnrollLoginService anrollLoginService;
  late final ThemeController themeController;

  final DioClient dioClient = DioClient();

  Future<void> start(HiveService service) async {
    hiveController = HiveController(service);
    anrollLoginService = AnrollLoginService(dioClient, service);
    themeController = ThemeController(service);
    await Future.wait([hiveController.loadAll(), themeController.loadAll()]);
  }

  final IsarServiceImpl isarServiceImpl = IsarServiceImpl();
  final ConnectionChecker connectionChecker = ConnectionChecker();
  final ValueNotifierList valueNotifierList = ValueNotifierList();

  final HiveService hiveServiceImpl = HiveServiceImpl(start: start);
  await hiveServiceImpl.init();

  final HiveCacheServiceImpl hiveCacheServiceImpl = HiveCacheServiceImpl();

  final LibraryController libraryController =
      LibraryController(isarServiceImpl, hiveController);

  final HistoricController historicController =
      HistoricController(isarServiceImpl);

  final CategoryController categoryController =
      CategoryController(isarServiceImpl);

  Future<void> libraryStart() async {
    await Future.wait([
      historicController.start(),
      categoryController.start(),
      libraryController.start(),
    ]);
  }

  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true),
    isarServiceImpl.startDatabase(onStart: libraryStart),
    hiveCacheServiceImpl.init(),
    PlayerAudioHandlerMixin.startPlayerAudio(),
    connectionChecker.start(),
  ]);

  final ContentRepository contentRepository =
      ContentRepository(hiveController, dioClient);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => anrollLoginService),
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
