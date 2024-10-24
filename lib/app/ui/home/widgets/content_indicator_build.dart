import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
import 'package:app_wsrb_jsr/app/utils/app_snack_bar.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:provider/provider.dart';

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
      widget = const FullScreenErrorWidget();
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

class FullScreenErrorWidget extends StatefulWidget {
  const FullScreenErrorWidget({
    super.key,
    this.btnAtualizar = true,
  });

  final bool btnAtualizar;

  @override
  State<FullScreenErrorWidget> createState() => FullScreenErrorWidgetState();
}

class FullScreenErrorWidgetState extends State<FullScreenErrorWidget> {
  late final ContentRepository _contentRepository;
  late final ConnectionChecker _connectionChecker;
  final Debouncer _debouncer = Debouncer();
  final Debouncer _connectionDebouncer =
      Debouncer(duration: const Duration(milliseconds: 200));

  @override
  void initState() {
    _contentRepository = context.read<ContentRepository>();
    _connectionChecker = context.read<ConnectionChecker>();
    _contentRepository.clear();
    if (_contentRepository.indicatorStatus ==
        IndicatorStatus.fullScreenBusying) {
      scheduleMicrotask(_showSnackBar);
    }

    super.initState();
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
  void didChangeDependencies() {
    // _connectionDebouncer.call(() {
    //   if (_connectionChecker.connectivityResult.isNotEmpty &&
    //       _contentRepository.indicatorStatus !=
    //           IndicatorStatus.fullScreenBusying) {
    //     final refreshIndicatorState =
    //         context.findAncestorWidgetOfExactType<RefreshIndicator>();

    //     if (refreshIndicatorState != null) {
    //       Timer(
    //         const Duration(milliseconds: 400),
    //         refreshIndicatorState.onRefresh,
    //       );
    //     }
    //   }
    // });
    super.didChangeDependencies();
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
          _ => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                "Parece que você está offline. Verifique sua conexão com a internet e tente novamente.",
                textAlign: TextAlign.center,
              ),
            )
        },
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.btnAtualizar)
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
            if (!connectionChecker.hasConnection ||
                connectionChecker.connectivityResult.isEmpty) ...[
              if (widget.btnAtualizar) const SizedBox(width: 8),
              FilledButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  switch (OpenSettingsPlus.shared) {
                    case OpenSettingsPlusAndroid settings:
                      await settings.wifi();

                      break;
                    case OpenSettingsPlusIOS settings:
                      await settings.wifi();
                      break;
                  }

                  Timer(const Duration(seconds: 1),
                      () => _contentRepository.refresh(true));
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
