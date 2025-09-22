// ignore_for_file: unused_field, unused_element

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum NotificationPosition { top, bottom, floating }

enum NotificationType { neutral, info, success, warning, error }

enum HapticType { light, medium, heavy, selection, vibrate }

class AppNotificationConfig {
  final int maxFloatingStack;
  final double floatingCornerRadius;
  final double floatingMaxWidthFactor;
  final bool enableHaptics;
  final double floatingSpacing;
  final Curve enterCurve;
  final Curve exitCurve;
  final bool highContrastMode;

  const AppNotificationConfig({
    this.maxFloatingStack = 3,
    this.floatingCornerRadius = 12.0,
    this.floatingMaxWidthFactor = 0.9,
    this.enableHaptics = true,
    this.floatingSpacing = 12.0,
    this.enterCurve = Curves.easeOutCubic,
    this.exitCurve = Curves.easeInCubic,
    this.highContrastMode = false,
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
  late Animation<double> _sharedFade;
  late Animation<double> _sharedSize;
  late Animation<double> _padding;
  late final AnimationController _progressController;

  Widget? _overlayContent;
  NotificationPosition? _currentPosition;
  ValueNotifier<double>? _progressNotifier;

  double? _height;
  bool _showCountdown = false;
  bool _mediaQuery = true;
  NotificationType _type = NotificationType.neutral;
  bool _isSizeComplete = false;
  bool _isOverlay = false;
  Color? _backgroundColor;
  TextStyle? _textStyle;
  Alignment _alignment = Alignment.center;
  Timer? _closeTimer;
  Timer? _sizeTimer;

  final List<_ActiveFloating> _activeFloatings = [];
  final List<_PendingNotification> _floatingQueue = [];

  final List<_PendingNotification> _topQueue = [];
  final List<_PendingNotification> _bottomQueue = [];

  final Map<String, int> _tagCounters = {};

  String? _currentTag;

  @override
  void initState() {
    super.initState();
    _sharedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _updateAnimations();
    _padding = CurvedAnimation(
      parent: _sharedController,
      curve: widget.config.enterCurve,
      reverseCurve: widget.config.exitCurve,
    )..addStatusListener(_paddingStatusListener);
    _progressController = AnimationController(vsync: this);
  }

  void _updateAnimations() {
    _sharedFade = CurvedAnimation(
      parent: _sharedController,
      curve: widget.config.enterCurve,
      reverseCurve: widget.config.exitCurve,
    );
    _sharedSize = CurvedAnimation(
      parent: _sharedController,
      curve: widget.config.enterCurve,
    );
  }

  void _paddingStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isSizeComplete) setState(() => _mediaQuery = true);
        });

      case AnimationStatus.forward:
      case AnimationStatus.reverse:
      case AnimationStatus.completed:
        break;
    }
  }

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
    Widget? leading,
    Widget? trailing,
    bool expandable = false,
    DismissDirection dismissDirection = DismissDirection.up,
    bool autoDismissOnTap = false,
    HapticType hapticType = HapticType.light,
    Duration? scheduleDelay,
    String? announceMessage,
    Key? notificationKey,
    Offset? enterOffset,
  }) {
    final pending = _PendingNotification(
      child: child,
      position: NotificationPosition.top,
      duration: duration,
      overlay: overlay,
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
      leading: leading,
      trailing: trailing,
      expandable: expandable,
      dismissDirection: dismissDirection,
      autoDismissOnTap: autoDismissOnTap,
      hapticType: hapticType,
      announceMessage: announceMessage,
      notificationKey: notificationKey,
      enterOffset: enterOffset,
    );
    if (scheduleDelay != null) {
      Timer(scheduleDelay, () => _showPending(pending));
    } else {
      _showPending(pending);
    }
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
    Widget? leading,
    Widget? trailing,
    bool expandable = false,
    DismissDirection dismissDirection = DismissDirection.down,
    bool autoDismissOnTap = false,
    HapticType hapticType = HapticType.light,
    Duration? scheduleDelay,
    String? announceMessage,
    Key? notificationKey,
    Offset? enterOffset,
  }) {
    final pending = _PendingNotification(
      child: child,
      position: NotificationPosition.bottom,
      duration: duration,
      overlay: overlay,
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
      leading: leading,
      trailing: trailing,
      expandable: expandable,
      dismissDirection: dismissDirection,
      autoDismissOnTap: autoDismissOnTap,
      hapticType: hapticType,
      announceMessage: announceMessage,
      notificationKey: notificationKey,
      enterOffset: enterOffset,
    );
    if (scheduleDelay != null) {
      Timer(scheduleDelay, () => _showPending(pending));
    } else {
      _showPending(pending);
    }
  }

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
    Widget? leading,
    Widget? trailing,
    bool expandable = false,
    DismissDirection dismissDirection = DismissDirection.horizontal,
    bool autoDismissOnTap = false,

    HapticType hapticType = HapticType.light,
    Duration? scheduleDelay,
    String? announceMessage,
    Key? notificationKey,
    Offset? enterOffset,
  }) {
    final pending = _PendingNotification(
      child: child,
      position: NotificationPosition.floating,
      duration: duration,
      overlay: true,
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
      leading: leading,
      trailing: trailing,
      expandable: expandable,
      dismissDirection: dismissDirection,
      autoDismissOnTap: autoDismissOnTap,
      hapticType: hapticType,
      announceMessage: announceMessage,
      notificationKey: notificationKey,
      enterOffset: enterOffset,
    );
    if (scheduleDelay != null) {
      Timer(scheduleDelay, () => _showPending(pending));
    } else {
      _showPending(pending);
    }
  }

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
      _sizeTimer?.cancel();
      _sizeTimer = Timer(const Duration(milliseconds: 200), () => _isSizeComplete = true);
      _closeTimer = Timer(duration, closeAnimated);
      if (_showCountdown) {
        _progressController.duration = duration;
        _progressController.forward(from: 0);
      }
    }
  }

  void _showPending(_PendingNotification pending) {
    if (pending.tag != null) {
      if (_tagCounters.containsKey(pending.tag)) {
        _tagCounters[pending.tag!] = _tagCounters[pending.tag]! + 1;
        _isSizeComplete = false;

        pending = pending.copyWith(child: pending.child);
      } else {
        _tagCounters[pending.tag!] = 1;
      }
    }
    _showNotification(pending);
  }

  void _showNotification(_PendingNotification pending) {
    if (pending.tag != null &&
        pending.tag == _currentTag &&
        (_tagCounters[pending.tag!] ?? 1) == 1) {
      return;
    }
    _isSizeComplete = false;

    if (pending.position == NotificationPosition.floating) {
      _handleFloating(pending);
    } else {
      _handleTopBottom(pending);
    }
  }

  void _handleFloating(_PendingNotification pending) {
    setState(() {
      _isOverlay = pending.overlay;
      _mediaQuery = false;
    });

    if (_activeFloatings.length >= widget.config.maxFloatingStack) {
      _activeFloatings.sort((a, b) => a.pending.priority.compareTo(b.pending.priority));
      final lowest = _activeFloatings.first;
      if (pending.priority > lowest.pending.priority) {
        _removeActiveFloating(lowest);
        _insertActiveFloating(pending);
        return;
      }
      if (_floatingQueue.length < 64) {
        _floatingQueue.add(pending);
      }
      return;
    }

    _insertActiveFloating(pending);
  }

  void _handleTopBottom(_PendingNotification pending) {
    final queue = pending.position == NotificationPosition.top ? _topQueue : _bottomQueue;
    queue.add(pending);
    _processTopBottomQueue(pending.position);
  }

  void _processTopBottomQueue(NotificationPosition position) {
    final queue = position == NotificationPosition.top ? _topQueue : _bottomQueue;
    if (queue.isEmpty || _overlayContent != null) return;

    final pending = queue.removeAt(0);
    _displayTopBottom(pending);
  }

  void _displayTopBottom(_PendingNotification pending) {
    _closeTimer?.cancel();
    _progressController.stop();
    setState(() {
      _isOverlay = pending.overlay;
      _mediaQuery = false;
      _overlayContent = _buildStyledContent(pending, context);
      _currentPosition = pending.position;
      _height = pending.height;
      _backgroundColor = pending.backgroundColor;
      _textStyle = pending.textStyle;
      _type = pending.type;
      _alignment = pending.alignment;
      _progressNotifier = pending.progressNotifier;
      _showCountdown = (pending.progressNotifier == null && pending.showCountdown);
      _currentTag = pending.tag;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _sizeTimer?.cancel();
      _sizeTimer = Timer(const Duration(milliseconds: 200), () => _isSizeComplete = true);
      _sharedController.forward(from: 0);

      if (pending.progressNotifier == null && !pending.persistent) {
        _closeTimer = Timer(pending.duration, closeAnimated);
        if (_showCountdown) {
          _progressController.duration = pending.duration;
          _progressController.forward(from: 0);
        }
      }

      pending.onShown?.call();
      _triggerHaptic(pending.hapticType);
      if (pending.announceMessage != null) {
        SemanticsService.announce(pending.announceMessage!, TextDirection.ltr);
      }
      _processTopBottomQueue(pending.position);
    });
  }

  Widget _buildStyledContent(_PendingNotification pending, BuildContext ctx) {
    IconData? defaultIcon = _defaultIconForType(pending.type);

    return DefaultTextStyle(
      style:
          pending.textStyle ??
          Theme.of(ctx).textTheme.bodyMedium!.copyWith(
            color: _colorOnSurfaceForType(pending.type, Theme.of(ctx).colorScheme),
          ),
      child: pending.expandable
          ? ExpansionTile(title: pending.child, children: [pending.child])
          : Row(
              children: [
                if (pending.leading != null)
                  pending.leading!
                else if (defaultIcon != null)
                  Icon(defaultIcon),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      pending.onTap?.call();
                      if (pending.autoDismissOnTap) {
                        closeAnimated();
                      }
                    },
                    child: pending.child,
                  ),
                ),
                if (pending.trailing != null) pending.trailing!,
                if (pending.actions != null && pending.actions!.isNotEmpty)
                  ...pending.actions!,
              ],
            ),
    );
  }

  void _insertActiveFloating(_PendingNotification pending) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final overlay = Overlay.of(context);

      if (widget.config.enableHaptics) {
        _triggerHaptic(pending.hapticType);
      }

      if (pending.announceMessage != null) {
        SemanticsService.announce(pending.announceMessage!, TextDirection.ltr);
      }

      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280),
      );
      final fade = CurvedAnimation(
        parent: controller,
        curve: widget.config.enterCurve,
        reverseCurve: widget.config.exitCurve,
      );
      final sizeAnim = CurvedAnimation(
        parent: controller,
        curve: widget.config.enterCurve,
      );
      final slideAnim = Tween<Offset>(
        begin: pending.enterOffset ?? Offset.zero,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: widget.config.enterCurve));

      final styledContent = _buildStyledContent(pending, context);

      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (ctx) {
          final index = _activeFloatings.length;
          final spacing = widget.config.floatingSpacing;
          final dy = (index * (spacing + (pending.height ?? 64))) * -1;

          return Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: SafeArea(
                child: Stack(
                  children: [
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
                        child: Dismissible(
                          key: pending.notificationKey ?? UniqueKey(),
                          direction: pending.dismissDirection,
                          onDismissed: (_) => _removeActiveFloatingByEntry(entry),
                          child: AnimatedBuilder(
                            animation: controller,
                            builder: (context, childW) {
                              return Opacity(
                                opacity: fade.value,
                                child: Transform.translate(
                                  offset:
                                      slideAnim.value + Offset(0, dy * (1 - fade.value)),
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

      pending.onShown?.call();

      if (!pending.persistent) {
        active.closeTimer = Timer(pending.duration, () => _removeActiveFloating(active));
      }

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
      if (active.pending.tag != null) {
        _tagCounters.remove(active.pending.tag);
      }
      _activeFloatings.remove(active);
      _processQueueIfNeeded();
    });
  }

  void _removeActiveFloatingByEntry(OverlayEntry entry) {
    final found = _activeFloatings.firstWhereOrNull((e) => e.entry == entry);
    if (found != null) _removeActiveFloating(found);
  }

  void closeAnimated() {
    _closeTimer?.cancel();
    _progressController.stop();

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
      _processTopBottomQueue(_currentPosition ?? NotificationPosition.top);
    });
  }

  void closeByTag(String tag) {
    _closeFloatingInstantByTag(tag);
    if (_currentTag == tag) {
      _closeInstantly();
    }
    _topQueue.removeWhere((p) => p.tag == tag);
    _bottomQueue.removeWhere((p) => p.tag == tag);
    _tagCounters.remove(tag);
  }

  void closeByType(NotificationType type) {
    final toRemove = _activeFloatings.where((e) => e.pending.type == type).toList();
    for (final a in toRemove) {
      _removeActiveFloating(a);
    }

    if (_overlayContent != null /* && current type == type */ ) {
      _closeInstantly();
    }
    _topQueue.removeWhere((p) => p.type == type);
    _bottomQueue.removeWhere((p) => p.type == type);
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

  void _triggerHaptic(HapticType type) {
    if (!widget.config.enableHaptics) return;
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  @override
  void didUpdateWidget(covariant AppNotificationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _updateAnimations();
    }
  }

  @override
  void dispose() {
    _sharedController.dispose();
    _progressController.dispose();
    _closeTimer?.cancel();
    _sizeTimer?.cancel();
    _padding.removeStatusListener(_paddingStatusListener);
    for (final a in _activeFloatings) {
      try {
        a.entry.remove();
      } catch (_) {}
      a.controller.dispose();
    }
    _activeFloatings.clear();
    _floatingQueue.clear();
    _topQueue.clear();
    _bottomQueue.clear();
    _tagCounters.clear();
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
        child: _CustomAnimatedPadding(
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
                  Positioned.fill(child: contentWidget),
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
  final _PendingNotification pending;
  Timer? closeTimer;

  _ActiveFloating({required this.entry, required this.controller, required this.pending});
}

class _PendingNotification {
  final Widget child;
  final NotificationPosition position;
  final Duration duration;
  final bool overlay;
  final bool showCountdown;
  final ValueNotifier<double>? progressNotifier;
  final Color? backgroundColor;
  final double? height;
  final TextStyle? textStyle;
  final Alignment alignment;
  final List<Widget>? actions;
  final String? tag;
  final int priority;
  final bool persistent;
  final NotificationType type;
  final NotificationCallback? onShown;
  final NotificationCallback? onDismissed;
  final NotificationCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool expandable;
  final DismissDirection dismissDirection;
  final bool autoDismissOnTap;
  final HapticType hapticType;
  final String? announceMessage;
  final Key? notificationKey;
  final Offset? enterOffset;

  _PendingNotification({
    required this.child,
    required this.position,
    required this.duration,
    this.overlay = false,
    this.showCountdown = true,
    this.progressNotifier,
    this.backgroundColor,
    this.height,
    this.textStyle,
    this.alignment = Alignment.center,
    this.actions,
    this.tag,
    this.priority = 0,
    this.persistent = false,
    this.type = NotificationType.neutral,
    this.onShown,
    this.onDismissed,
    this.onTap,
    this.leading,
    this.trailing,
    this.expandable = false,
    this.dismissDirection = DismissDirection.none,
    this.autoDismissOnTap = false,
    this.hapticType = HapticType.light,
    this.announceMessage,
    this.notificationKey,
    this.enterOffset,
  });

  _PendingNotification copyWith({
    Widget? child,
    NotificationPosition? position,
    Duration? duration,
    bool? overlay,
    bool? showCountdown,
    ValueNotifier<double>? progressNotifier,
    Color? backgroundColor,
    double? height,
    TextStyle? textStyle,
    Alignment? alignment,
    List<Widget>? actions,
    String? tag,
    int? priority,
    bool? persistent,
    NotificationType? type,
    NotificationCallback? onShown,
    NotificationCallback? onDismissed,
    NotificationCallback? onTap,
    Widget? leading,
    Widget? trailing,
    bool? expandable,
    DismissDirection? dismissDirection,
    bool? autoDismissOnTap,
    HapticType? hapticType,
    String? announceMessage,
    Key? notificationKey,
    Offset? enterOffset,
  }) {
    return _PendingNotification(
      child: child ?? this.child,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      overlay: overlay ?? this.overlay,
      showCountdown: showCountdown ?? this.showCountdown,
      progressNotifier: progressNotifier ?? this.progressNotifier,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      textStyle: textStyle ?? this.textStyle,
      alignment: alignment ?? this.alignment,
      actions: actions ?? this.actions,
      tag: tag ?? this.tag,
      priority: priority ?? this.priority,
      persistent: persistent ?? this.persistent,
      type: type ?? this.type,
      onShown: onShown ?? this.onShown,
      onDismissed: onDismissed ?? this.onDismissed,
      onTap: onTap ?? this.onTap,
      leading: leading ?? this.leading,
      trailing: trailing ?? this.trailing,
      expandable: expandable ?? this.expandable,
      dismissDirection: dismissDirection ?? this.dismissDirection,
      autoDismissOnTap: autoDismissOnTap ?? this.autoDismissOnTap,
      hapticType: hapticType ?? this.hapticType,
      announceMessage: announceMessage ?? this.announceMessage,
      notificationKey: notificationKey ?? this.notificationKey,
      enterOffset: enterOffset ?? this.enterOffset,
    );
  }
}

IconData? _defaultIconForType(NotificationType type) {
  switch (type) {
    case NotificationType.info:
      return Icons.info_outline;
    case NotificationType.success:
      return Icons.check_circle_outline;
    case NotificationType.warning:
      return Icons.warning_amber_rounded;
    case NotificationType.error:
      return Icons.error_outline;
    case NotificationType.neutral:
      return null;
  }
}

class _NotificationContainer extends StatelessWidget {
  final Widget content;
  const _NotificationContainer({required this.content});

  @override
  Widget build(BuildContext context) {
    final state = InheritedNotificationOverlay.of(context);
    final cs = Theme.of(context).colorScheme;

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
    Widget? leading,
    Widget? trailing,
    bool expandable = false,
    DismissDirection dismissDirection = DismissDirection.up,
    bool autoDismissOnTap = false,
    HapticType hapticType = HapticType.light,
    Duration? scheduleDelay,
    String? announceMessage,
    Key? notificationKey,
    Offset? enterOffset,
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
    leading: leading,
    trailing: trailing,
    expandable: expandable,
    dismissDirection: dismissDirection,
    autoDismissOnTap: autoDismissOnTap,
    hapticType: hapticType,
    scheduleDelay: scheduleDelay,
    announceMessage: announceMessage,
    notificationKey: notificationKey,
    enterOffset: enterOffset,
  );

  bool hasNotification() =>
      InheritedNotificationOverlay.of(this)._overlayContent != null ||
      InheritedNotificationOverlay.of(this)._activeFloatings.isNotEmpty ||
      InheritedNotificationOverlay.of(this)._floatingQueue.isNotEmpty ||
      InheritedNotificationOverlay.of(this)._topQueue.isNotEmpty ||
      InheritedNotificationOverlay.of(this)._bottomQueue.isNotEmpty;

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
    Widget? leading,
    Widget? trailing,
    bool expandable = false,
    DismissDirection dismissDirection = DismissDirection.down,
    bool autoDismissOnTap = false,
    HapticType hapticType = HapticType.light,
    Duration? scheduleDelay,
    String? announceMessage,
    Key? notificationKey,
    Offset? enterOffset,
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
    leading: leading,
    trailing: trailing,
    expandable: expandable,
    dismissDirection: dismissDirection,
    autoDismissOnTap: autoDismissOnTap,
    hapticType: hapticType,
    scheduleDelay: scheduleDelay,
    announceMessage: announceMessage,
    notificationKey: notificationKey,
    enterOffset: enterOffset,
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
    Widget? leading,
    Widget? trailing,
    bool expandable = false,
    DismissDirection dismissDirection = DismissDirection.horizontal,
    bool autoDismissOnTap = false,
    HapticType hapticType = HapticType.light,
    Duration? scheduleDelay,
    String? announceMessage,
    Key? notificationKey,
    Offset? enterOffset,
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
    leading: leading,
    trailing: trailing,
    expandable: expandable,
    dismissDirection: dismissDirection,
    autoDismissOnTap: autoDismissOnTap,
    hapticType: hapticType,
    scheduleDelay: scheduleDelay,
    announceMessage: announceMessage,
    notificationKey: notificationKey,
    enterOffset: enterOffset,
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
      iconData: MdiIcons.alertCircleOutline,
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
      iconData: MdiIcons.checkCircleOutline,
      backgroundColor: cs.tertiaryContainer,
      foregroundColor: cs.onTertiaryContainer,
      duration: duration,
      type: NotificationType.success,
    );
  }

  void showWarningNotification(String message, {Duration? duration}) {
    final cs = Theme.of(this).colorScheme;
    _showPresetNotification(
      message: message,
      iconData: MdiIcons.alertOutline,
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
      iconData: MdiIcons.informationOutline,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: foregroundColor ?? cs.onSurface),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
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
        // Icon(iconData, color: foregroundColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: foregroundColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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

  void showProgressNotification(
    String message, {
    required ValueNotifier<double> progress,
    Color? backgroundColor,
    Color? foregroundColor,
    double height = 86,
    NotificationPosition position = NotificationPosition.bottom,
  }) {
    final cs = Theme.of(this).colorScheme;

    final content = ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, value, _) {
        return Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                "$message (${(value * 100).toStringAsFixed(0)}%)",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: foregroundColor ?? cs.onSurface),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );

    switch (position) {
      case NotificationPosition.top:
        showTopNotification(
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: content),
          height: height,
          showCountdown: false,
          persistent: true,
          duration: const Duration(days: 1),
          backgroundColor: backgroundColor ?? cs.surfaceContainerHighest,
          overlay: false,
        );
      case NotificationPosition.bottom:
        showBottomNotification(
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: content),
          height: height,
          duration: const Duration(days: 1),
          backgroundColor: backgroundColor ?? cs.surfaceContainerHighest,
          overlay: false,
        );
      case NotificationPosition.floating:
        showFloatingNotification(
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: content),
          height: height,
          duration: const Duration(days: 1),
          backgroundColor: backgroundColor ?? cs.surfaceContainerHighest,
          textStyle: TextStyle(color: foregroundColor ?? cs.onSurface),
        );
    }
  }

  void closeNotification() => InheritedNotificationOverlay.of(this).closeAnimated();

  void closeByTag(String tag) => InheritedNotificationOverlay.of(this).closeByTag(tag);

  void closeByType(NotificationType type) =>
      InheritedNotificationOverlay.of(this).closeByType(type);
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

class _CustomAnimatedPadding extends SingleChildRenderObjectWidget {
  final Animation<double> animation;
  final double originalTop;
  final bool shouldKeepFullTop;

  const _CustomAnimatedPadding({
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
    final double value = CurvedAnimation(parent: _animation, curve: Curves.linear).value;
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
