import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:app_wsrb_jsr/app/ui/home/view/home_view.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:content_library/content_library.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:open_settings_plus/open_settings_plus.dart';

final Debouncer _debouncer = Debouncer();

Widget contentIndicatorBuilder(BuildContext context, IndicatorStatus status) {
  Widget widget;

  switch (status) {
    case IndicatorStatus.none:
      widget = const _NoneWidget();
      break;
    case IndicatorStatus.loadingMoreBusying:
      widget = const _LoadingMoreBusyingWidget();
      break;
    case IndicatorStatus.fullScreenBusying:
      widget = const _FullScreenBusyingWidget();
      final tabController = HomeScope.maybeOf(context)?.tabController;
      if (tabController != null && tabController.index != 0) {
        widget = const SizedBox.shrink();
        break;
      }

      final refreshIndicatorState =
          context.findAncestorStateOfType<RefreshIndicatorState>();
      if (refreshIndicatorState != null) {
        refreshIndicatorState.show();
        widget = const SizedBox.shrink();
      }

      break;
    case IndicatorStatus.error:
      widget = const _ErrorWidget();
      break;
    case IndicatorStatus.fullScreenError:
      widget = const _FullScreenErrorWidget();
      break;
    case IndicatorStatus.noMoreLoad:
      widget = const _NoMoreLoadWidget();
      break;
    case IndicatorStatus.empty:
      widget = const _EmptyWidget();
      break;
    default:
      widget = const _DefaultWidget();
      break;
  }
  return _StatusNotifier(
    status: status,
    child: Builder(builder: (context) {
      // final ConnectionChecker connectionChecker =
      //     context.watch<ConnectionChecker>();
      // if (!connectionChecker.hasConnection) {
      //   return const _FullScreenErrorWidget();
      // }
      return widget;
    }),
  );
}

class _StatusNotifier extends InheritedWidget {
  final IndicatorStatus status;
  const _StatusNotifier({required super.child, required this.status});

  static _StatusNotifier? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_StatusNotifier>();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(EnumProperty<IndicatorStatus>('IndicatorStatus', status,
        defaultValue: IndicatorStatus.none));
  }

  // ignore: unused_element
  static _StatusNotifier of(BuildContext context) {
    final _StatusNotifier? result = maybeOf(context);
    assert(result != null, 'No _StatusNotifier found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_StatusNotifier oldWidget) =>
      status != oldWidget.status;
}

class _DefaultWidget extends StatelessWidget {
  const _DefaultWidget();
  @override
  Widget build(BuildContext context) {
    final isSliver =
        context.findAncestorWidgetOfExactType<CustomScrollView>() != null;
    Widget widget = const SizedBox.shrink();
    if (isSliver) widget = SliverToBoxAdapter(child: widget);
    return widget;
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver =
        context.findAncestorWidgetOfExactType<CustomScrollView>() != null;

    Widget child = const SizedBox.shrink();
    if (isSliver) child = SliverToBoxAdapter(child: child);
    return child;
  }
}

class _NoMoreLoadWidget extends StatelessWidget {
  const _NoMoreLoadWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver =
        context.findAncestorWidgetOfExactType<CustomScrollView>() != null;
    final size = MediaQuery.sizeOf(context);
    Widget child = SizedBox(
      height: size.height * .06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(MdiIcons.alertCircleOutline),
          ),
          Text('Última página', style: Theme.of(context).textTheme.titleMedium)
        ],
      ),
    );
    if (isSliver) child = SliverToBoxAdapter(child: child);
    return child;
  }
}

class _FullScreenErrorWidget extends StatefulWidget {
  const _FullScreenErrorWidget();

  @override
  State<_FullScreenErrorWidget> createState() => _FullScreenErrorWidgetState();
}

class _FullScreenErrorWidgetState extends State<_FullScreenErrorWidget> {
  late final ContentRepository _contentRepository;

