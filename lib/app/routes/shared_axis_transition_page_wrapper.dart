import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Um wrapper de página que aplica uma transição SharedAxis.
///
/// Utiliza [PageRouteBuilder] para criar uma rota personalizada com animações
/// de transição SharedAxis. É recomendado usar [screenBuilder] para construir
/// o widget da tela de forma lazy, melhorando a performance.
class SharedAxisTransitionPageWrapper<T> extends Page<T> {
  const SharedAxisTransitionPageWrapper({
    this.screen,
    this.screenBuilder,
    this.transitionDuration,
    this.reverseTransitionDuration,
    required ValueKey<dynamic> transitionKey,
    super.restorationId,
    super.arguments,
  }) : super(key: transitionKey);

  /// A duração padrão para a transição de entrada.
  static const Duration _defaultTransitionDuration = Duration(milliseconds: 700);

  /// A duração padrão para a transição de saída (reversa).
  static const Duration _defaultReverseTransitionDuration = Duration(milliseconds: 700);

  /// O widget da tela a ser exibido. Use [screenBuilder] para melhor performance.
  final Widget? screen;

  /// Um construtor para o widget da tela, preferível para construção lazy.
  final WidgetBuilder? screenBuilder;

  /// Duração personalizada para a transição de entrada.
  final Duration? transitionDuration;

  /// Duração personalizada para a transição de saída (reversa).
  final Duration? reverseTransitionDuration;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      fullscreenDialog: true,
      transitionDuration: transitionDuration ?? _defaultTransitionDuration,
      reverseTransitionDuration:
          reverseTransitionDuration ?? _defaultReverseTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // final curvedAnimation = CurvedAnimation(
        //   parent: animation,
        //   curve: Curves.fastOutSlowIn,
        //   reverseCurve: Curves.easeOutQuad,
        // );
        // final curvedSecondary = CurvedAnimation(
        //   parent: secondaryAnimation,
        //   curve: Curves.fastOutSlowIn,
        //   reverseCurve: Curves.easeInQuad,
        // );

        return SharedAxisTransition(
          fillColor: Theme.of(context).canvasColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) =>
          screenBuilder?.call(context) ?? screen ?? const SizedBox.shrink(),
    );
  }
}
