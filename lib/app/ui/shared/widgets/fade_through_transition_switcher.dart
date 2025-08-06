import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

class FadeThroughTransitionSwitcher extends StatelessWidget {
  const FadeThroughTransitionSwitcher({
    super.key,
    required this.child,
    this.secondChild = const SizedBox.shrink(),
    this.enableSecondChild = false,
    this.duration = const Duration(milliseconds: 300),
    this.fillColor = Colors.transparent,
  });

  final Widget child;
  final Widget secondChild;
  final bool enableSecondChild;
  final Duration duration;
  final Color fillColor;

  bool get _onlySwitch => secondChild is SizedBox && !enableSecondChild;

  static Widget defaultLayoutBuilder(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return SliverStack(
      children: [...previousChildren, if (currentChild != null) currentChild],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeChild = _onlySwitch
        ? KeyedSubtree(key: ValueKey('${child.runtimeType} onlyChild'), child: child)
        : enableSecondChild
        ? KeyedSubtree(
            key: ValueKey('${secondChild.runtimeType} secondChild'),
            child: secondChild,
          )
        : KeyedSubtree(key: ValueKey('${child.runtimeType} firstChild'), child: child);

    return PageTransitionSwitcher(
      duration: duration,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return FadeThroughTransition(
          fillColor: fillColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: activeChild,
    );
  }
}

const double _kTabHeight = 46.0;

class TabBarSwitcher extends StatelessWidget implements PreferredSizeWidget {
  const TabBarSwitcher({
    super.key,
    required this.tabBar,
    required this.secondTabBar,
    this.enableSecondChild = false,
    this.duration = const Duration(milliseconds: 300),
    this.fillColor = Colors.transparent,
  });

  final TabBar tabBar;
  final TabBar secondTabBar;
  final bool enableSecondChild;
  final Duration duration;
  final Color fillColor;

  @override
  Size get preferredSize {
    final TabBar current = enableSecondChild ? secondTabBar : tabBar;

    double maxHeight = _kTabHeight;
    for (final Widget tab in current.tabs) {
      if (tab is PreferredSizeWidget) {
        maxHeight = math.max(tab.preferredSize.height, maxHeight);
      }
    }

    return Size.fromHeight(maxHeight + current.indicatorWeight);
  }

  @override
  Widget build(BuildContext context) {
    return FadeThroughTransitionSwitcher(
      secondChild: secondTabBar,
      enableSecondChild: enableSecondChild,
      duration: duration,
      fillColor: fillColor,
      child: tabBar,
    );
  }
}
