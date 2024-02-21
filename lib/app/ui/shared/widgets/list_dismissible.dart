import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/models/data_content.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/dismissible.dart'
    as customdismissible;
import 'package:flutter/material.dart';

class ListDismissible<T extends DataContent> extends StatelessWidget {
  const ListDismissible({
    super.key,
    required this.contents,
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
  final DataContents contents;
  final bool Function(DataContent content)? selected;
  final ScrollPhysics? physics;
  final bool isSliver;
  final Duration resizeDuration;
  final SetCallBack<T>? onTap;
  final EdgeInsetsGeometry? padding;
  final SetCallBack<customdismissible.DismissUpdateDetails>? onUpdate;

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(BuildContext context, int index) {
      final content = contents[index];

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
        itemCount: contents.length,
      );
    }

    return ListView.builder(
      physics: physics,
      padding: padding,
      itemCount: contents.length,
      itemBuilder: itemBuilder,
    );
  }
}
