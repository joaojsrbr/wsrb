import 'package:app_wsrb_jsr/app/core/constants/order.dart';
import 'package:app_wsrb_jsr/app/core/constants/source.dart';
import 'package:app_wsrb_jsr/app/core/interfaces/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HiveController extends ChangeNotifier {
  final HiveService _hiveService;

  HiveController(this._hiveService);

  late OrderBy _orderBy;
  late bool _contentOrders;
  late bool _pageOrders;
  late Source _source;

  static const _defaultValueOrderBy = OrderBy.LATEST;
  static const _defaultValueSource = Source.NEOX_SCANS;
  static const _defaultValueContentOrders = false;
  static const _defaultValuePageOrders = true;

  bool get contentOrders => _contentOrders;
  bool get pageOrders => _pageOrders;
  OrderBy get orderBy => _orderBy;
  Source get source => _source;

  // String _byType<T>() {
  //   return _hiveKeys.entries.firstWhere((element) => element.key == T).value;
  // }

  Stream<BoxEvent> watchBy(String key) => _hiveService.watchBy(key);

  Future<void> setOrderBy(OrderBy? value, [bool notify = true]) async {
    if (value == null || value == _orderBy) return;
    _orderBy = value;
    if (notify) notifyListeners();

    await _hiveService.save('repository_order_by', value);
  }

  Future<void> setSource(Source? value, [bool notify = true]) async {
    if (value == null || value == _source) return;
    _source = value;
    if (notify) notifyListeners();

    await _hiveService.save('repository_source', value);
  }

  Future<void> setChaptersOrders(bool? value, [bool notify = true]) async {
    if (value == null || value == _contentOrders) return;
    _contentOrders = value;
    if (notify) notifyListeners();

    await _hiveService.save('book_info_content_orders', value);
  }

  Future<void> setPageOrders(bool? value, [bool notify = true]) async {
    if (value == null || value == _pageOrders) return;
    _pageOrders = value;
    if (notify) notifyListeners();

    await _hiveService.save('book_info_page_order', value);
  }

  Future<void> loadAll() async {
    final result = await Future.wait([
      _hiveService.load(
        'book_info_page_order',
        _defaultValuePageOrders,
      ),
      _hiveService.load(
        'book_info_content_orders',
        _defaultValueContentOrders,
      ),
      _hiveService.load(
        'repository_order_by',
        _defaultValueOrderBy,
      ),
      _hiveService.load(
        'repository_source',
        _defaultValueSource,
      ),
    ]);

    _pageOrders = result.elementAt(0) as bool;
    _contentOrders = result.elementAt(1) as bool;
    _orderBy = result.elementAt(2) as OrderBy;
    _source = result.elementAt(3) as Source;
  }
}
