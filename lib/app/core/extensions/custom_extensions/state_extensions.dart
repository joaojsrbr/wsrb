import 'package:flutter/material.dart';

extension StateExtension<S extends StatefulWidget> on State<S> {
  void setStateIfMounted(VoidCallback callback) {
    // ignore: invalid_use_of_protected_member
    if (mounted) setState(callback);
  }

  void ifMounted(VoidCallback callback) {
    if (mounted) callback.call();
  }

  void addPostFrameCallback(SetCallBack<Duration> callback) {
    WidgetsBinding.instance.addPostFrameCallback(callback);
  }
}

typedef SetCallBack<T> = void Function(T data);
