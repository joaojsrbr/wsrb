// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app/my_app.dart';
import 'app/ui/player/mixins/player_audio_handler.dart';
import 'app/utils/content_utils.dart';

@pragma('vm:entry-point')
void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final DioClient dioClient = DioClient();

  final ValueNotifierList valueNotifierList = ValueNotifierList();

  // Services
  final IsarServiceImpl isarServiceImpl = IsarServiceImpl();
  final AppConfigService appConfigService = AppConfigService(isarServiceImpl);
  final DownloadService downloadService = DownloadService();
  final LibraryService libraryService = LibraryService(
    isarServiceImpl,
    appConfigService,
  );
  final HistoricService historicService = HistoricService(isarServiceImpl);

  final AppConfigController appConfigController = AppConfigController(
    appConfigService,
  );
  final LibraryController libraryController = LibraryController(libraryService);
  final HistoricController historicController = HistoricController(
    historicService,
  );
  final CategoryController categoryController = CategoryController(
    isarServiceImpl,
  );

  final GraphQLApiClient graphQLApiClient = GraphQLApiClient();
  final AnimeSkipRepository animeSkipRepository = AnimeSkipRepository(
    graphQLApiClient,
  );

  timeago.setLocaleMessages('pt_br', timeago.PtBrMessages());
  timeago.setDefaultLocale('pt_br');

  // Start Isar
  await isarServiceImpl.startDatabase();
  await appConfigService.start();

  await Future.wait([Workmanager().initialize(_callbackDispatcher)]);

  await Future.wait([
    historicService.start(),
    categoryController.start(),
    libraryService.start(),
    NotificationService.I.init(onTap: ContentUtils.notificationResponse),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    PlayerAudioHandlerMixin.startPlayerAudio(),
    dotenv.load(fileName: ".env"),
  ]);

  await Workmanager().registerPeriodicTask(
    UniqueKey().toString(),
    App.APP_WORK_DELETE_CONTENT,
    tag: App.APP_WORK_DELETE_CONTENT,
    frequency: const Duration(days: 3),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
  );
  // elapsed.printAndStop('MAIN');

  customLog(dotenv.env['ANIME_SKIP_API_KEY']);

  final ContentRepository contentRepository = ContentRepository(
    appConfigService: appConfigService,
    dio: dioClient,
    animeSkipRepository: animeSkipRepository,
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
      case App.APP_WORK_DELETE_CONTENT:
        // TODO: IMPLEMENTAR O DIA QUE VAI SER EXCLUIDO E ADICIONAR NAS CONFIG UMA OPCAO

        // await ContentService.deleteNoFavoriteContent();
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