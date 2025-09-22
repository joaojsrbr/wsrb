import 'dart:async';

import 'fade_through_transition_switcher.dart';
import '../../../utils/anchor.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

/// A custom dropdown menu button with fade-through transition between two visual states.
class DropdownMenuButton<T> extends StatelessWidget {
  final void Function(T data)? onSelected;
  final Widget? child;
  final bool enableSecondChild;
  final List<T> items;
  final bool Function(T data)? itemEnabled;
  final Widget Function(T data)? itemLeading;

  const DropdownMenuButton({
    super.key,
    required this.onSelected,
    required this.child,
    this.itemEnabled,
    this.itemLeading,
    this.enableSecondChild = false,
    required this.items,
  });

  bool get _isDisabled => items.length <= 1;

  @override
  Widget build(BuildContext context) {
    return FadeThroughTransitionSwitcher(
      duration: const Duration(milliseconds: 350),
      enableSecondChild: enableSecondChild,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140, maxHeight: 38),
          child: FilledButton(
            style: FilledButton.styleFrom(
              disabledIconColor: Colors.white,
              disabledBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isDisabled ? null : () => _showDropdownMenu(context),
            child: child,
          ),
        ),
      ),
    );
  }

  Future<void> _showDropdownMenu(BuildContext context) async {
    final anchor = Anchor();
    final timer = anchor.autoPopAfterDelay(const Duration(seconds: 10));

    final buttonBox = context.findRenderObject();
    final overlayBox = Navigator.of(context).overlay?.context.findRenderObject();

    if (buttonBox is RenderBox && overlayBox is RenderBox) {
      final size = buttonBox.size;
      final buttonTopLeft = buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);

      final left = buttonTopLeft.dx + 10;
      final top = buttonTopLeft.dy + size.height;

      final position = RelativeRect.fromLTRB(
        left,
        top,
        overlayBox.size.width - left,
        overlayBox.size.height - top,
      );

      final result = await showMenu<T>(
        context: context,
        position: position,
        menuPadding: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        // 👇 chave: menu com a MESMA largura do botão
        constraints: BoxConstraints.tightFor(width: size.width),
        items: items.mapIndexed((index, e) {
          return PopupMenuItem<T>(
            key: index == 0 ? anchor : null,
            value: e,
            enabled: itemEnabled?.call(e) ?? true,
            child: ListTile(leading: itemLeading?.call(e), title: Text(e.toString())),
          );
        }).toList(),
      );

      timer.cancel();
      if (result != null) onSelected?.call(result);
    }
  }
}
