import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/models/chapter.dart';
import 'package:app_wsrb_jsr/app/models/data_content.dart';
import 'package:flutter/material.dart';

class ReadingViewArgs {
  final int currentIndex;

  final List<DataContent> allDataContent;
  final Chapter chapter;
  final Book book;
  final ThemeData bookThemeData;

  const ReadingViewArgs({
    required this.currentIndex,
    required this.allDataContent,
    required this.bookThemeData,
    required this.book,
    required this.chapter,
  });
}
