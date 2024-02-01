import 'package:flutter/material.dart';

class OpenContainerController extends ChangeNotifier {
  bool _active = false;
  bool _disable = false;

  set activeOpenContainer(bool active) {
    if (_active == active) return;
    _active = active;
    notifyListeners();
  }

  set disableOpenContainer(bool disable) {
    if (_disable == disable) return;
    _disable = disable;
    notifyListeners();
  }

  bool get isActive => _active;
  bool get isDisable => _disable;
}
