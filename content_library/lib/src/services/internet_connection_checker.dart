import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionChecker extends ChangeNotifier {
  ConnectionChecker() {
    _subscriptions.addAll([
      InternetConnectionChecker().onStatusChange.listen((status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            _hasConnection = true;
            break;
          case InternetConnectionStatus.disconnected:
            _hasConnection = false;
            break;
        }
      })
    ]);
  }

  bool _hasConnection = false;

  bool get hasConnection => _hasConnection;

  final Subscriptions _subscriptions = Subscriptions();

  Future<void> start() async {
    _hasConnection = await InternetConnectionChecker().hasConnection;
  }

  @override
  void dispose() {
    _subscriptions.dispose();
    super.dispose();
  }
}
