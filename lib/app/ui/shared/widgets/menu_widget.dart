import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class MenuWidget<T> extends StatefulWidget {
  final T data;
  final String Function(T data) label;
  final bool startOpenMenu;

  final List<T> items;

  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final BorderRadius menuBorderRadius;
  final BoxConstraints? constraints;
  final bool disableButton;
  final void Function(T selected)? onChange;

  const MenuWidget({
    super.key,
    this.borderRadius = BorderRadius.zero,
    this.menuBorderRadius = BorderRadius.zero,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.startOpenMenu = false,
    this.constraints,
    this.disableButton = false,
    this.onChange,
    required this.data,
    required this.items,
    required this.label,
  });

  @override
  State<MenuWidget<T>> createState() => _MenuWidgetState<T>();
}

class _MenuWidgetState<T> extends State<MenuWidget<T>> {
  late final _MenuController _menuController;

  @override
  void initState() {
    _menuController = _MenuController(
      widget.startOpenMenu,
      widget.label.call(widget.data),
    );
    super.initState();
  }

  final GlobalKey _container = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final constraints = widget.constraints;
    final cardShape = RoundedRectangleBorder(borderRadius: widget.borderRadius);

    return ChangeNotifierProvider(
      create: (context) => _menuController,
      child: Padding(
        padding: widget.padding,
        key: _container,
        child: ConstrainedBox(
          constraints: constraints ?? const BoxConstraints.expand(),
          child: Card(
            shape: cardShape,
            elevation: 1,
            margin: EdgeInsets.zero,
            child: Builder(
              builder: (context) => InkWell(
                borderRadius: widget.borderRadius,
                onTap: widget.disableButton ? null : () => _openMenu(context),
                child: const Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: _LabelWidget(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 4, left: 8),
                        child: _BuildIcon(),
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
  }

  void _openMenu(BuildContext context) async {
    _menuController.setIsOpen = true;
    final theme = Theme.of(context);
    final timer = Timer(
      const Duration(seconds: 15),
      Navigator.of(context).pop,
    );
    final result = await showMenu<T>(
      context: context,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: widget.menuBorderRadius),
      position: _buttonPosition(context),
      items: List.generate(
        widget.items.length,
        (index) {
          final item = widget.items.elementAt(index);
          return PopupMenuItem<T>(
            value: item,
            height: 45,
            padding: EdgeInsets.zero,
            child: Center(
              child: Text(
                widget.label.call(item),
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
          );
        },
      ),
    );
    timer.cancel();
    _menuController.setIsOpen = false;
    if (result == null || _menuController.label == widget.label.call(result)) {
      return;
    }
    _menuController.setLabel = widget.label.call(result);
    widget.onChange?.call(result);
  }

  RelativeRect _buttonPosition(BuildContext context) {
    final RenderBox bar = context.findRenderObject() as RenderBox;
    // final RenderBox bar =
    //     _container.currentContext?.findRenderObject() as RenderPadding;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // final double startdx = (bar.size.width * .2) * .2;
    const double startdx = 4.0;

    // final barText = _test.currentContext?.findRenderObject() as RenderPadding;

    const Offset offset = Offset(startdx, 0);
    // final size = _container.currentContext?.size;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        bar.localToGlobal(bar.size.bottomLeft(offset), ancestor: overlay),
        bar.localToGlobal(bar.size.bottomLeft(offset), ancestor: overlay),
      ),
      const Offset(0, 0) & Size(overlay.size.width, overlay.size.height),
    ).inflate(-6);

    return position;
  }
}

class _LabelWidget extends StatelessWidget {
  const _LabelWidget();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final menuController = context.watch<_MenuController>();
    final label = menuController.label;

    return Text(
      label,
      style: themeData.textTheme.labelMedium!
          .copyWith(color: themeData.colorScheme.primary),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}

class _BuildIcon extends StatelessWidget {
  const _BuildIcon();

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<_MenuController>();
    final isOpen = menuController.isOpenMenu;
    final theme = Theme.of(context);
    Widget icon =
        Icon(MdiIcons.menuUp, color: theme.colorScheme.primary, size: 20);
    if (!isOpen) {
      icon =
          Icon(MdiIcons.menuDown, color: theme.colorScheme.primary, size: 20);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: icon,
      ),
    );
  }
}

class _MenuController extends ChangeNotifier {
  String _label = '';
  bool _isOpenMenu = false;

  _MenuController(bool startOpenMenu, String startLabel) {
    _isOpenMenu = startOpenMenu;
    _label = startLabel;
  }

  String get label => _label;

  bool get isOpenMenu => _isOpenMenu;

  set setIsOpen(bool isOpen) {
    _isOpenMenu = isOpen;
    notifyListeners();
  }

  set setLabel(String label) {
    _label = label;
    notifyListeners();
  }
}
