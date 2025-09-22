// ignore_for_file: constant_identifier_names

import 'package:app_wsrb_jsr/app/routes/shared_axis_transition_page_wrapper.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/view/refactory_content_information.dart';
import 'package:app_wsrb_jsr/app/ui/download/view/download_view.dart';
import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/settings/view/settings_view.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/global_overlay.dart';
import 'package:app_wsrb_jsr/app/ui/webview/view/webview_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'generated/routes.g.dart';

final appRouter = GoRouter(
  routes: $appRoutes,
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteName.HOME.route,
  observers: [_CloseNotificationObserver()],
);

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final class _CloseNotificationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted && context.hasNotification()) {
      context.closeNotification();
    }
    super.didPush(route, previousRoute);
  }

  // @override // void didPop(Route route, Route? previousRoute) {
  // final context = rootNavigatorKey.currentContext; // if (context != null && context.mounted && context.hasNotification())
  //{
  // context.closeNotification(); // }
  // super.didPop(route, previousRoute);
  //} }
}

/// ============================
/// ROTAS TIPADAS
/// ============================

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<ContentInfoRoute>(
      path: 'content_info',
      routes: [TypedGoRoute<PlayerRoute>(path: 'player')],
    ),
    TypedGoRoute<SettingsRoute>(path: 'settings'),
    TypedGoRoute<DownloadRoute>(path: 'download_view'),
    TypedGoRoute<WebviewRoute>(path: 'webview'),
  ],
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SharedAxisTransitionPageWrapper(
        transitionKey: state.pageKey,
        arguments: state.extra,
        screen: const HomeView(),
      );
}

class ContentInfoRoute extends GoRouteData {
  const ContentInfoRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SharedAxisTransitionPageWrapper(
        transitionKey: state.pageKey,
        arguments: state.extra,
        screen: const RefContentInformationView(),
      );
}

class PlayerRoute extends GoRouteData {
  const PlayerRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SharedAxisTransitionPageWrapper(
        transitionKey: state.pageKey,
        arguments: state.extra,
        screen: const PlayerView(),
      );
}

class SettingsRoute extends GoRouteData {
  const SettingsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SharedAxisTransitionPageWrapper(
        transitionKey: state.pageKey,
        arguments: state.extra,
        screen: const SettingsView(),
      );
}

class DownloadRoute extends GoRouteData {
  const DownloadRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SharedAxisTransitionPageWrapper(
        transitionKey: state.pageKey,
        arguments: state.extra,
        screen: const DownloadView(),
      );
}

class WebviewRoute extends GoRouteData {
  const WebviewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SharedAxisTransitionPageWrapper(
        transitionKey: state.pageKey,
        arguments: state.extra,
        screen: const WebViewPage(),
      );
}

/// ============================
/// ENUM DE ROTAS
/// ============================

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

  Set<String> get _pathSegments {
    final home = RouteName.HOME;
    final info = RouteName.CONTENTINFO;
    return switch (this) {
      RouteName.HOME => {home.subRouter},
      RouteName.READ => {home.subRouter, subRouter},
      RouteName.PLAYER => {home.subRouter, info.subRouter, subRouter},
      RouteName.DOWNLOAD => {home.subRouter, subRouter},
      RouteName.SETTINGS => {home.subRouter, subRouter},
      RouteName.WEBVIEW => {home.subRouter, subRouter},
      RouteName.CONTENTINFO => {home.subRouter, subRouter},
    };
  }
}

/// ============================
/// EXTENSIONS DE NAVEGAÇÃO
/// ============================

extension GoRouterEnumNavigation on BuildContext {
  void goEnum(
    RouteName route, {
    Object? extra,
    Map<String, String> params = const {},
    Map<String, dynamic> queryParams = const {},
  }) {
    final uri = Uri(
      pathSegments: route._pathSegments,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    go(uri.toString(), extra: extra);
  }

  Future<T?> pushEnum<T>(
    RouteName route, {
    Object? extra,
    Map<String, String> params = const {},
    Map<String, dynamic> queryParams = const {},
  }) {
    final uri = Uri(
      pathSegments: route._pathSegments,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    // Navigator.of(this).pushNamed();
    // customLog(uri.toString());

    return push<T>(uri.toString(), extra: extra);
  }

  void replaceEnum(
    RouteName route, {
    Object? extra,
    Map<String, String> params = const {},
    Map<String, dynamic> queryParams = const {},
  }) {
    final uri = Uri(
      pathSegments: route._pathSegments,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    replace(uri.toString(), extra: extra);
  }

  Future<T?> pushReplacementEnum<T>(
    RouteName route, {
    Object? extra,
    Map<String, String> params = const {},
    Map<String, dynamic> queryParams = const {},
  }) {
    final uri = Uri(
      pathSegments: route._pathSegments,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final go = GoRouter.of(this);
    return go.pushReplacement(uri.toString(), extra: extra);
  }
}
