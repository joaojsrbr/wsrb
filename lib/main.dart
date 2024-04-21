import 'package:app_wsrb_jsr/app/core/services/theme_controller.dart';
import 'package:app_wsrb_jsr/app/my_app.dart';
import 'package:app_wsrb_jsr/app/utils/value_notifier_list.dart';
import 'package:content_library/content_library.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:workmanager/workmanager.dart';
import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  late final HiveController hiveController;
  late final ThemeController themeController;

  Future<void> start(HiveService service) async {
    hiveController = HiveController(service);
    themeController = ThemeController(service);
    await Future.wait([hiveController.loadAll(), themeController.loadAll()]);
  }

  final IsarServiceImpl isarServiceImpl = IsarServiceImpl();
  final ValueNotifierList valueNotifierList = ValueNotifierList();
  final HiveService hiveServiceImpl = HiveServiceImpl(start: start);
  final HiveService hiveCacheServiceImpl = HiveCacheServiceImpl();

  final ContentCache bookCache = ContentCache(hiveCacheServiceImpl);

  final LibraryController libraryController =
      LibraryController(isarServiceImpl);

  final CategoryController categoryController =
      CategoryController(isarServiceImpl);

  Future<void> libraryStart() async {
    await categoryController.start();
    await libraryController.start();
  }

  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true),
    isarServiceImpl.startDatabase(onStart: libraryStart),
    hiveServiceImpl.init(),
    hiveCacheServiceImpl.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => themeController),
        ChangeNotifierProvider(create: (context) => hiveController),
        ChangeNotifierProvider(create: (context) => libraryController),
        ChangeNotifierProvider(create: (context) => categoryController),
        ChangeNotifierProvider(create: (context) => valueNotifierList),
        Provider(
          create: (context) => ContentRepository(context.read()),
          dispose: (context, repository) => repository.dispose(),
        ),
        Provider(create: (context) => bookCache),
      ],
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    customLog('running $task');

    if ([App.APP_CACHE_TASK_DELETE_BY_ID, App.APP_CACHE_TASK_DELETE_ALL]
            .contains(task) &&
        inputData != null) {
      final result = await ContentCache.cacheTask(task, inputData);
      return Future.value(result);
    }

    return Future.value(false);
  });
}
