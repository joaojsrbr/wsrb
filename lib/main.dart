import 'package:app_wsrb_jsr/app/core/interfaces/hive_service.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_controller.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_service.dart';
import 'package:app_wsrb_jsr/app/my_app.dart';
import 'package:app_wsrb_jsr/app/repositories/content_cache.dart';
import 'package:app_wsrb_jsr/app/repositories/content_repository.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late final HiveController hiveController;
  MediaKit.ensureInitialized();

  Future<void> start(HiveService service) async {
    hiveController = HiveController(service);
    await hiveController.loadAll();
  }

  final HiveService hiveServiceImpl = HiveServiceImpl(
    'wsrb_hive',
    start: start,
  );

  final ContentCache bookCache = ContentCache(hiveServiceImpl);

  await Future.wait([
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true),
    hiveServiceImpl.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => hiveController),
        Provider(
          create: (context) => ContentRepository(context.read()),
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
    customLog('running $task');
    final cacheResult = await ContentCache.cacheTask(task, inputData);
    return Future.value(cacheResult ?? true);
  });
}
