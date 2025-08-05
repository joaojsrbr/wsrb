import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:flutter/material.dart';

class MenuButton<T> extends StatelessWidget {
  final void Function(T data)? onTap;
  final Widget? child;
  final bool enableSecondChild;
  final List<T> data;
  final bool Function(T data)? enableMenuItem;
  final Widget Function(T data)? leadingMenuItem;

  const MenuButton({
    super.key,
    required this.onTap,
    required this.child,
    this.enableMenuItem,
    this.leadingMenuItem,
    this.enableSecondChild = false,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return FadeThroughTransitionSwitcher(
      duration: const Duration(milliseconds: 350),
      enableSecondChild: enableSecondChild,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140, maxHeight: 38),
          child: Builder(
            builder: (context) {
              return FilledButton(
                style: FilledButton.styleFrom(
                  disabledIconColor: Colors.white,
                  disabledBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: (data.length == 1)
                    ? null
                    : () async {
                        final timer = Timer(
                          const Duration(seconds: 10),
                          Navigator.of(context).pop,
                        );

                        final RenderBox? button =
                            context.findRenderObject() as RenderBox?;

                        final RenderBox? overlay =
                            Navigator.of(context).overlay?.context.findRenderObject()
                                as RenderBox?;
                        if (overlay != null && button != null) {
                          final size = button.size;

                          final RelativeRect position = RelativeRect.fromRect(
                            Rect.fromPoints(
                              button.localToGlobal(size.bottomLeft(Offset.zero)),
                              button.localToGlobal(size.bottomLeft(Offset.zero)),
                            ),
                            Offset(size.width > 100 ? -5 : size.width, -5) & overlay.size,
                          );

                          final result = await showMenu(
                            context: context,
                            position: position,
                            clipBehavior: Clip.hardEdge,
                            items: data
                                .map(
                                  (e) => PopupMenuItem(
                                    value: e,
                                    enabled: enableMenuItem?.call(e) ?? true,
                                    child: ListTile(
                                      leading: leadingMenuItem?.call(e),
                                      title: Text(e.toString()),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                          timer.cancel();
                          if (result != null) {
                            onTap?.call(result);
                          }
                        }
                      },
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}