  @override
  void initState() {
    _contentRepository = context.read<ContentRepository>();
    scheduleMicrotask(_showSnackBar);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final ConnectionChecker connectionChecker =
        context.watch<ConnectionChecker>();

    if (!connectionChecker.hasConnection) {
      // scheduleMicrotask(() => _contentRepository.refresh(true));
      scheduleMicrotask(_showSnackBar);
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant _FullScreenErrorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _showSnackBar([BuildContext? context]) async {
    _debouncer.cancel();
    _debouncer.call(() {
      // _contentRepository.refresh(true);
      final fullScreenError = _contentRepository.fullScreenError;
      setStateIfMounted(() {});
      if (fullScreenError is DioException) {
        final AppSnackBar appSnackBar = AppSnackBar(context ?? this.context);
        appSnackBar.show(
          const Text(
            'Verifique sua conexão com a internet.',
          ),
          flushbarPosition: FlushbarPosition.TOP,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ConnectionChecker connectionChecker =
        context.watch<ConnectionChecker>();
    final isSliver =
        context.findAncestorWidgetOfExactType<CustomScrollView>() != null;

    Widget child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        switch (_contentRepository.fullScreenError) {
          AnrollGetIdException data => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data.message,
                textAlign: TextAlign.center,
              ),
            ),
          GoyabuLoadDataException data => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data.message,
                textAlign: TextAlign.center,
              ),
            ),
          DioException data => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data.message ?? '',
                textAlign: TextAlign.center,
              ),
            ),
          _ => const SizedBox.shrink()
        },
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _contentRepository.refresh(true);
              },
              child: const Text('Atualizar'),
            ),
            if (!connectionChecker.hasConnection) ...[
              const SizedBox(width: 8),
              FilledButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  switch (OpenSettingsPlus.shared) {
                    case OpenSettingsPlusAndroid settings:
                      // await settings.wifi();

                      settings.sendCustomMessage('message');
                      break;
                    case OpenSettingsPlusIOS settings:
                      await settings.wifi();
                      break;
                  }

                  await _contentRepository.refresh(true);
                },
                child: const Text('configurações de wi-fi'),
              ),
            ],
          ],
        ),
      ],
    );

    if (isSliver) child = SliverFillRemaining(child: child);
    return child;
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver =
        context.findAncestorWidgetOfExactType<CustomScrollView>() != null;
    final size = MediaQuery.sizeOf(context);
    Widget child = SizedBox(
      height: size.height * .06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(MdiIcons.alertCircleOutline),
          ),
          Text('Última página', style: Theme.of(context).textTheme.titleMedium)
        ],
      ),
    );
    if (isSliver) child = SliverToBoxAdapter(child: child);
    return child;
  }
}

class _NoneWidget extends StatelessWidget {
  const _NoneWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver =
        context.findAncestorWidgetOfExactType<CustomScrollView>() != null;

    Widget child = const SizedBox.shrink();
    if (isSliver) child = SliverToBoxAdapter(child: child);
    return child;
  }
}

class _LoadingMoreBusyingWidget extends StatelessWidget {
  const _LoadingMoreBusyingWidget();

  @override
  Widget build(BuildContext context) {
    // if (isSliver) child = SliverToBoxAdapter(child: child);
    return const _BuildCircularWidget();
  }
}

class _FullScreenBusyingWidget extends StatelessWidget {
  const _FullScreenBusyingWidget();

  @override
  Widget build(BuildContext context) {
    final isSliver =
        context.findAncestorWidgetOfExactType<CustomScrollView>() != null;

    Widget child = const _BuildCircularWidget();
    if (isSliver) child = SliverFillRemaining(child: child);
    return Center(child: child);
  }
}

class _BuildCircularWidget extends StatelessWidget {
  const _BuildCircularWidget();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox(
      height: size.height * .15,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LoadingAnimationWidget.staggeredDotsWave(
          //   color: Theme.of(context).colorScheme.primary,
          //   size: height / 2,
          // ),
          CircularProgressIndicator.adaptive(),
        ],
      ),
    );
  }
}
