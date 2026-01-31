import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControllerBundle {
  late final LibraryController libraryController;
  late final HistoricController historicController;
  ControllerBundle(BuildContext context) {
    libraryController = context.read<LibraryController>();
    historicController = context.read<HistoricController>();
  }
}
