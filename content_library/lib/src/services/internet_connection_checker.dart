import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionChecker extends ChangeNotifier {
  late final InternetConnectionChecker _internetConnectionChecker;

  ConnectionChecker() {
    _internetConnectionChecker = InternetConnectionChecker.createInstance();
    _subscriptions.addAll([
      _internetConnectionChecker.onStatusChange.listen((status) async {
        switch (status) {
          case InternetConnectionStatus.connected:
            _connectivityResult = [ConnectivityResult.wifi];
            break;
          case InternetConnectionStatus.disconnected:
            _connectivityResult = [ConnectivityResult.none];
            break;
        }
        _hasConnection = await InternetConnectionChecker().hasConnection;
        notifyListeners();
      }),
      Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> result) async {
        _connectivityResult = result;
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
  List<ConnectivityResult> _connectivityResult = [ConnectivityResult.none];

  bool get hasConnection => _hasConnection;
  List<ConnectivityResult> get connectivityResult => _connectivityResult;

  final Subscriptions _subscriptions = Subscriptions();

  Future<void> start() async {
    final result = await Connectivity().checkConnectivity();
    _connectivityResult = result;
    if (result.contains(ConnectivityResult.vpn) &&
        !result.contains(ConnectivityResult.wifi)) {
      _hasConnection = !(await InternetConnectionChecker().hasConnection);
    } else {
      _hasConnection = await InternetConnectionChecker().hasConnection;
    }
  }

  @override
  void dispose() {
    _subscriptions.cancelAll();

    super.dispose();
  }
}
