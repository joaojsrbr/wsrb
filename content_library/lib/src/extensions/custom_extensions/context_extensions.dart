import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  void unFocusKeyBoard() {
    final FocusScopeNode currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.focusedChild?.unfocus();
    }
  }
}
