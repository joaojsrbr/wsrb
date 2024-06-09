import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionChecker extends ChangeNotifier {
  late final InternetConnectionChecker _internetConnectionChecker;

  ConnectionChecker() {
    _internetConnectionChecker = InternetConnectionChecker.createInstance();
    _subscriptions.addAll([
      _internetConnectionChecker.onStatusChange.listen((status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            _hasConnection = true;
            break;
          case InternetConnectionStatus.disconnected:
            _hasConnection = false;
            break;
        }
        notifyListeners();
      }),
      Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> result) async {
        if (result.contains(ConnectivityResult.vpn) &&
            !result.contains(ConnectivityResult.wifi)) {
          _hasConnection = !(await InternetConnectionChecker().hasConnection);
        } else {
          _hasConnection = await InternetConnectionChecker().hasConnection;
        }

        notifyListeners();
      }),
    ]);
  }

  bool _hasConnection = false;

  bool get hasConnection => _hasConnection;

  final Subscriptions _subscriptions = Subscriptions();

  Future<void> start() async {
    final result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.vpn) &&
        !result.contains(ConnectivityResult.wifi)) {
      _hasConnection = !(await InternetConnectionChecker().hasConnection);
    } else {
      _hasConnection = await InternetConnectionChecker().hasConnection;
    }
  }

  @override
  void dispose() {
    _subscriptions.dispose();
    super.dispose();
  }
}
