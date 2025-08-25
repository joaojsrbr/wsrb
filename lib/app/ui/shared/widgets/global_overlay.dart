// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_element
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// App Notification Overlay
/// - Mantém comportamento original para top/bottom
/// - Usa OverlayEntry apenas para NotificationPosition.floating
/// - Compatível com Material 3 (usa ColorScheme tokens quando possível)
/// - Features adicionadas: actions, tag (evita duplicatas), fila/stack para floating,
///   prioridade com preemption, sticky/persistent notifications, callbacks (onShown/onDismissed/onTap),
///   NotificationType para cores automáticas, haptics, acessibilidade.

enum NotificationPosition { top, bottom, floating }

enum NotificationType { neutral, info, success, warning, error }

class AppNotificationConfig {
  final int maxFloatingStack; // quantas flutuantes simultâneas
  final double floatingCornerRadius;
  final double floatingMaxWidthFactor; // % da largura da tela
  final bool enableHaptics;
  final double floatingSpacing; // deslocamento Y entre flutuantes empilhadas

  const AppNotificationConfig({
    this.maxFloatingStack = 3,
    this.floatingCornerRadius = 12.0,
    this.floatingMaxWidthFactor = 0.9,
    this.enableHaptics = true,
    this.floatingSpacing = 12.0,
  });
}

typedef NotificationCallback = void Function();

class AppNotificationOverlay extends StatefulWidget {
  final Widget child;
  final AppNotificationConfig config;

  const AppNotificationOverlay({
    super.key,
    required this.child,
    this.config = const AppNotificationConfig(),
  });

  @override
  State<AppNotificationOverlay> createState() => AppNotificationOverlayState();
}

