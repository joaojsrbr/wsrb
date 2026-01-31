import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:content_library/src/repository/app_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class AppConfigService {
  late final AppConfigRepository _repository;
  final IsarServiceImpl _isarService;

  final Subscriptions _subscriptions = Subscriptions();

  final StreamController<AppConfigService> _updateRepositoryController =
      StreamController.broadcast();

  Stream<AppConfigService> get updateRepository => _updateRepositoryController.stream;

  AppConfigService(this._isarService, [bool setWorkManage = true]) {
    _repository = AppConfigRepository();
    if (setWorkManage) _setWorkManage();
  }

  final List<Function> _update = [];

  void addNotifyListeners(VoidCallback func) {
    _update.add(func);
  }

  void _notifyListeners() {
    for (var a in _update) {
      a();
    }
  }

  final Debouncer _updateRepositoryDebouncer = Debouncer(
    duration: const Duration(milliseconds: 200),
  );

  AppConfigEntity get config => repo.config;

  void dispose() {
    _updateRepositoryDebouncer.cancel();
    _subscriptions.cancelAll();
    _updateRepositoryController.close();
  }

  AppConfigRepository get repo => _repository;

  Future<void> _addConfig() async {
    _isarService.add(entity: repo.config);
  }

  Future<void> setOrderBy(OrderBy value) async {
    if (value == repo.config.orderBy) return;
    repo.updateConfig((config) => config.copyWith(orderBy: value));
    await _addConfig();
    _updateRepositoryController.add(this);
  }

  Future<void> setAutoUpdateInterval(AutoUpdateInterval value) async {
    if (value == repo.config.autoUpdateInterval) return;
    repo.updateConfig((config) => config.copyWith(autoUpdateInterval: value));
    await _addConfig();
    _setWorkManage();
  }

  Future<void> setSource(Source value) async {
    if (value == repo.config.source) return;
    repo.updateConfig((config) => config.copyWith(source: value));
    await _addConfig();
    _updateRepositoryController.add(this);
  }

  Future<void> setReverseContents(bool value) async {
    if (value == repo.config.reverseContents) return;
    repo.updateConfig((config) => config.copyWith(reverseContents: value));
    await _addConfig();
  }

  Future<void> setFilterWatching(FilterWatching value) async {
    repo.updateConfig((config) => config.copyWith(filterWatching: value));
    await _addConfig();
  }

  Future<void> start() async {
    final configCollection = await _isarService.collection<AppConfigEntity>();

    final config = await configCollection.where().findAll();

    if (config.isEmpty) {
      _isarService.add(entity: AppConfigEntity.init());
    } else {
      repo.updateConfig((_) => config.first);
    }

    _subscriptions.addAll([configCollection.watchLazy().listen(_updateConfig)]);
  }

  void _updateConfig(data) async {
    final configCollection = await _isarService.collection<AppConfigEntity>();
    final config = await configCollection.where().findAll();

    if (config.isNotEmpty) {
      repo.updateConfig((_) => config.first);
      _updateRepositoryDebouncer.call(_notifyListeners);
    }
  }

  void _setWorkManage() async {
    final config = repo.config;

    final intervalDuration = config.autoUpdateInterval.intervalDuration;

    await Workmanager().cancelByTag(App.APP_WORK_NEW_RELEASE);

    if (intervalDuration == Duration.zero) return;

    Workmanager().registerPeriodicTask(
      UniqueKey().toString(),
      App.APP_WORK_NEW_RELEASE,
      tag: App.APP_WORK_NEW_RELEASE,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      frequency: intervalDuration,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }
}
