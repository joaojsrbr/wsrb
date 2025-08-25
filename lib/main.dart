// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:app_wsrb_jsr/app/my_app.dart';
import 'package:app_wsrb_jsr/app/ui/player/mixins/player_audio_handler.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  final AppConfigController appConfigController = AppConfigController(isarServiceImpl);

  final LibraryController libraryController = LibraryController(
    isarServiceImpl,
    appConfigController,
  );

  final GraphQLApiClient graphQLApiClient = GraphQLApiClient();
  final AnimeSkipRepository animeSkipRepository = AnimeSkipRepository(graphQLApiClient);

  final AnimeSkipController animeSkipController = AnimeSkipController(isarServiceImpl);

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
    animeSkipController.start(),
    libraryController.start(),
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true),
  ]);

  // WorkmanagerPlatform.instance;

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
        ChangeNotifierProvider(create: (context) => animeSkipController),
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

    // if (App.APP_RELEASE_DOWNLOAD.contains(task) && inputData != null) {
    //   await DownloadService.downloadReleaseVideoByHLSWork(inputData);
    //   return Future.value(true);
    // }

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