class AppNotificationOverlayState extends State<AppNotificationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _sharedController;
  late final Animation<double> _sharedFade;
  late final Animation<double> _sharedSize;
  late final Animation<double> _padding;

  late final AnimationController _progressController;

  Widget? _overlayContent; // usado para top/bottom
  NotificationPosition? _currentPosition;
  ValueNotifier<double>? _progressNotifier;

  double? _height;
  bool _showCountdown = false;
  bool _mediaQuery = true;
  bool _isOverlay = false; // mantém comportamento atual para top/bottom overlay
  Color? _backgroundColor;
  TextStyle? _textStyle;
  Alignment _alignment = Alignment.center;
  Timer? _closeTimer;

  final List<_ActiveFloating> _activeFloatings = [];
  final List<_PendingFloating> _floatingQueue = [];

  String? _currentTag; // evita duplicatas por tag

  @override
  void initState() {
    super.initState();
    _sharedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _sharedFade = CurvedAnimation(
      parent: _sharedController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _padding = CurvedAnimation(
      parent: _sharedController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    )..addStatusListener(_paddingStatusListener);
    _sharedSize = CurvedAnimation(parent: _sharedController, curve: Curves.easeOutCubic);
    _progressController = AnimationController(vsync: this);
  }

  void _paddingStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _currentTag != null) setState(() => _mediaQuery = true);
        });
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
      case AnimationStatus.completed:
        break;
    }
  }

  /// Top / bottom public API — agora aceitam `actions` e `tag`.
  void showTop({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    bool overlay = false,
    bool showCountdown = true,
    ValueNotifier<double>? progressNotifier,
    Color? backgroundColor,
    double height = 90.0,
    TextStyle? textStyle,
    Alignment alignment = Alignment.centerLeft,
    List<Widget>? actions,
    String? tag,
    int priority = 0,
    bool persistent = false,
    NotificationType type = NotificationType.neutral,
    NotificationCallback? onShown,
    NotificationCallback? onDismissed,
    NotificationCallback? onTap,
  }) {
    _show(
      child: child,
      position: NotificationPosition.top,
      overlay: overlay,
      duration: duration,
      showCountdown: showCountdown,
      progressNotifier: progressNotifier,
      backgroundColor: backgroundColor,
      height: height,
      textStyle: textStyle,
      alignment: alignment,
      actions: actions,
      tag: tag,
      priority: priority,
      persistent: persistent,
      type: type,
      onShown: onShown,
      onDismissed: onDismissed,
      onTap: onTap,
    );
  }

  void showBottom({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    bool overlay = false,
    bool showCountdown = true,
    ValueNotifier<double>? progressNotifier,
    Color? backgroundColor,
    double height = 60.0,
    TextStyle? textStyle,
    Alignment alignment = Alignment.center,
    List<Widget>? actions,
    String? tag,
    int priority = 0,
    bool persistent = false,
    NotificationType type = NotificationType.neutral,
    NotificationCallback? onShown,
    NotificationCallback? onDismissed,
    NotificationCallback? onTap,
  }) {
    _show(
      child: child,
      position: NotificationPosition.bottom,
      overlay: overlay,
      duration: duration,
      showCountdown: showCountdown,
      progressNotifier: progressNotifier,
      backgroundColor: backgroundColor,
      height: height,
      textStyle: textStyle,
      alignment: alignment,
      actions: actions,
      tag: tag,
      priority: priority,
      persistent: persistent,
      type: type,
      onShown: onShown,
      onDismissed: onDismissed,
      onTap: onTap,
    );
  }

  /// Show floating (public). Accepts priority/persistent etc.
  void showFloating({
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    ValueNotifier<double>? progressNotifier,
    Color? backgroundColor,
    TextStyle? textStyle,
    Alignment alignment = Alignment.center,
    double? height,
    List<Widget>? actions,
    String? tag,
    int priority = 0,
    bool persistent = false,
    NotificationType type = NotificationType.neutral,
    NotificationCallback? onShown,
    NotificationCallback? onDismissed,
    NotificationCallback? onTap,
  }) {
    _show(
      child: child,
      position: NotificationPosition.floating,
      overlay: true,
      duration: duration,
      showCountdown: true,
      progressNotifier: progressNotifier,
      backgroundColor: backgroundColor,
      height: height,
      textStyle: textStyle,
      alignment: alignment,
      actions: actions,
      tag: tag,
      priority: priority,
      persistent: persistent,
      type: type,
      onShown: onShown,
      onDismissed: onDismissed,
      onTap: onTap,
    );
  }

  /// Mantém a notificação ativa (reinicia timer ou mostra progresso passado)
  void maintainOverlap({
    Duration duration = const Duration(seconds: 4),
    ValueNotifier<double>? progressNotifier,
  }) {
    _closeTimer?.cancel();
    _progressController.stop();
    setState(() {
      _progressNotifier = progressNotifier;
    });
    if (progressNotifier == null && mounted) {
      _closeTimer = Timer(duration, closeAnimated);
      if (_showCountdown) {
        _progressController.duration = duration;
        _progressController.forward(from: 0);
      }
    }
  }

  void _show({
    required Widget child,
    required NotificationPosition position,
    required Duration duration,
    required bool overlay,
    required bool showCountdown,
    ValueNotifier<double>? progressNotifier,
    Color? backgroundColor,
    double? height,
    TextStyle? textStyle,
    Alignment? alignment,
    List<Widget>? actions,
    String? tag,
    int priority = 0,
    bool persistent = false,
    NotificationType type = NotificationType.neutral,
    NotificationCallback? onShown,
    NotificationCallback? onDismissed,
    NotificationCallback? onTap,
  }) {
    // evita duplicatas por tag
    if (tag != null && tag == _currentTag) return;

    // Se position for floating, usamos OverlayEntry (novo comportamento)
    if (position == NotificationPosition.floating) {
      setState(() {
        _isOverlay = overlay;
        _mediaQuery = false;
      });

      final pending = _PendingFloating(
        child: child,
        duration: duration,
        progressNotifier: progressNotifier,
        backgroundColor: backgroundColor,
        textStyle: textStyle,
        alignment: alignment ?? Alignment.center,
        height: height,
        actions: actions,
        tag: tag,
        priority: priority,
        persistent: persistent,
        type: type,
        onShown: onShown,
        onDismissed: onDismissed,
        onTap: onTap,
      );

      // Preemption: se fila cheia e incoming tem prioridade maior que algum ativo
      if (_activeFloatings.length >= widget.config.maxFloatingStack) {
        // encontra o ativo de menor prioridade
        _activeFloatings.sort((a, b) => a.pending.priority.compareTo(b.pending.priority));
        final lowest = _activeFloatings.first;
        if (pending.priority > lowest.pending.priority) {
          // remove lowest e mostra pending
          _removeActiveFloating(lowest);
          _insertActiveFloating(pending);
          return;
        }

        // se não preemptou, tenta enfileirar
        if (_floatingQueue.length < 64) {
          _floatingQueue.add(pending);
        }
        return;
      }

      // Ainda temos espaço para mostrar imediatamente
      _insertActiveFloating(pending);
      return;
    }

    // comport. existente para top/bottom (mantive e acrescentei actions)
    _closeTimer?.cancel();
    _progressController.stop();
    setState(() {
      _mediaQuery = false;
      _overlayContent = child;
      _currentPosition = position;
      _isOverlay = overlay;
      _height = height;
      _backgroundColor = backgroundColor;
      _textStyle = textStyle;
      _alignment = alignment ?? Alignment.center;

      _progressNotifier = progressNotifier;
      _showCountdown = (progressNotifier == null && showCountdown);
      _currentTag = tag;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sharedController.forward(from: 0);

      if (progressNotifier == null && !persistent) {
        _closeTimer = Timer(duration, closeAnimated);
        if (_showCountdown) {
          _progressController.duration = duration;
          _progressController.forward(from: 0);
        }
      }

      if (onShown != null) onShown();
    });
  }

  void _insertActiveFloating(_PendingFloating pending) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final overlay = Overlay.of(context);

      // haptics
      if (widget.config.enableHaptics) {
        try {
          HapticFeedback.lightImpact();
        } catch (_) {}
      }

      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280),
      );
      final fade = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
      final sizeAnim = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);

      final styledContent = DefaultTextStyle(
        style:
            pending.textStyle ??
            Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: _colorOnSurfaceForType(pending.type, Theme.of(context).colorScheme),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                pending.onTap?.call();
              },
              child: pending.child,
            ),
            if (pending.actions != null && pending.actions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(mainAxisSize: MainAxisSize.min, children: pending.actions!),
            ],
          ],
        ),
      );

      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (ctx) {
          // calcula offset baseado em quantos ativos
          final index = _activeFloatings.length;
          final spacing = widget.config.floatingSpacing;
          final dy = (index * (spacing + (pending.height ?? 64))) * -1; // sobe pra cima

          return Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: SafeArea(
                child: Stack(
                  children: [
                    // Backdrop tap area
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: pending.persistent
                            ? null
                            : () => _removeActiveFloatingByEntry(entry),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: null,
                      top: null,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (context, childW) {
                            return Opacity(
                              opacity: fade.value,
                              child: Transform.translate(
                                offset: Offset(0, dy * (1 - fade.value)),
                                child: Transform.scale(
                                  scale: Tween<double>(
                                    begin: 0.96,
                                    end: 1.0,
                                  ).evaluate(sizeAnim),
                                  child: childW,
                                ),
                              ),
                            );
                          },
                          child: _FloatingNotificationContainer(
                            content: styledContent,
                            cornerRadius: widget.config.floatingCornerRadius,
                            maxWidthFactor: widget.config.floatingMaxWidthFactor,
                            backgroundColor:
                                pending.backgroundColor ??
                                _colorForType(
                                  pending.type,
                                  Theme.of(context).colorScheme,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      final active = _ActiveFloating(
        entry: entry,
        controller: controller,
        pending: pending,
      );
      _activeFloatings.add(active);
      overlay.insert(entry);

      await controller.forward();

      // notifica mostrado
      pending.onShown?.call();

      // auto close se não for persistent
      if (!pending.persistent) {
        active.closeTimer = Timer(pending.duration, () => _removeActiveFloating(active));
      }

      // processa fila se ainda tiver espaço
      _processQueueIfNeeded();
    });
  }

  void _processQueueIfNeeded() {
    while (_activeFloatings.length < widget.config.maxFloatingStack &&
        _floatingQueue.isNotEmpty) {
      final next = _floatingQueue.removeAt(0);
      _insertActiveFloating(next);
    }
  }

  void _removeActiveFloating(_ActiveFloating active) {
    if (!_activeFloatings.contains(active)) return;
    active.closeTimer?.cancel();
    active.controller.reverse().then((_) {
      try {
        active.entry.remove();
      } catch (_) {}
      active.controller.dispose();
      active.pending.onDismissed?.call();
      _activeFloatings.remove(active);
      _processQueueIfNeeded();
    });
  }

  void _removeActiveFloatingByEntry(OverlayEntry entry) {
    final found = _activeFloatings.firstWhere((e) => e.entry == entry);
    _removeActiveFloating(found);
  }

  void closeAnimated() {
    _closeTimer?.cancel();
    _progressController.stop();

    // fecha todos os flutuantes ativos
    if (_activeFloatings.isNotEmpty) {
      final copy = List<_ActiveFloating>.from(_activeFloatings);
      for (final a in copy) {
        _removeActiveFloating(a);
      }
      return;
    }

    if (!mounted || !_sharedController.isCompleted) return;

    _sharedController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _overlayContent = null;
        _currentPosition = null;
        _progressNotifier = null;
        _currentTag = null;
      });
    });
  }

  void _closeFloatingInstantByTag(String tag) {
    final found = _activeFloatings.where((e) => e.pending.tag == tag).toList();
    for (final a in found) {
      try {
        a.entry.remove();
      } catch (_) {}
      a.controller.dispose();
      a.pending.onDismissed?.call();
      _activeFloatings.remove(a);
    }
    _processQueueIfNeeded();
  }

  void _closeFloatingInstant() {
    for (final a in _activeFloatings) {
      try {
        a.entry.remove();
      } catch (_) {}
      a.controller.dispose();
      a.pending.onDismissed?.call();
    }
    _activeFloatings.clear();
    _floatingQueue.clear();
  }

  void _closeInstantly() {
    if (!mounted) return;
    _closeTimer?.cancel();
    _progressController.stop();
    _sharedController.value = 0;
    setState(() {
      _overlayContent = null;
      _currentPosition = null;
      _progressNotifier = null;
      _currentTag = null;
    });
  }

  @override
  void dispose() {
    _sharedController.dispose();
    _progressController.dispose();
    _closeTimer?.cancel();
    _padding.removeStatusListener(_paddingStatusListener);
    for (final a in _activeFloatings) {
      try {
        a.entry.remove();
      } catch (_) {}
      a.controller.dispose();
    }
    _activeFloatings.clear();
    _floatingQueue.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final styledContent = _overlayContent == null
        ? null
        : DefaultTextStyle(
            style:
                _textStyle ?? theme.textTheme.bodyMedium!.copyWith(color: cs.onSurface),
            child: _overlayContent!,
          );

    final overlayWidget = styledContent == null || _currentPosition == null
        ? null
        : Dismissible(
            key: ValueKey(_currentPosition),
            direction: _currentPosition == NotificationPosition.top
                ? DismissDirection.up
                : DismissDirection.down,
            onDismissed: (_) => _closeInstantly(),
            child: SizeTransition(
              sizeFactor: _sharedSize,
              axisAlignment: _currentPosition == NotificationPosition.top ? -1 : 1,
              child: FadeTransition(
                opacity: _sharedFade,
                child: _NotificationContainer(content: styledContent),
              ),
            ),
          );

    final mediaQueryData = MediaQuery.of(context);

    final safeAreaPadding = mediaQueryData.padding.copyWith(top: 0, bottom: 0);

    Widget contentWidget = switch (_mediaQuery) {
      true => MediaQuery(data: mediaQueryData, child: widget.child),
      false => MediaQuery(
        data: mediaQueryData.copyWith(padding: safeAreaPadding),
        child: CustomAnimatedPadding(
          animation: _padding,
          originalTop: mediaQueryData.padding.top,
          shouldKeepFullTop:
              _currentPosition == NotificationPosition.bottom ||
              _overlayContent == null ||
              _isOverlay,
          child: widget.child,
        ),
      ),
    };

    return Material(
      // Mantemos sombra só para top/bottom quando necessário
      elevation: overlayWidget != null && _currentPosition == NotificationPosition.top
          ? 6
          : 0,
      color: _mediaQuery && _currentPosition == NotificationPosition.top
          ? Colors.transparent
          : null,
      surfaceTintColor: cs.surfaceTint,
      shadowColor: cs.shadow,
      child: InheritedNotificationOverlay(
        state: this,
        child: _isOverlay
            ? Stack(
                children: [
                  contentWidget,
                  if (overlayWidget != null)
                    Align(
                      alignment: _currentPosition == NotificationPosition.top
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
                      child: overlayWidget,
                    ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentPosition == NotificationPosition.top &&
                      overlayWidget != null)
                    overlayWidget,
                  Expanded(child: contentWidget),
                  if (_currentPosition == NotificationPosition.bottom &&
                      overlayWidget != null)
                    overlayWidget,
                ],
              ),
      ),
    );
  }
}

