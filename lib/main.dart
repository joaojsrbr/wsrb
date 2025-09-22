// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:app_wsrb_jsr/app/my_app.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_audio_handler.dart';
import 'package:app_wsrb_jsr/app/utils/content_utils.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

@pragma('vm:entry-point')
void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final DioClient dioClient = DioClient();

  final IsarServiceImpl isarServiceImpl = IsarServiceImpl();

  final ValueNotifierList valueNotifierList = ValueNotifierList();
  final DownloadService downloadService = DownloadService();

  final AppConfigController appConfigController = AppConfigController(isarServiceImpl);

  final LibraryController libraryController = LibraryController(
    isarServiceImpl,
    appConfigController,
  );

  final GraphQLApiClient graphQLApiClient = GraphQLApiClient();
  final AnimeSkipRepository animeSkipRepository = AnimeSkipRepository(graphQLApiClient);

  final HistoricController historicController = HistoricController(isarServiceImpl);

  final CategoryController categoryController = CategoryController(isarServiceImpl);

  timeago.setLocaleMessages('pt_br', timeago.PtBrMessages());
  timeago.setDefaultLocale('pt_br');

  // Start Isar
  await isarServiceImpl.startDatabase();
  await appConfigController.start();

  await Future.wait([
    historicController.start(),
    categoryController.start(),
    libraryController.start(),
    NotificationService.I.init(onTap: ContentUtils.notificationResponse),
    Workmanager().initialize(_callbackDispatcher),
  ]);

  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    PlayerAudioHandlerMixin.startPlayerAudio(),
    dotenv.load(fileName: "assets/.env"),
  ]);

  // elapsed.printAndStop('MAIN');

  final ContentRepository contentRepository = ContentRepository(
    appConfigController,
    dioClient,
    animeSkipRepository,
  );

  await contentRepository.session.init();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => dioClient),
        ChangeNotifierProvider(create: (context) => appConfigController),
        ChangeNotifierProvider(create: (context) => libraryController),
        ChangeNotifierProvider(create: (context) => categoryController),
        ChangeNotifierProvider(create: (context) => historicController),
        ChangeNotifierProvider(create: (context) => valueNotifierList),
        ChangeNotifierProvider(create: (context) => downloadService),
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
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    switch (task) {
      case App.APP_WORK_NEW_RELEASE:
        await ReleaseUpdateService.newReleases();
        break;
    }

    return Future.value(true);
  });
}


//  runApp(
//     StatefulBuilder(
//       builder: (context, setState) => MaterialApp(
//         theme: ThemeData.dark(),
//         builder: (context, child) {
//           return AppNotificationOverlay(child: child!);
//         },
//         home: Scaffold(
//           appBar: AppBar(title: Text("Demo Overlay")),
//           body: Builder(
//             builder: (context) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         context.showTopNotification(
//                           Text("Olá do Top!"),
//                           showCountdown: false,
//                         );
//                       },
//                       child: Text("Show Top"),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         context.showBottomNotification(
//                           Text("Olá do Bottom!"),
//                           showCountdown: false,
//                         );
//                       },
//                       child: Text("Show Bottom"),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         context.showErrorNotification(Exception("test123").toString());
//                       },
//                       child: Text("Show Error"),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     ),
//   );
//   return;