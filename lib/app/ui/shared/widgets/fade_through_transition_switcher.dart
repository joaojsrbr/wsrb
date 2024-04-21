import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'dart:math' as math;

class FadeThroughTransitionSwitcher extends StatelessWidget {
  const FadeThroughTransitionSwitcher({
    super.key,
    this.fillColor = Colors.transparent,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.enableSecondChild = false,
    this.secondChild = const SizedBox.shrink(),
  }) : _onlySwitch = false;

  final Widget child;
  final Widget secondChild;
  final Duration duration;
  final bool enableSecondChild;
  final Color fillColor;
  final bool _onlySwitch;

  const FadeThroughTransitionSwitcher.noSecondChild({
    super.key,
    this.fillColor = Colors.transparent,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  })  : _onlySwitch = true,
        enableSecondChild = false,
        secondChild = const SizedBox.shrink();

  static Widget defaultLayoutBuilder(
      Widget? currentChild, List<Widget> previousChildren) {
    return SliverStack(
      children: <Widget>[
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: _onlySwitch
          ? child
          : enableSecondChild
              ? KeyedSubtree(
                  key: ValueKey('${secondChild.runtimeType} secondChild'),
                  child: secondChild,
                )
              : KeyedSubtree(
                  key: ValueKey('${child.runtimeType} firstChild'),
                  child: child,
                ),
    );
  }
}

const double _kTabHeight = 46.0;

class TabBarSwitcher extends FadeThroughTransitionSwitcher
    implements PreferredSizeWidget {
  const TabBarSwitcher({
    super.key,
    super.fillColor = Colors.transparent,
    required TabBar tabBar,
    required TabBar secondTabBar,
    super.duration = const Duration(milliseconds: 300),
    super.enableSecondChild = false,
  }) : super(child: tabBar, secondChild: secondTabBar);

  @override
  Size get preferredSize {
    TabBar tabBar = child as TabBar;
    if (enableSecondChild) {
      tabBar = secondChild as TabBar;
    }

    double maxHeight = _kTabHeight;
    for (final Widget item in tabBar.tabs) {
      if (item is PreferredSizeWidget) {
        final double itemHeight = item.preferredSize.height;
        maxHeight = math.max(itemHeight, maxHeight);
      }
    }
    return Size.fromHeight(maxHeight + tabBar.indicatorWeight);
  }
}