class _ActiveFloating {
  final OverlayEntry entry;
  final AnimationController controller;
  final _PendingFloating pending;
  Timer? closeTimer;

  _ActiveFloating({required this.entry, required this.controller, required this.pending});
}

class _PendingFloating {
  final Widget child;
  final Duration duration;
  final ValueNotifier<double>? progressNotifier;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Alignment alignment;
  final double? height;
  final List<Widget>? actions;
  final String? tag;
  final int priority;
  final bool persistent;
  final NotificationType type;
  final NotificationCallback? onShown;
  final NotificationCallback? onDismissed;
  final NotificationCallback? onTap;

  _PendingFloating({
    required this.child,
    required this.duration,
    this.progressNotifier,
    this.backgroundColor,
    this.textStyle,
    this.alignment = Alignment.center,
    this.height,
    this.actions,
    this.tag,
    this.priority = 0,
    this.persistent = false,
    this.type = NotificationType.neutral,
    this.onShown,
    this.onDismissed,
    this.onTap,
  });
}

class _NotificationContainer extends StatelessWidget {
  final Widget content;
  const _NotificationContainer({required this.content});

  @override
  Widget build(BuildContext context) {
    final state = InheritedNotificationOverlay.of(context);
    final cs = Theme.of(context).colorScheme;

    // Use M3 surfaceVariant if available for contraste sutil
    final bg = state._backgroundColor ?? cs.surfaceContainerHighest;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        height: state._height,
        color: bg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((state._showCountdown || state._progressNotifier != null) &&
                state._currentPosition == NotificationPosition.bottom)
              _ProgressBar(
                controller: state._progressController,
                notifier: state._progressNotifier,
              ),
            Padding(
              padding: state._currentPosition == NotificationPosition.top
                  ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
                  : EdgeInsets.zero,
              child: SafeArea(
                top: state._currentPosition == NotificationPosition.top,
                bottom: state._currentPosition == NotificationPosition.bottom,
                child: Align(alignment: state._alignment, child: content),
              ),
            ),
            if ((state._showCountdown || state._progressNotifier != null) &&
                state._currentPosition == NotificationPosition.top)
              _ProgressBar(
                controller: state._progressController,
                notifier: state._progressNotifier,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final AnimationController controller;
  final ValueNotifier<double>? notifier;

  const _ProgressBar({required this.controller, this.notifier});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (notifier != null) {
      return ValueListenableBuilder<double>(
        valueListenable: notifier!,
        builder: (_, progress, __) => LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          color: cs.onSurface.withAlpha(128),
        ),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => LinearProgressIndicator(
        value: 1.0 - controller.value,
        backgroundColor: Colors.transparent,
        color: cs.onSurface.withAlpha(128),
      ),
    );
  }
}

class InheritedNotificationOverlay extends InheritedWidget {
  final AppNotificationOverlayState state;
  const InheritedNotificationOverlay({
    super.key,
    required this.state,
    required super.child,
  });

