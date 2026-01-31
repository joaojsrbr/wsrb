// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'routes.dart';

class OpenContainerController extends ChangeNotifier {
  bool _active = false;
  bool _disable = false;

  set activeOpenContainer(bool active) {
    if (_active == active) return;
    _active = active;
    notifyListeners();
  }

  set disableOpenContainer(bool disable) {
    if (_disable == disable) return;
    _disable = disable;
    notifyListeners();
  }

  bool get isActive => _active;
  bool get isDisable => _disable;
}

class OpenContainerWidgetArgs {
  final Object? arguments;

  final BuildContext widgetContext;
  const OpenContainerWidgetArgs({this.arguments, required this.widgetContext});
}

class OpenContainerWidgetWrapper<T> extends StatefulWidget {
  OpenContainerWidgetWrapper({
    super.key,
    required this.widgetBuilder,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    this.closedColor = Colors.white,
    this.openColor = Colors.white,
    this.middleColor,
    this.closedElevation = 1.0,
    this.openElevation = 4.0,
    this.onClosed,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionType = ContainerTransitionType.fade,
    this.useRootNavigator = false,
    this.arguments,
    this.clipBehavior = Clip.antiAlias,
  }) : closedShape = RoundedRectangleBorder(borderRadius: borderRadius),
       openShape = RoundedRectangleBorder(borderRadius: borderRadius);

  final Color openColor;
  final Color closedColor;
  final WidgetBuilder widgetBuilder;
  final double closedElevation;
  final Color? middleColor;
  final double openElevation;
  final ShapeBorder closedShape;
  final ShapeBorder openShape;
  final ClosedCallback<T?>? onClosed;
  final Duration transitionDuration;
  final ContainerTransitionType transitionType;
  final bool useRootNavigator;
  final Object? arguments;
  final Clip clipBehavior;

  @override
  State<OpenContainerWidgetWrapper<T>> createState() =>
      _OpenContainerWidgetWrapperState<T>();

  static Future<Object?> action(BuildContext context) async {
    final state = context
        .findAncestorStateOfType<_OpenContainerWidgetWrapperState<Object>>();
    final result = await state?.action();
    return result;
  }
}

class _OpenContainerWidgetWrapperState<T> extends State<OpenContainerWidgetWrapper<T>> {
  final GlobalKey _closedWidgetKey = GlobalKey();
  final GlobalKey<_HideableState> _hideableKey = GlobalKey<_HideableState>();

  Future<T?> action() async {
    if (_hideableKey.currentContext == null) return null;
    final openController = context.read<OpenContainerController>();
    openController.activeOpenContainer = true;
    final result = await context.push<T>(
      RouteName.CONTENTINFO.toString(),
      extra: OpenContainerWidgetArgs(
        arguments: widget.arguments,
        widgetContext: _hideableKey.currentContext!,
      ),
    );
    openController.activeOpenContainer = false;
    widget.onClosed?.call(result);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return _Hideable(
      key: _hideableKey,
      child: Material(
        clipBehavior: widget.clipBehavior,
        color: widget.closedColor,
        elevation: widget.closedElevation,
        shape: widget.closedShape,
        child: Builder(key: _closedWidgetKey, builder: widget.widgetBuilder),
      ),
    );
  }
}

class _Hideable extends StatefulWidget {
  const _Hideable({super.key, required this.child});

  final Widget child;

  @override
  State<_Hideable> createState() => _HideableState();
}

class _HideableState extends State<_Hideable> {
  /// Quando não é nulo, o filho é substituído por um [SizedBox] do tamanho definido.
  Size? get placeholderSize => _placeholderSize;
  Size? _placeholderSize;
  set placeholderSize(Size? value) {
    if (_placeholderSize == value) return;
    setState(() => _placeholderSize = value);
  }

  /// Quando verdadeiro o filho não fica visível, mas manterá seu tamanho.
  ///
  /// O valor desta propriedade é ignorado quando [placeholderSize] não é nulo
  /// (ou seja, [isInTree] retorna falso).
  bool get isVisible => _visible;
  bool _visible = true;
  set isVisible(bool value) {
    if (_visible == value) return;
    setState(() => _visible = value);
  }

  /// Se o filho está atualmente incluído na árvore.
  ///
  /// Quando incluído, pode estar visível ou não de acordo com [isVisible].
  bool get isInTree => _placeholderSize == null;

