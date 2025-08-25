// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:app_wsrb_jsr/app/routes/shared_axis_transition_page_wrapper.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/view/refactory_content_information.dart';
import 'package:app_wsrb_jsr/app/ui/download/view/download_view.dart';
import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/settings/view/settings_view.dart';
import 'package:app_wsrb_jsr/app/ui/webview/view/webview_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum RouteName {
  HOME("/"),
  CONTENTINFO("/content_info"),
  READ("/read"),
  PLAYER("/player"),
  DOWNLOAD("/download_view"),
  SETTINGS("/settings"),
  WEBVIEW("/webview");

  final String route;
  const RouteName(this.route);

  String get subRouter => route.replaceFirst('/', '');

  @override
  String toString() => route;

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
}

final appRoutes = GoRouter(
  // restorationScopeId: 'router',
  initialLocation: RouteName.HOME.route,

  routes: [
    GoRoute(
      path: RouteName.HOME.route,
      pageBuilder: (context, state) {
        return SharedAxisTransitionPageWrapper(
          // restorationId: 'router.home',
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
              screen: const RefContentInformationView(),
            );
          },
        ),
        GoRoute(
          path: RouteName.SETTINGS.subRouter,
          pageBuilder: (context, state) {
            return SharedAxisTransitionPageWrapper(
              arguments: state.extra,
              transitionKey: state.pageKey,
              screen: const SettingsView(),
            );
          },
        ),
        GoRoute(
          path: RouteName.DOWNLOAD.subRouter,
          pageBuilder: (context, state) {
            return SharedAxisTransitionPageWrapper(
              arguments: state.extra,
              // restorationId: 'router.download',
              transitionKey: state.pageKey,
              screen: const DownloadView(),
            );
          },
        ),
        // !descomentar se for usar
        // GoRoute(
        //   path: RouteName.READ.subRouter,
        //   pageBuilder: (context, state) {
        //     final ReadingViewArgs extra = state.extra as ReadingViewArgs;
        //     return SharedAxisTransitionPageWrapper(
        //       transitionKey: state.pageKey,
        //       arguments: state.extra,
        //       screen: extra.capturedThemes.wrap(const ReadingView()),
        //     );
        //   },
        // ),
        GoRoute(
          path: RouteName.PLAYER.subRouter,
          pageBuilder: (context, state) {
            return SharedAxisTransitionPageWrapper(
              transitionKey: state.pageKey,
              arguments: state.extra,
              screen: const PlayerView(),
            );
          },
        ),
        GoRoute(
          path: RouteName.WEBVIEW.subRouter,
          pageBuilder: (context, state) {
            return SharedAxisTransitionPageWrapper(
              transitionKey: state.pageKey,
              arguments: state.extra,
              screen: const WebViewPage(),
            );
          },
        ),
      ],
    ),
  ],
);