  static AppNotificationOverlayState of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<InheritedNotificationOverlay>();
    assert(result != null, 'No AppNotificationOverlay found in context');
    return result!.state;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotificationOverlay oldWidget) =>
      state != oldWidget.state;
}

/// Extension para usar direto do context — adicionei `actions`, `tag`, `priority`, `persistent`
extension NotificationOverlayExtension on BuildContext {
  void showTopNotification(
    Widget child, {
    double height = 90.0,
    Duration duration = const Duration(seconds: 4),
    bool showCountdown = true,
    ValueNotifier<double>? progressNotifier,
    Color? backgroundColor,
    TextStyle? textStyle,
    bool overlay = false,
    Alignment alignment = Alignment.centerLeft,
    List<Widget>? actions,
    String? tag,
    int priority = 0,
    bool persistent = false,
    NotificationType type = NotificationType.neutral,
    NotificationCallback? onShown,
    NotificationCallback? onDismissed,
    NotificationCallback? onTap,
  }) => InheritedNotificationOverlay.of(this).showTop(
    child: child,
    height: height,
    overlay: overlay,
    duration: duration,
    showCountdown: showCountdown,
    progressNotifier: progressNotifier,
    backgroundColor: backgroundColor,
    textStyle: textStyle,
    alignment: alignment,
    actions: actions,
    tag: tag,
    priority: priority,
    persistent: persistent,
    type: type,
    onShown: onShown,
    onDismissed: onDismissed,
    onTap: onTap,
  );