  @override
  Widget build(BuildContext context) {
    if (_placeholderSize != null) {
      return SizedBox.fromSize(size: _placeholderSize);
    }
    return Visibility(
      visible: _visible,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      child: widget.child,
    );
  }
}

class OpenContainerPage<T> extends Page<T> {
  const OpenContainerPage({required this.screen, required this.args});

  final OpenContainerWidgetArgs args;

  final Widget screen;

  @override
  Object? get arguments => args.arguments;

  @override
  Route<T> createRoute(BuildContext context) {
    final state = args.widgetContext
        .findAncestorStateOfType<_OpenContainerWidgetWrapperState<T>>()!;
    return _OpenContainerRoute(
      settings: this,
      hideableKey: state._hideableKey,
      closedElevation: state.widget.closedElevation,
      closedShape: state.widget.closedShape,
      closedWidget: state.widget.widgetBuilder(context),
      openWidget: screen,
    );
  }
}

class _OpenContainerRoute<T> extends ModalRoute<T> {
  _OpenContainerRoute({
    required double closedElevation,
    required ShapeBorder closedShape,
    required this.hideableKey,
    required this.closedWidget,
    required this.openWidget,
    required super.settings,
  }) {
    if (hideableKey.currentContext != null) {
      state = hideableKey.currentContext!
          .findAncestorStateOfType<_OpenContainerWidgetWrapperState<T>>()!;
      closedColor = state.widget.closedColor;
      middleColor =
          state.widget.middleColor ??
          Theme.of(state._hideableKey.currentContext!).canvasColor;
      openColor = state.widget.openColor;
      openElevation = state.widget.openElevation;
      openShape = state.widget.openShape;
      closedWidgetKey = state._closedWidgetKey;
      transitionDuration = state.widget.transitionDuration;
      transitionType = state.widget.transitionType;
      useRootNavigator = state.widget.useRootNavigator;
    }
    _elevationTween = Tween<double>(begin: closedElevation, end: openElevation);
    _shapeTween = ShapeBorderTween(begin: closedShape, end: openShape);
    _colorTween = _getColorTween(
      transitionType: transitionType,
      closedColor: closedColor,
      openColor: openColor,
      middleColor: middleColor,
    );
    _closedOpacityTween = _getClosedOpacityTween(transitionType);
    _openOpacityTween = _getOpenOpacityTween(transitionType);
  }

