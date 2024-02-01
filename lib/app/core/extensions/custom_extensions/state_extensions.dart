import 'package:flutter/material.dart';

extension StateExtension<S extends StatefulWidget> on State<S> {
  void setStateIfMounted(VoidCallback callback) {
    // ignore: invalid_use_of_protected_member
    if (mounted) setState(callback);
  }

  void ifMounted(VoidCallback callback) {
    if (mounted) callback.call();
  }

  void addPostFrameCallback(SetCallback<Duration> callback) {
    WidgetsBinding.instance.addPostFrameCallback(callback);
  }
}

typedef SetCallback<T> = void Function(T data);