  bool hasNotification() =>
      InheritedNotificationOverlay.of(this)._overlayContent != null ||
      InheritedNotificationOverlay.of(this)._activeFloatings.isNotEmpty ||
      InheritedNotificationOverlay.of(this)._floatingQueue.isNotEmpty;

  void showBottomNotification(
    Widget child, {
    double height = 60.0,
    Duration duration = const Duration(seconds: 4),
    bool showCountdown = true,
    ValueNotifier<double>? progressNotifier,
    Color? backgroundColor,
    TextStyle? textStyle,
    bool overlay = false,
    Alignment alignment = Alignment.centerLeft,
    List<Widget>? actions,
    String? tag,
    int priority = 0,
    bool persistent = false,
    NotificationType type = NotificationType.neutral,
    NotificationCallback? onShown,
    NotificationCallback? onDismissed,
    NotificationCallback? onTap,
  }) => InheritedNotificationOverlay.of(this).showBottom(
    child: child,
    height: height,
    duration: duration,
    overlay: overlay,
    showCountdown: showCountdown,
    progressNotifier: progressNotifier,
    backgroundColor: backgroundColor,
    textStyle: textStyle,
    alignment: alignment,
    actions: actions,
    tag: tag,
    priority: priority,
    persistent: persistent,
    type: type,
    onShown: onShown,
    onDismissed: onDismissed,
    onTap: onTap,
  );

