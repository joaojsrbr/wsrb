// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:app_wsrb_jsr/app/ui/download/view/download_view.dart';
import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/routes/shared_axis_transition_page_wrapper.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/view/content_information_view.dart';
import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:app_wsrb_jsr/app/ui/reading/view/reading_view.dart';
import 'package:go_router/go_router.dart';

class RouteName {
  const RouteName._();
  static const String HOME = '/';
  static const String CONTENTINFO = '/contentInfo';
  static const String READ = '/read';
  static const String PLAYER = '/player';
  static const String DOWNLOAD = '/downloadView';
  // static const CATEGORY = '/category';
  // static const TEST = '/test';
}

final appRoutes = GoRouter(
  initialLocation: RouteName.HOME,
  routes: [
    GoRoute(
      path: RouteName.HOME,
      pageBuilder: (context, state) {
        return SharedAxisTransitionPageWrapper(
          transitionKey: state.pageKey,
          screen: const HomeView(),
        );
      },
      routes: [
        GoRoute(
          path: RouteName.CONTENTINFO.subRouter,
          pageBuilder: (context, state) {
            return SharedAxisTransitionPageWrapper(
              arguments: state.extra,
              transitionKey: state.pageKey,
              screen: const BookInformationView(),
            );
          },
        ),
        GoRoute(
          path: RouteName.DOWNLOAD.subRouter,
          pageBuilder: (context, state) {
            return SharedAxisTransitionPageWrapper(
              arguments: state.extra,
              transitionKey: state.pageKey,
              screen: const DownloadView(),
            );
          },
        ),
        GoRoute(
          path: RouteName.READ.subRouter,
          pageBuilder: (context, state) {
            final ReadingViewArgs extra = state.extra as ReadingViewArgs;
            return SharedAxisTransitionPageWrapper(
              transitionKey: state.pageKey,
              arguments: state.extra,
              screen: extra.capturedThemes.wrap(const ReadingView()),
            );
          },
        ),
        GoRoute(
          path: RouteName.PLAYER.subRouter,
          pageBuilder: (context, state) {
            // final PlayerArgs extra = state.extra as PlayerArgs;
            return SharedAxisTransitionPageWrapper(
              transitionKey: state.pageKey,
              arguments: state.extra,
              screen: const PlayerView(),
            );
          },
        ),
      ],
    ),
  ],
);
