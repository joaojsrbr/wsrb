import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_dismissible.dart'
    as customdismissible;
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

class ListDismissible<T extends Release> extends StatelessWidget {
  const ListDismissible({
    super.key,
    required this.releases,
    this.selected,
    this.physics,
    this.onUpdate,
    this.padding,
    this.isSliver = false,
    this.titleTextStyle,
    this.resizeDuration = const Duration(milliseconds: 700),
    this.onTap,
  });
  final TextStyle? titleTextStyle;
  final Releases releases;
  final bool Function(Release content)? selected;
  final ScrollPhysics? physics;
  final bool isSliver;
  final Duration resizeDuration;
  final ValueChanged<T>? onTap;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<customdismissible.DismissUpdateDetails>? onUpdate;

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(BuildContext context, int index) {
      final content = releases[index];

      return customdismissible.CustomDismissible(
        onUpdate: onUpdate,
        dismissThresholds: const {
          DismissDirection.endToStart: 0.5,
          DismissDirection.startToEnd: 0.5
        },
        resizeDuration: resizeDuration,
        background: Container(
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(color: Colors.blueAccent),
          padding: const EdgeInsets.only(left: 20.0),
          child: const Icon(Icons.check, color: Colors.white),
        ),
        radius: 20,
        secondaryBackground: Container(
          decoration: const BoxDecoration(color: Colors.redAccent),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        key: ValueKey(content.id),
        onTap: selected != null
            ? (selected?.call(content) ?? true)
                ? null
                : () => onTap?.call(content as T)
            : () => onTap?.call(content as T),
        child: ListTile(
          selected: selected?.call(content) ?? false,
          titleTextStyle: titleTextStyle,
          title: Text(content.title),
        ),
      );
    }

    if (isSliver) {
      return SliverList.builder(
        itemBuilder: itemBuilder,
        itemCount: releases.length,
      );
    }

    return ListView.builder(
      physics: physics,
      padding: padding,
      itemCount: releases.length,
      itemBuilder: itemBuilder,
    );
  }
}
