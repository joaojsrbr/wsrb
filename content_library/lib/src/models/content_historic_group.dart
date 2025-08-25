import 'dart:collection';

import 'package:content_library/content_library.dart';

class ContentHistoricGroup {
  final Set<ContentEntity> contents;
  final SplayTreeSet<HistoricEntity> historics;

  const ContentHistoricGroup({required this.contents, required this.historics});
}
