import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:content_library/src/utils/elapsed.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../constants/order.dart';
import '../../constants/source.dart';
import '../../interfaces/hive_service.dart';
import 'hive_service.dart';

class HiveController extends ChangeNotifier {
  final HiveService _hiveService;

  HiveController(this._hiveService);

  late OrderBy _orderBy;
  late bool _reverseContents;
  late Source _source;
  late ConnectivityResult _connectivityResult;
  late double _historicSavePercent;

  static const _defaultValueOrderBy =
      HiveDefaultValue('repository_order_by', OrderBy.LATEST);
  static const _defaultValueSource =
      HiveDefaultValue('repository_source', Source.ANROLL);
  static const _defaultValueReverseContent =
      HiveDefaultValue('bookInfo_reverse_contents', true);
  static const _defaultValueConnectivityResult =
      HiveDefaultValue('connectivity_result', ConnectivityResult.none);
  static const _defaultValueHistoricSavePercent =
      HiveDefaultValue('historico_save_percent', 0.00);

  bool get reverseContents => _reverseContents;
  ConnectivityResult get connectivityResult => _connectivityResult;
  OrderBy get orderBy => _orderBy;
  double get historicSavePercent => _historicSavePercent;
  Source get source => _source;

  Stream<BoxEvent> watchBy(String key) => _hiveService.watchBy(key);

  Future<void> setOrderBy(OrderBy? value, [bool notify = true]) async {
    if (value == null || value == _orderBy) return;
    _orderBy = value;
    if (notify) notifyListeners();

    await _hiveService.save(_defaultValueOrderBy.key, value);
  }

  Future<void> setSource(Source? value, [bool notify = true]) async {
    if (value == null || value == _source) return;
    _source = value;
    if (notify) notifyListeners();

    await _hiveService.save(_defaultValueSource.key, value);
  }

  Future<void> setReverseContents(bool? value, [bool notify = true]) async {
    if (value == null || value == _reverseContents) return;
    _reverseContents = value;
    if (notify) notifyListeners();

    await _hiveService.save(_defaultValueReverseContent.key, value);
  }

  Future<void> setConnectivityResult(ConnectivityResult? value,
      [bool notify = true]) async {
    if (value == null || value == _connectivityResult) return;
    _connectivityResult = value;
    if (notify) notifyListeners();

    await _hiveService.save(_defaultValueConnectivityResult.key, value);
  }

  Future<void> setHistoricSavePercent(double? value,
      [bool notify = true]) async {
    if (value == null || value == _historicSavePercent) return;
    _historicSavePercent = value;
    if (notify) notifyListeners();

    await _hiveService.save(_defaultValueHistoricSavePercent.key, value);
  }

  Future<void> loadAll() async {
    final Elapsed elapsed = Elapsed()..start();

    final result = await Future.wait([
      _hiveService.load(
        _defaultValueReverseContent.key,
        _defaultValueReverseContent.defaultValue,
      ),
      _hiveService.load(
        _defaultValueOrderBy.key,
        _defaultValueOrderBy.defaultValue,
      ),
      _hiveService.load(
        _defaultValueSource.key,
        _defaultValueSource.defaultValue,
      ),
      _hiveService.load(
        _defaultValueConnectivityResult.key,
        _defaultValueConnectivityResult.defaultValue,
      ),
      _hiveService.load(
        _defaultValueHistoricSavePercent.key,
        _defaultValueHistoricSavePercent.defaultValue,
      ),
    ]);

    _reverseContents = result.getElementAt<bool>(0);
    _orderBy = result.getElementAt<OrderBy>(1);
    _source = result.getElementAt<Source>(2);
    _connectivityResult = result.getElementAt<ConnectivityResult>(3);
    _historicSavePercent = result.getElementAt<double>(4);
    elapsed.printAndStop(runtimeType.toString());
  }
}

extension on List<Object> {
  T getElementAt<T>(int index) => this[index] as T;
}
