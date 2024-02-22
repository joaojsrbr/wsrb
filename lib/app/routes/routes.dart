// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/string_extensions.dart';
import 'package:app_wsrb_jsr/app/routes/shared_axis_transition_page_wrapper.dart';
import 'package:app_wsrb_jsr/app/ui/content_information/view/content_information_view.dart';
import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/reading/view/reading_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteName {
  const RouteName._();
  static const StringRouter HOME = StringRouter('/');
  static const StringRouter CONTENTINFO = StringRouter('/contentInfo');
  static const StringRouter READ = StringRouter('/read');
  static const StringRouter PLAYER = StringRouter('/player');
  // static const WEBVIEW = '/web_view';
  // static const CATEGORY = '/category';
  // static const TEST = '/test';
}

final appRoutes = GoRouter(
  initialLocation: RouteName.HOME,
  routes: [
    GoRoute(
      path: RouteName.HOME,
      pageBuilder: (context, state) {
        return const SharedAxisTransitionPageWrapper(
          transitionKey: ValueKey('home_page'),
          screen: HomeView(),
        );
      },
      routes: [
        GoRoute(
          path: RouteName.CONTENTINFO.subRouter,
          pageBuilder: (context, state) {
            // final openController = context.read<OpenContainerController>();
            // if (state.extra is OpenContainerWidgetArgs &&
            //     openController.isActive &&
            //     !openController.isDisable) {
            //   final args = state.extra as OpenContainerWidgetArgs;

            //   return OpenContainerPage(
            //     screen: const BookInformationView(),
            //     args: args,
            //   );
            // }

            return SharedAxisTransitionPageWrapper(
              arguments: state.extra,
              transitionKey: const ValueKey('book_information_view'),
              screen: const BookInformationView(),
            );
          },
        ),
        GoRoute(
          path: RouteName.READ.subRouter,
          pageBuilder: (context, state) {
            return SharedAxisTransitionPageWrapper(
              transitionKey: const ValueKey('read_page'),
              arguments: state.extra,
              screen: const ReadingView(),
            );
          },
        ),
        GoRoute(
          path: RouteName.PLAYER.subRouter,
          pageBuilder: (context, state) {
            return SharedAxisTransitionPageWrapper(
              transitionKey: const ValueKey('player_page'),
              arguments: state.extra,
              screen: const PlayerView(),
            );
          },
        ),
      ],
    ),
  ],
);
