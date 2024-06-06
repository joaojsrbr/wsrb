import 'dart:async';

import 'package:app_wsrb_jsr/app/my_app.dart';
import 'package:content_library/content_library.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MediaKit.ensureInitialized();
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
  final ValueNotifierList valueNotifierList = ValueNotifierList();
  final HiveService hiveServiceImpl = HiveServiceImpl(start: start);
  final HiveCacheServiceImpl hiveCacheServiceImpl = HiveCacheServiceImpl();

  final LibraryController libraryController =
      LibraryController(isarServiceImpl);

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
    hiveServiceImpl.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => anrollLoginService),
        Provider(create: (context) => dioClient),
        ChangeNotifierProvider(create: (context) => themeController),
        ChangeNotifierProvider(create: (context) => hiveController),
        ChangeNotifierProvider(create: (context) => libraryController),
        ChangeNotifierProvider(create: (context) => categoryController),
        ChangeNotifierProvider(create: (context) => historicController),
        ChangeNotifierProvider(create: (context) => valueNotifierList),
        Provider(
          create: (context) => ContentRepository(
            context.read(),
            context.read(),
          ),
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
