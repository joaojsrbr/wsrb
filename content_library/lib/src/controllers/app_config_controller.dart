import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:content_library/src/repository/app_config_repository.dart';
import 'package:flutter/material.dart';

class AppConfigController extends ChangeNotifier {
  final AppConfigService _appConfigService;

  AppConfigController(this._appConfigService) {
    _appConfigService.addNotifyListeners(notifyListeners);
  }

  AppConfigEntity get config => _appConfigService.config;

  @override
  void dispose() {
    _appConfigService.dispose();
    super.dispose();
  }

  AppConfigRepository get repo => _appConfigService.repo;

  Future<void> setOrderBy(OrderBy value) async {
    await _appConfigService.setOrderBy(value);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    await _appConfigService.setThemeMode(value);
  }

  Future<void> setAutoUpdateInterval(AutoUpdateInterval value) async {
    await _appConfigService.setAutoUpdateInterval(value);
  }

  Future<void> setSource(Source value) async {
    await _appConfigService.setSource(value);
  }

  Future<void> setReverseContents(bool value) async {
    await _appConfigService.setReverseContents(value);
  }

  Future<void> setFilterWatching(FilterWatching value) async {
    await _appConfigService.setFilterWatching(value);
  }
}
