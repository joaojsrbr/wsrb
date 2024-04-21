import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _defaultBorderRadius = BorderRadius.all(Radius.circular(8));

typedef CustomToggleButtonsBuilder<A> = Widget Function(
    BuildContext context, A item, int index);

class CustomToggleButtons<A> extends StatefulWidget {
  const CustomToggleButtons({
    super.key,
    required this.items,
    this.initialSelected,
    this.constraints,
    this.focusNodes,
    this.onTap,
    this.didUpdate,
    this.padding,
    this.borderRadius = _defaultBorderRadius,
    required this.itemBuilder,
  });

  final A? initialSelected;
  final CustomToggleButtonsBuilder<A> itemBuilder;
  final List<A> items;
  final ValueChanged<ValueNotifier<A>>? didUpdate;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final List<FocusNode>? focusNodes;
  final BoxConstraints? constraints;
  final ValueChanged<A>? onTap;

  @override
  State<CustomToggleButtons<A>> createState() => _CustomToggleButtonsState<A>();
}

class _CustomToggleButtonsState<A> extends State<CustomToggleButtons<A>> {
  List<A> get _items => widget.items;

  A? get _initialSelected => widget.initialSelected;

  late List<bool> _isSelected;

  late ValueNotifier<A> _selected;

  @override
  void initState() {
    super.initState();
    _initSelected();
    _startList();
    _setIsSelected();
  }

  @override
  void didUpdateWidget(covariant CustomToggleButtons<A> oldWidget) {
    if (!listEquals(_items, oldWidget.items)) {
      _startList();
      _setIsSelected();
    }

    final indexOf = _items.indexOf(_selected.value);

    if (!_isSelected[indexOf]) {
      final oldSelectedIndex = _isSelected.indexWhere(
        (element) => element == true,
      );

      _isSelected[oldSelectedIndex] = false;
      _isSelected[indexOf] = true;
    }

    widget.didUpdate?.call(_selected);

    super.didUpdateWidget(oldWidget);
  }

  void _initSelected() {
    _selected = ValueNotifier(_items.first);
    if (_initialSelected != null) {
      _selected = ValueNotifier(_initialSelected as A);
    }
    _selected.addListener(_selectedListener);
  }

  void _selectedListener() {
    final indexOf = _items.indexOf(_selected.value);
    final oldSelectedIndex = _isSelected.indexWhere(
      (element) => element == true,
    );
    if (mounted) {
      setState(() {
        _isSelected[oldSelectedIndex] = false;
        _isSelected[indexOf] = true;
      });
    } else {
      _isSelected[oldSelectedIndex] = false;
      _isSelected[indexOf] = true;
    }
  }

  void _startList() {
    _isSelected = List.generate(_items.length, (index) => false);
  }

  void _setIsSelected() {
    final indexOf = _items.indexOf(_selected.value);
    _isSelected[indexOf] = true;
  }

  void _handlePressed(int index) {
    _selected.value = _items[index];
    widget.onTap?.call(_selected.value);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    Widget container = ToggleButtons(
      constraints: widget.constraints,
      splashColor: themeData.splashColor,
      onPressed: _handlePressed,
      isSelected: _isSelected,
      borderRadius: widget.borderRadius,
      focusNodes: widget.focusNodes,
      children: List.generate(
        _items.length,
        (index) => Builder(
          builder: (context) => widget.itemBuilder.call(
            context,
            _items[index],
            index,
          ),
        ),
      ),
    );
    if (widget.padding != null) {
      container = Padding(
        padding: widget.padding!,
        child: container,
      );
    }
    return container;
  }

  @override
  void dispose() {
    _selected
      ..removeListener(_selectedListener)
      ..dispose();
    super.dispose();
  }
}