  static _FlippableTweenSequence<Color?> _getColorTween({
    required ContainerTransitionType transitionType,
    required Color closedColor,
    required Color openColor,
    required Color middleColor,
  }) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<Color?>(<TweenSequenceItem<Color?>>[
          TweenSequenceItem<Color>(
            tween: ConstantTween<Color>(closedColor),
            weight: 1 / 5,
          ),
          TweenSequenceItem<Color?>(
            tween: ColorTween(begin: closedColor, end: openColor),
            weight: 1 / 5,
          ),
          TweenSequenceItem<Color>(tween: ConstantTween<Color>(openColor), weight: 3 / 5),
        ]);
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<Color?>(<TweenSequenceItem<Color?>>[
          TweenSequenceItem<Color?>(
            tween: ColorTween(begin: closedColor, end: middleColor),
            weight: 1 / 5,
          ),
          TweenSequenceItem<Color?>(
            tween: ColorTween(begin: middleColor, end: openColor),
            weight: 4 / 5,
          ),
        ]);
    }
  }

  static _FlippableTweenSequence<double> _getClosedOpacityTween(
    ContainerTransitionType transitionType,
  ) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(tween: ConstantTween<double>(1.0), weight: 1),
        ]);
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: 0.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(tween: ConstantTween<double>(0.0), weight: 4 / 5),
        ]);
    }
  }

  static _FlippableTweenSequence<double> _getOpenOpacityTween(
    ContainerTransitionType transitionType,
  ) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(tween: ConstantTween<double>(0.0), weight: 1 / 5),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(tween: ConstantTween<double>(1.0), weight: 3 / 5),
        ]);
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(tween: ConstantTween<double>(0.0), weight: 1 / 5),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 4 / 5,
          ),
        ]);
    }
  }

  late final Color closedColor;
  late final Color openColor;
  late final Color middleColor;
  late final double openElevation;
  late final ShapeBorder openShape;
  late final Widget closedWidget;
  late final Widget openWidget;
  late final GlobalKey hideableKey;
  late final GlobalKey closedWidgetKey;
  late final _OpenContainerWidgetWrapperState<T> state;

  @override
  late final Duration transitionDuration;
  late final ContainerTransitionType transitionType;

  late final bool useRootNavigator;

  late final Tween<double> _elevationTween;
  late final ShapeBorderTween _shapeTween;
  late final _FlippableTweenSequence<double> _closedOpacityTween;
  late final _FlippableTweenSequence<double> _openOpacityTween;
  late final _FlippableTweenSequence<Color?> _colorTween;

  static final TweenSequence<Color?> _scrimFadeInTween =
      TweenSequence<Color?>(<TweenSequenceItem<Color?>>[
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: Colors.transparent, end: Colors.black54),
          weight: 1 / 5,
        ),
        TweenSequenceItem<Color>(
          tween: ConstantTween<Color>(Colors.black54),
          weight: 4 / 5,
        ),
      ]);
  static final Tween<Color?> _scrimFadeOutTween = ColorTween(
    begin: Colors.transparent,
    end: Colors.black54,
  );

  // Chave usada para o widget retornado por [OpenContainer.openBuilder] manter
  // seu estado quando a forma da árvore do widget é alterada no final do
  // animação para retirar todo o craft que foi necessário para fazer a animação
  // trabalhar.
  final GlobalKey _openWidgetKey = GlobalKey();

  // Define a posição e o tamanho do (abertura) [OpenContainer] dentro
  // os limites do [Navigator] envolvente.
  final RectTween _rectTween = RectTween();

  AnimationStatus? _lastAnimationStatus;
  AnimationStatus? _currentAnimationStatus;

  void _animationStatusListener(AnimationStatus status) {
    _lastAnimationStatus = _currentAnimationStatus;
    _currentAnimationStatus = status;
    switch (status) {
      case AnimationStatus.dismissed:
        _toggleHideable(hide: false);
        break;
      case AnimationStatus.completed:
        _toggleHideable(hide: true);
        break;
      default:
        break;
    }
  }

  @override
  TickerFuture didPush() {
    _takeMeasurements(navigatorContext: hideableKey.currentContext!);

    animation?.addStatusListener(_animationStatusListener);

    return super.didPush();
  }

  @override
  bool didPop(T? result) {
    _takeMeasurements(navigatorContext: subtreeContext!, delayForSourceRoute: true);
    return super.didPop(result);
  }

  @override
  void dispose() {
    if (state._hideableKey.currentState?.isVisible == false) {
      // Esta rota pode ser descartada sem descartar sua animação se for
      // removido pelo navegador.
      SchedulerBinding.instance.addPostFrameCallback(
        (Duration d) => _toggleHideable(hide: false),
      );
    }
    super.dispose();
  }

  void _toggleHideable({required bool hide}) {
    if (hideableKey.currentState != null) {
      state._hideableKey.currentState!
        ..placeholderSize = null
        ..isVisible = !hide;
    }
  }

  void _takeMeasurements({
    required BuildContext navigatorContext,
    bool delayForSourceRoute = false,
  }) {
    final RenderBox navigator =
        Navigator.of(
              navigatorContext,
              rootNavigator: useRootNavigator,
            ).context.findRenderObject()!
            as RenderBox;
    final Size navSize = _getSize(navigator);
    _rectTween.end = Offset.zero & navSize;

    void takeMeasurementsInSourceRoute([Duration? _]) {
      if (!navigator.attached || hideableKey.currentContext == null) {
        return;
      }
      _rectTween.begin = _getRect(hideableKey, navigator);
      state._hideableKey.currentState?.placeholderSize = _rectTween.begin!.size;
    }

    if (delayForSourceRoute) {
      SchedulerBinding.instance.addPostFrameCallback(takeMeasurementsInSourceRoute);
    } else {
      takeMeasurementsInSourceRoute();
    }
  }

  Size _getSize(RenderBox render) {
    assert(render.hasSize);
    return render.size;
  }

  // Retorna os limites do [RenderObject] identificado por `key` no
  // sistema de coordenadas do `ancestral`.
  Rect _getRect(GlobalKey key, RenderBox ancestor) {
    assert(key.currentContext != null);
    assert(ancestor.hasSize);
    final RenderBox render = key.currentContext!.findRenderObject()! as RenderBox;
    assert(render.hasSize);
    return MatrixUtils.transformRect(
      render.getTransformTo(ancestor),
      Offset.zero & render.size,
    );
  }

  bool get _transitionWasInterrupted {
    bool wasInProgress = false;
    bool isInProgress = false;

    switch (_currentAnimationStatus) {
      case AnimationStatus.dismissed:
        isInProgress = false;
        break;
      case AnimationStatus.reverse:
        isInProgress = true;
        break;
      default:
        break;
    }
    switch (_lastAnimationStatus) {
      case AnimationStatus.dismissed:
        wasInProgress = false;
        break;
      case AnimationStatus.reverse:
        wasInProgress = true;
        break;
      default:
        break;
    }
    return wasInProgress && isInProgress;
  }

  void closeContainer({T? returnValue}) {
    Navigator.of(subtreeContext!).pop(returnValue);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          if (animation.isCompleted) {
            return SizedBox.expand(
              child: Material(
                color: openColor,
                elevation: openElevation,
                shape: openShape,
                child: Builder(
                  key: _openWidgetKey,
                  builder: (BuildContext context) => openWidget,
                ),
              ),
            );
          }

          final Animation<double> curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
            reverseCurve: _transitionWasInterrupted ? null : Curves.fastOutSlowIn.flipped,
          );
          TweenSequence<Color?>? colorTween;
          TweenSequence<double>? closedOpacityTween, openOpacityTween;
          Animatable<Color?>? scrimTween;
          switch (animation.status) {
            case AnimationStatus.forward:
              closedOpacityTween = _closedOpacityTween;
              openOpacityTween = _openOpacityTween;
              colorTween = _colorTween;
              scrimTween = _scrimFadeInTween;
              break;
            case AnimationStatus.reverse:
              if (_transitionWasInterrupted) {
                closedOpacityTween = _closedOpacityTween;
                openOpacityTween = _openOpacityTween;
                colorTween = _colorTween;
                scrimTween = _scrimFadeInTween;
                break;
              }
              closedOpacityTween = _closedOpacityTween.flipped;
              openOpacityTween = _openOpacityTween.flipped;
              colorTween = _colorTween.flipped;
              scrimTween = _scrimFadeOutTween;
              break;
            case AnimationStatus.completed:
              assert(false); // Unreachable.
              break;
            default:
              break;
          }
          assert(colorTween != null);
          assert(closedOpacityTween != null);
          assert(openOpacityTween != null);
          assert(scrimTween != null);

          final Rect rect = _rectTween.evaluate(curvedAnimation)!;
          return SizedBox.expand(
            child: Container(
              color: scrimTween!.evaluate(curvedAnimation),
              child: Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: Offset(rect.left, rect.top),
                  child: SizedBox(
                    width: rect.width,
                    height: rect.height,
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      animationDuration: Duration.zero,
                      color: colorTween!.evaluate(animation),
                      shape: _shapeTween.evaluate(curvedAnimation),
                      elevation: _elevationTween.evaluate(curvedAnimation),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: <Widget>[
                          // Closed child fading out.
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: _rectTween.begin!.width,
                              height: _rectTween.begin!.height,
                              child: (state._hideableKey.currentState?.isInTree ?? false)
                                  ? null
                                  : FadeTransition(
                                      opacity: closedOpacityTween!.animate(animation),
                                      child: Builder(
                                        key: closedWidgetKey,
                                        builder: (BuildContext context) => closedWidget,
                                      ),
                                    ),
                            ),
                          ),

                          // Open child fading in.
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: _rectTween.end!.width,
                              height: _rectTween.end!.height,
                              child: FadeTransition(
                                opacity: openOpacityTween!.animate(animation),
                                child: Builder(
                                  key: _openWidgetKey,
                                  builder: (BuildContext context) => openWidget,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;
}

class _FlippableTweenSequence<T> extends TweenSequence<T> {
  _FlippableTweenSequence(this._items) : super(_items);

  final List<TweenSequenceItem<T>> _items;
  _FlippableTweenSequence<T>? _flipped;

  _FlippableTweenSequence<T>? get flipped {
    if (_flipped == null) {
      final List<TweenSequenceItem<T>> newItems = <TweenSequenceItem<T>>[];
      for (int i = 0; i < _items.length; i++) {
        newItems.add(
          TweenSequenceItem<T>(
            tween: _items[i].tween,
            weight: _items[_items.length - 1 - i].weight,
          ),
        );
      }
      _flipped = _FlippableTweenSequence<T>(newItems);
    }
    return _flipped;
  }
}
