import 'package:content_library/content_library.dart';

import 'package:flutter/material.dart';

class ReadingViewArgs {
  final int currentIndex;

  final List<Release> releases;
  final Chapter chapter;
  final Book book;
  final CapturedThemes capturedThemes;

  const ReadingViewArgs({
    required this.currentIndex,
    required this.releases,
    required this.capturedThemes,
    required this.book,
    required this.chapter,
  });
}