  void showFloatingNotification(
    Widget child, {
    Duration duration = const Duration(seconds: 4),
    ValueNotifier<double>? progressNotifier,
    Color? backgroundColor,
    TextStyle? textStyle,
    Alignment alignment = Alignment.center,
    double? height,
    List<Widget>? actions,
    String? tag,
    int priority = 0,
    bool persistent = false,
    NotificationType type = NotificationType.neutral,
    NotificationCallback? onShown,
    NotificationCallback? onDismissed,
    NotificationCallback? onTap,
  }) => InheritedNotificationOverlay.of(this).showFloating(
    child: child,
    duration: duration,
    progressNotifier: progressNotifier,
    backgroundColor: backgroundColor,
    textStyle: textStyle,
    alignment: alignment,
    height: height,
    actions: actions,
    tag: tag,
    priority: priority,
    persistent: persistent,
    type: type,
    onShown: onShown,
    onDismissed: onDismissed,
    onTap: onTap,
  );

  void maintainOverlap({
    Duration duration = const Duration(seconds: 4),
    ValueNotifier<double>? progressNotifier,
  }) => InheritedNotificationOverlay.of(
    this,
  ).maintainOverlap(duration: duration, progressNotifier: progressNotifier);

  void showErrorNotification(String message, {Duration? duration}) {
    final cs = Theme.of(this).colorScheme;
    _showPresetNotification(
      message: message,
      iconData: Icons.error_outline,
      backgroundColor: cs.errorContainer,
      foregroundColor: cs.onErrorContainer,
      duration: duration ?? const Duration(seconds: 5),
      type: NotificationType.error,
    );
  }

