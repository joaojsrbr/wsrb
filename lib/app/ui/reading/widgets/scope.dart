// ignore_for_file: unused_field, constant_identifier_names, unused_element, library_private_types_in_public_api

import 'package:content_library/content_library.dart';

import 'package:app_wsrb_jsr/app/ui/reading/arguments/reading_args.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:positioned_scroll_observer/positioned_scroll_observer.dart';

class ReaderController extends ScrollController {
  ScrollExtent get scrollExtent => ScrollExtent.fromPosition(position);

  double get pixels {
    if (!position.hasContentDimensions) return 0.0;
    double pixels;

    pixels = position.pixels;
    // customLog(pixels);
    return pixels;
  }

  double get lastPixels {
    if (!hasClients) return 0.0;
    return position.maxScrollExtent;
  }

  double get percent {
    double percent = (pixels / lastPixels);

    if (percent.isNegative) percent = (1 - -percent);

    return percent;
  }
}

enum _ReadingScopeAspect {
  READING_BOOK,
  READING_CHAPTER,
  READING_CONTENTS,
  READING_FOOTERWIDGET,
}

class ReadingScope extends InheritedModel<_ReadingScopeAspect> {
  const ReadingScope({
    super.key,
    required super.child,
    required this.book,
    required this.chapter,
    required this.readerController,
    required this.contents,
    required this.showFooterWidget,
    required this.observer,
    required this.onNotification,
    required this.onDoubleTapDown,
  });

  final BoxScrollObserver<RenderObject> observer;

  final bool Function(ScrollNotification) onNotification;
  final Book? book;
  final bool showFooterWidget;
  final ReaderController readerController;
  final void Function(BuildContext context, TapDownDetails details)
      onDoubleTapDown;
  final List<Widget> contents;
  final Chapter? chapter;

  static ReadingScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ReadingScope>()!;
  }

  static ReadingScope _of(BuildContext context, [_ReadingScopeAspect? aspect]) {
    assert(debugCheckHasMediaQuery(context));
    return InheritedModel.inheritFrom<ReadingScope>(context, aspect: aspect)!;
  }

  static Book bookOf(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ReadingViewArgs;
    final book = _of(context, _ReadingScopeAspect.READING_BOOK).book;
    return book ?? args.book;
  }

  static List<Widget> contentsOf(BuildContext context) {
    final contents =
        _of(context, _ReadingScopeAspect.READING_CONTENTS).contents;
    return contents;
  }

  static bool showFooterWidgetOf(BuildContext context) {
    final data = _of(
      context,
      _ReadingScopeAspect.READING_FOOTERWIDGET,
    ).showFooterWidget;
    return data;
  }

  static Chapter chapterOf(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ReadingViewArgs;

    final chapter = _of(context, _ReadingScopeAspect.READING_CHAPTER).chapter;
    return chapter ?? args.chapter;
  }

  @override
  bool updateShouldNotifyDependent(
      ReadingScope oldWidget, Set<_ReadingScopeAspect> dependencies) {
    for (final Object dependency in dependencies) {
      if (dependency is _ReadingScopeAspect) {
        switch (dependency) {
          case _ReadingScopeAspect.READING_BOOK when book != oldWidget.book:
            return true;
          case _ReadingScopeAspect.READING_CHAPTER
              when chapter != oldWidget.chapter:
            return true;
          case _ReadingScopeAspect.READING_FOOTERWIDGET
              when showFooterWidget != oldWidget.showFooterWidget:
            return true;
          case _ReadingScopeAspect.READING_CONTENTS
              when !listEquals(contents, oldWidget.contents):
            return true;
          default:
            return true;
        }
      }
    }

    return false;
  }

  @override
  bool updateShouldNotify(covariant ReadingScope oldWidget) {
    return oldWidget.book != book ||
        oldWidget.chapter != chapter ||
        oldWidget.showFooterWidget != showFooterWidget ||
        !listEquals(contents, oldWidget.contents);
  }
}
