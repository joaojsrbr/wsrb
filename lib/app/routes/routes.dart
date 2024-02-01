// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:app_wsrb_jsr/app/core/controllers/open_container_controller.dart';
import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/string_extensions.dart';
import 'package:app_wsrb_jsr/app/routes/open_container_transition_page_wrapper.dart';
import 'package:app_wsrb_jsr/app/routes/shared_axis_transition_page_wrapper.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/view/book_information_view.dart';
import 'package:app_wsrb_jsr/app/ui/home/page/home_page.dart';
import 'package:app_wsrb_jsr/app/ui/reading/view/reading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RouteName {
  RouteName._();
  static const HOME = '/';
  static const BOOKINFO = '/bookInfo';
  static const READ = '/read';
  // static const CONFIG = '/config';
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
          screen: HomePage(),
        );
      },
      routes: [
        GoRoute(
          path: RouteName.BOOKINFO.subRouter,
          pageBuilder: (context, state) {
            final openController = context.read<OpenContainerController>();
            if (state.extra is OpenContainerWidgetArgs &&
                openController.isActive &&
                !openController.isDisable) {
              final args = state.extra as OpenContainerWidgetArgs;

              return OpenContainerPage(
                screen: const BookInformationView(),
                args: args,
              );
            }
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
      ],
    ),
  ],
);
