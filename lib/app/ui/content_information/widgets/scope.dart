// ignore_for_file: library_private_types_in_public_api, constant_identifier_names, unused_field

import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/models/data_content.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/widgets.dart';

enum _BookInformationScopeAspect {
  ISLOADING,
  LISTCHAPTERINDEX,
  ALLDATACONTENTS,
  CONTENT,
}

class BookInformationScope extends InheritedModel<_BookInformationScopeAspect> {
  const BookInformationScope({
    super.key,
    required super.child,
    required this.isLoading,
    required this.index,
    required this.setListIndex,
    required this.content,
    required this.contentOrders,
    required this.dataContents,
  });

  final bool isLoading;
  final bool contentOrders;
  final Content content;
  final SetCallBack<int> setListIndex;
  final int index;

  final List<List<DataContent>> dataContents;

  static BookInformationScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BookInformationScope>()!;
  }

  static BookInformationScope _of(BuildContext context,
      [_BookInformationScopeAspect? aspect]) {
    assert(debugCheckHasMediaQuery(context));
    return InheritedModel.inheritFrom<BookInformationScope>(context,
        aspect: aspect)!;
  }

  static bool isLoadingOf(BuildContext context) =>
      _of(context, _BookInformationScopeAspect.ISLOADING).isLoading;

  static List<List<DataContent>> dataContentsOf(BuildContext context) =>
      _of(context, _BookInformationScopeAspect.ALLDATACONTENTS).dataContents;

  static Content contentOf(BuildContext context) =>
      _of(context, _BookInformationScopeAspect.CONTENT).content;

  static int indexOf(BuildContext context) =>
      _of(context, _BookInformationScopeAspect.LISTCHAPTERINDEX).index;

  @override
  bool updateShouldNotifyDependent(BookInformationScope oldWidget,
      Set<_BookInformationScopeAspect> dependencies) {
    for (final Object dependency in dependencies) {
      if (dependency is _BookInformationScopeAspect) {
        switch (dependency) {
          case _BookInformationScopeAspect.ISLOADING
              when isLoading != oldWidget.isLoading:
            return true;
          case _BookInformationScopeAspect.CONTENT
              when content != oldWidget.content:
            return true;
          case _BookInformationScopeAspect.LISTCHAPTERINDEX
              when index != oldWidget.index:
            return true;
          case _BookInformationScopeAspect.ALLDATACONTENTS
              when !listEquals(_dataContents, oldWidget._dataContents) ||
                  contentOrders != oldWidget.contentOrders:
            return true;
          default:
            return true;
        }
      }
    }

    return false;
  }

  List<DataContent> get _dataContents {
    final List<DataContent> lista = [];

    for (final content in dataContents) {
      lista.addAll(content);
    }

    lista.sort();

    return lista;
  }

  @override
  bool updateShouldNotify(BookInformationScope oldWidget) {
    return isLoading != oldWidget.isLoading ||
        content != oldWidget.content ||
        index != oldWidget.index ||
        contentOrders != oldWidget.contentOrders ||
        !listEquals(_dataContents, oldWidget._dataContents);
  }
}
