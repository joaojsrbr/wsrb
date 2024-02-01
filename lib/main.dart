import 'package:app_wsrb_jsr/app/core/controllers/open_container_controller.dart';
import 'package:app_wsrb_jsr/app/core/interfaces/hive_service.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_controller.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_service.dart';
import 'package:app_wsrb_jsr/app/my_app.dart';
import 'package:app_wsrb_jsr/app/repositories/content_cache.dart';
import 'package:app_wsrb_jsr/app/repositories/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late final HiveController hiveController;

  Future<void> start(HiveService service) async {
    hiveController = HiveController(service);
    await hiveController.loadAll();
  }

  final HiveService hiveServiceImpl = HiveServiceImpl(
    'wsrb_hive',
    start: start,
  );

  final ContentCache bookCache = ContentCache(hiveServiceImpl);
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  await Future.wait([hiveServiceImpl.init()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => hiveController),
        ChangeNotifierProvider(create: (context) => OpenContainerController()),
        Provider(
          create: (context) => BookRepository(context.read()),
          dispose: (context, repository) => repository.dispose(),
        ),
        Provider(create: (context) => bookCache)
      ],
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'task_clear_allCache') {
      // await BookCache.clearAllCache();
      return Future.value(true);
    } else if (task == 'task_clear_cache' && inputData != null) {
      final removeID = inputData['remove_id'] as String;
      await ContentCache.task(removeID);
      return Future.value(true);
    }
    return Future.value(true);
  });
}