  void showSuccessNotification(String message, {Duration? duration}) {
    final cs = Theme.of(this).colorScheme;
    _showPresetNotification(
      message: message,
      iconData: Icons.check_circle_outline,
      backgroundColor: cs.tertiaryContainer,
      // backgroundColor: Color(0xFF4CAF50).withAlpha(120),
      foregroundColor: cs.onTertiaryContainer,
      duration: duration,
      type: NotificationType.success,
    );
  }

  void showWarningNotification(String message, {Duration? duration}) {
    final cs = Theme.of(this).colorScheme;
    _showPresetNotification(
      message: message,
      iconData: Icons.warning_amber_rounded,
      backgroundColor: cs.secondaryContainer,
      foregroundColor: cs.onSecondaryContainer,
      duration: duration ?? const Duration(seconds: 5),
      type: NotificationType.warning,
    );
  }

  void showInfoNotification(String message, {Duration? duration}) {
    final cs = Theme.of(this).colorScheme;
    _showPresetNotification(
      message: message,
      iconData: Icons.info_outline,
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      duration: duration,
      type: NotificationType.info,
    );
  }

  void showCancelableNotification(
    String message, {
    Duration? duration,
    Color? backgroundColor,
    Color? foregroundColor,
    bool overlay = false,
    NotificationPosition position = NotificationPosition.bottom,
    VoidCallback? onCancel,
  }) {
    final cs = Theme.of(this).colorScheme;

    final content = Row(
      children: [
        Expanded(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: foregroundColor ?? cs.onSurface),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          ),
          onPressed: () {
            closeNotification();
            onCancel?.call();
          },
          child: Text("Cancelar", style: TextStyle(color: foregroundColor ?? cs.primary)),
        ),
      ],
    );

    switch (position) {
      case NotificationPosition.top:
        showTopNotification(
          content,
          height: 100,
          backgroundColor: backgroundColor ?? cs.surfaceContainerHighest,
          duration: duration ?? const Duration(seconds: 5),
          overlay: overlay,
        );
      case NotificationPosition.bottom:
        showBottomNotification(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: content,
          ),
          height: 60,
          backgroundColor: backgroundColor ?? cs.surfaceContainerHighest,
          duration: duration ?? const Duration(seconds: 5),
          overlay: overlay,
        );
      case NotificationPosition.floating:
        showFloatingNotification(
          content,
          height: 100,
          duration: duration ?? const Duration(seconds: 5),
          backgroundColor: backgroundColor ?? cs.surfaceContainerHighest,
          textStyle: TextStyle(color: foregroundColor ?? cs.onSurface),
          alignment: Alignment.center,
        );
    }
  }

  void _showPresetNotification({
    required String message,
    required IconData iconData,
    required Color backgroundColor,
    required Color foregroundColor,
    Duration? duration,
    NotificationType type = NotificationType.neutral,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: foregroundColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: TextStyle(color: foregroundColor)),
        ),
      ],
    );

    showTopNotification(
      content,
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(seconds: 4),
      type: type,
    );
  }

  void closeNotification() => InheritedNotificationOverlay.of(this).closeAnimated();
}

class _FloatingNotificationContainer extends StatelessWidget {
  final Widget content;
  final double cornerRadius;
  final double maxWidthFactor;
  final Color? backgroundColor;

