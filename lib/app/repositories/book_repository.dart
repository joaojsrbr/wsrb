import 'dart:async';

import 'package:app_wsrb_jsr/app/core/constants/app.dart';
import 'package:app_wsrb_jsr/app/core/constants/source.dart';
import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/string_extensions.dart';
import 'package:app_wsrb_jsr/app/core/services/dio_client.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_controller.dart';
import 'package:app_wsrb_jsr/app/core/services/jikan.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/models/data_content.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:app_wsrb_jsr/app/utils/result.dart';
import 'package:app_wsrb_jsr/app/utils/scraping.util.dart';
import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/models/chapter.dart';
import 'package:app_wsrb_jsr/app/models/data.dart';
import 'package:app_wsrb_jsr/app/models/genre.dart';
import 'package:app_wsrb_jsr/app/repositories/source/source.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' as ui;

import 'package:hive/hive.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'package:loading_more_list/loading_more_list.dart';

part 'source/neox_source.dart';

abstract class BookRepository extends LoadingMoreBase<Content> {
  int index = 0;
  bool isSuccess = false;
  // ignore: prefer_final_fields
  bool _hasMore = true;
  bool forceRefresh = false;

  late final DioClient _dio;
  late final JikanService _jikanService;
  late final List<StreamSubscription>? _subs;
  late final List<RSource> _sources;

  final HiveController _hiveController;

  // late final BookRepositoryController controller;

  BookRepository._internal(this._hiveController) {
    _dio = DioClient();
    _jikanService = JikanService();
    _sources = [
      NeoxSource(this),
    ];
    _subs = [
      _hiveController.watchBy('repository_order_by').listen(_listen),
      _hiveController.watchBy('repository_source').listen(_listen),
    ];
  }

  void _listen(BoxEvent event) {
    ui.WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => refresh(true),
    );
  }

  bool get addMore => isSuccess && _hasMore;

  factory BookRepository(HiveController hiveController) =>
      _BookRepositoryImp(hiveController);

  factory BookRepository.isolate(HiveController hiveController) =>
      _BookRepositoryImp(hiveController);

  RSource get source => _sources.firstWhere(
        (source) => source.source == _hiveController.source,
      );

  Future<Result<Content>> getData(Content content);

  Future<Result<List<Data>>> getContent(DataContent dataContent);

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    index = source.initialIndex;
    isSuccess = false;
    _hasMore = false;
    forceRefresh = notifyStateChanged;
    bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
    // if (notifyStateChanged) {
    //   forceRefresh = true;
    //   result = await super.refresh( notifyStateChanged);
    // } else {
    //   forceRefresh = false;
    //   result = await super.refresh( notifyStateChanged);
    // }
    // forceRefresh = false;
    // return Future.value(result);
  }

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  void dispose() {
    for (final sub in _subs ?? []) {
      sub.cancel();
    }

    super.dispose();
  }
}

class _BookRepositoryImp extends BookRepository {
  _BookRepositoryImp(super._hiveController) : super._internal() {
    ui.WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => refresh(true));
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async =>
      await source.loadData();

  @override
  Future<Result<Content>> getData(Content content) async =>
      await source.getData(content);

  @override
  Future<Result<List<Data>>> getContent(DataContent dataContent) async =>
      await source.getContent(dataContent);
}

// class BookRepositoryController extends ChangeNotifier {}
