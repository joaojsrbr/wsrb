// ignore_for_file: library_private_types_in_public_api, constant_identifier_names, unused_field

import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/models/chapter.dart';

import 'package:flutter/widgets.dart';

enum _BookInformationScopeAspect {
  ISLOADING,
  LISTCHAPTERINDEX,
  CHAPTERS,
  BOOK,
}

class BookInformationScope extends InheritedModel<_BookInformationScopeAspect> {
  const BookInformationScope({
    super.key,
    required super.child,
    required this.isLoading,
    required this.index,
    required this.setListIndex,
    required this.book,
    required this.chaptersOrders,
    required this.chapters,
  });

  final bool isLoading;
  final Book book;
  final bool chaptersOrders;
  final void Function(int index) setListIndex;
  final int index;

  final List<List<Chapter>> chapters;

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

  static List<List<Chapter>> chaptersOf(BuildContext context) =>
      _of(context, _BookInformationScopeAspect.CHAPTERS).chapters;

  static Book bookOf(BuildContext context) =>
      _of(context, _BookInformationScopeAspect.BOOK).book;

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
          case _BookInformationScopeAspect.BOOK when book != oldWidget.book:
            return true;
          case _BookInformationScopeAspect.LISTCHAPTERINDEX
              when index != oldWidget.index:
            return true;
          case _BookInformationScopeAspect.CHAPTERS
              when _chapters.length != oldWidget._chapters.length ||
                  chaptersOrders != oldWidget.chaptersOrders:
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

  List<Chapter> get _chapters {
    final List<Chapter> lista = [];

    for (final chapter in chapters) {
      lista.addAll(chapter);
    }

    return lista;
  }

  @override
  bool updateShouldNotify(BookInformationScope oldWidget) {
    return isLoading != oldWidget.isLoading ||
        chaptersOrders != oldWidget.chaptersOrders ||
        book != oldWidget.book ||
        index != oldWidget.index ||
        _chapters.length != oldWidget._chapters.length;
  }
}