  const _FloatingNotificationContainer({
    required this.content,
    this.cornerRadius = 12,
    this.maxWidthFactor = 0.9,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.surface;
    final maxWidth = MediaQuery.of(context).size.width * maxWidthFactor;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(cornerRadius),
        color: bg,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 120, maxWidth: maxWidth, maxHeight: 240),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [content]),
          ),
        ),
      ),
    );
  }
}

/// --- Render object personalizado (mantive) ---

class CustomAnimatedPadding extends SingleChildRenderObjectWidget {
  final Animation<double> animation;
  final double originalTop;
  final bool shouldKeepFullTop;

  const CustomAnimatedPadding({
    super.key,
    required this.animation,
    required this.originalTop,
    required this.shouldKeepFullTop,
    required super.child,
  });

  @override
  RenderShiftedBox createRenderObject(BuildContext context) {
    return _RenderCustomAnimatedPadding(
      animation: animation,
      originalTop: originalTop,
      shouldKeepFullTop: shouldKeepFullTop,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderShiftedBox renderObject) {
    if (renderObject is _RenderCustomAnimatedPadding) {
      renderObject
        ..animation = animation
        ..originalTop = originalTop
        ..shouldKeepFullTop = shouldKeepFullTop;
    }
  }
}

class _RenderCustomAnimatedPadding extends RenderShiftedBox {
  _RenderCustomAnimatedPadding({
    required Animation<double> animation,
    required double originalTop,
    required bool shouldKeepFullTop,
  }) : _animation = animation,
       _originalTop = originalTop,
       _shouldKeepFullTop = shouldKeepFullTop,
       super(null);

  Animation<double> _animation;
  Animation<double> get animation => _animation;
  set animation(Animation<double> value) {
    if (value == _animation) return;
    _animation.removeListener(markNeedsLayout);
    _animation = value;
    _animation.addListener(markNeedsLayout);
    markNeedsLayout();
  }

  double _originalTop;
  double get originalTop => _originalTop;
  set originalTop(double value) {
    if (value == _originalTop) return;
    _originalTop = value;
    markNeedsLayout();
  }

  bool _shouldKeepFullTop;
  bool get shouldKeepFullTop => _shouldKeepFullTop;
  set shouldKeepFullTop(bool value) {
    if (value == _shouldKeepFullTop) return;
    _shouldKeepFullTop = value;
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsLayout);
    super.detach();
  }

  double get _effectiveTop {
    final double value = CurvedAnimation(
      parent: _animation,
      curve: Curves.linear, // Ajuste a curva se necessário
    ).value;
    return _shouldKeepFullTop ? _originalTop : _originalTop * (1 - value);
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    if (child == null) {
      size = constraints.constrain(Size.zero);
      return;
    }
    child!.layout(
      constraints.deflate(EdgeInsets.only(top: _effectiveTop)),
      parentUsesSize: true,
    );
    size = constraints.constrain(
      Size(child!.size.width, child!.size.height + _effectiveTop),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final Offset shiftedOffset = offset + Offset(0, _effectiveTop);
      context.paintChild(child!, shiftedOffset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    return result.addWithPaintOffset(
      offset: Offset(0, _effectiveTop),
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return child!.hitTest(result, position: transformed);
      },
    );
  }
}

Color _colorForType(NotificationType? type, ColorScheme cs) {
  switch (type) {
    case NotificationType.error:
      return cs.errorContainer;
    case NotificationType.success:
      return cs.tertiaryContainer;
    case NotificationType.warning:
      return cs.secondaryContainer;
    case NotificationType.info:
      return cs.primaryContainer;
    case NotificationType.neutral:
    default:
      return cs.surface;
  }
}

Color _colorOnSurfaceForType(NotificationType? type, ColorScheme cs) {
  switch (type) {
    case NotificationType.error:
      return cs.onErrorContainer;
    case NotificationType.success:
      return cs.onTertiaryContainer;
    case NotificationType.warning:
      return cs.onSecondaryContainer;
    case NotificationType.info:
      return cs.onPrimaryContainer;
    case NotificationType.neutral:
    default:
      return cs.onSurface;
  }
}
