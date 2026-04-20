// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $homeRoute,
    ];

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      factory: $HomeRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'content_info',
          factory: $ContentInfoRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'player',
              factory: $PlayerRouteExtension._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'settings',
          factory: $SettingsRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'download_view',
          factory: $DownloadRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'webview',
          factory: $WebviewRouteExtension._fromState,
        ),
      ],
    );

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ContentInfoRouteExtension on ContentInfoRoute {
  static ContentInfoRoute _fromState(GoRouterState state) =>
      const ContentInfoRoute();

  String get location => GoRouteData.$location(
        '/content_info',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PlayerRouteExtension on PlayerRoute {
  static PlayerRoute _fromState(GoRouterState state) => const PlayerRoute();

  String get location => GoRouteData.$location(
        '/content_info/player',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SettingsRouteExtension on SettingsRoute {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  String get location => GoRouteData.$location(
        '/settings',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $DownloadRouteExtension on DownloadRoute {
  static DownloadRoute _fromState(GoRouterState state) => const DownloadRoute();

  String get location => GoRouteData.$location(
        '/download_view',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $WebviewRouteExtension on WebviewRoute {
  static WebviewRoute _fromState(GoRouterState state) => const WebviewRoute();

  String get location => GoRouteData.$location(
        '/webview',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
