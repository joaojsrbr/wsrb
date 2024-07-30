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
        final result = await Connectivity().checkConnectivity();
        _connectivityResult = result
            .where((connectivity) => connectivity != ConnectivityResult.vpn)
            .toList();
        _hasConnection = await InternetConnectionChecker().hasConnection;
        notifyListeners();
      }),
      Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> result) async {
        _connectivityResult = result
            .where((connectivity) => connectivity != ConnectivityResult.vpn)
            .toList();

        if (_connectivityResult.contains(ConnectivityResult.wifi) ||
            _connectivityResult.contains(ConnectivityResult.mobile)) {
          _hasConnection = await InternetConnectionChecker().hasConnection;
        } else {
          _hasConnection = false;
        }
        customLog(_connectivityResult);
        notifyListeners();
      }),
    ]);
  }

  bool _hasConnection = false;
  List<ConnectivityResult> _connectivityResult = [];

  bool get hasConnection => _hasConnection;
  List<ConnectivityResult> get connectivityResult => _connectivityResult;

  final Subscriptions _subscriptions = Subscriptions();

  Future<void> start() async {
    final result = await Connectivity().checkConnectivity();
    _connectivityResult = result
        .where((connectivity) => connectivity != ConnectivityResult.vpn)
        .toList();
    if (_connectivityResult.contains(ConnectivityResult.wifi) ||
        _connectivityResult.contains(ConnectivityResult.mobile)) {
      _hasConnection = await InternetConnectionChecker().hasConnection;
    } else {
      _hasConnection = false;
    }
  }

  @override
  void dispose() {
    _subscriptions.cancelAll();

    super.dispose();
  }
}
