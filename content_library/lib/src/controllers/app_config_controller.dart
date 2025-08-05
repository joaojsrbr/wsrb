import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:content_library/src/repository/app_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class AppConfigController extends ChangeNotifier {
  late final AppConfigRepository _repository;
  final IsarServiceImpl _isarService;

  final Subscriptions _subscriptions = Subscriptions();

  final StreamController<AppConfigController> _updateController = StreamController.broadcast();
  Stream<AppConfigController> get update => _updateController.stream;

  AppConfigController(this._isarService) {
    _repository = AppConfigRepository();
  }

  final Debouncer _updateDebouncer = Debouncer(duration: const Duration(milliseconds: 200));

  AppConfigEntity get config => repo.config;

  @override
  void dispose() {
    _updateDebouncer.cancel();
    _subscriptions.cancelAll();
    super.dispose();
  }

  AppConfigRepository get repo => _repository;

  Future<void> _addConfig() async {
    _isarService.add(entity: repo.config);
  }

  Future<void> setOrderBy(OrderBy value) async {
    if (value == repo.config.orderBy) return;
    repo.updateConfig((config) => config.copyWith(orderBy: value));
    await _addConfig();
    _updateController.add(this);
  }

  Future<void> setSource(Source value) async {
    if (value == repo.config.source) return;
    repo.updateConfig((config) => config.copyWith(source: value));
    await _addConfig();
    _updateController.add(this);
  }

  Future<void> setBetterAnimeCookies(List<ContentCookie> values) async {
    repo.updateConfig((config) => config.copyWith(betterAnimeCookies: values));
    await _addConfig();
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
      _updateDebouncer.call(notifyListeners);
    }
  }
}
