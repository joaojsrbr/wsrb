// ignore_for_file: library_private_types_in_public_api, constant_identifier_names, unused_field

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
    required this.allDataContent,
  });

  final bool isLoading;
  final Content content;
  final void Function(int index) setListIndex;
  final int index;

  final List<List<DataContent>> allDataContent;

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

  static List<List<DataContent>> allDataContentOf(BuildContext context) =>
      _of(context, _BookInformationScopeAspect.ALLDATACONTENTS).allDataContent;

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
              when !listEquals(_allDataContent, oldWidget._allDataContent):
            // if (!listEquals(_chapters, _chapters) &&
            //     listChapterIndex == oldWidget.listChapterIndex) return true;
            return true;
          default:
            return true;
        }
      }
    }

    return false;
  }

  List<DataContent> get _allDataContent {
    final List<DataContent> lista = [];

    for (final content in allDataContent) {
      lista.addAll(content);
    }

    return lista;
  }

  @override
  bool updateShouldNotify(BookInformationScope oldWidget) {
    return isLoading != oldWidget.isLoading ||
        content != oldWidget.content ||
        index != oldWidget.index ||
        !listEquals(_allDataContent, oldWidget._allDataContent);
  }
}
