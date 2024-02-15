import 'dart:async';
import 'dart:convert';

import 'package:app_wsrb_jsr/app/core/constants/app.dart';
import 'package:app_wsrb_jsr/app/core/constants/source.dart';
import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/string_extensions.dart';
import 'package:app_wsrb_jsr/app/core/services/dio_client.dart';
import 'package:app_wsrb_jsr/app/core/services/hive/hive_controller.dart';
import 'package:app_wsrb_jsr/app/core/services/jikan.dart';
import 'package:app_wsrb_jsr/app/models/anime.dart';
import 'package:app_wsrb_jsr/app/models/content.dart';
import 'package:app_wsrb_jsr/app/models/data_content.dart';
import 'package:app_wsrb_jsr/app/models/episode.dart';
import 'package:app_wsrb_jsr/app/utils/custom_log.dart';
import 'package:app_wsrb_jsr/app/utils/result.dart';
import 'package:app_wsrb_jsr/app/utils/scraping.util.dart';
import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/models/chapter.dart';
import 'package:app_wsrb_jsr/app/models/data.dart';
import 'package:app_wsrb_jsr/app/models/genre.dart';
import 'package:app_wsrb_jsr/app/repositories/source/source.dart';
import 'package:app_wsrb_jsr/app/utils/subscriptions.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as ui;

import 'package:hive/hive.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'package:loading_more_list/loading_more_list.dart';

part 'source/neox_source.dart';
part 'source/anroll_source.dart';

abstract class ContentRepository extends LoadingMoreBase<Content> {
  int index = 0;
  bool isSuccess = false;
  bool _hasMore = true;
  bool forceRefresh = false;

  late final DioClient _dio;
  late final JikanService _jikanService;
  late final Subscriptions _subscriptions;
  late final List<RSource> _sources;
  late final DeepCollectionEquality _deepCollectionEquality;
  final HiveController _hiveController;

  ContentRepository._internal(this._hiveController) {
    _deepCollectionEquality = const DeepCollectionEquality();
    _dio = DioClient();
    _jikanService = JikanService();
    _sources = [
      NeoxSource(this),
      AnrollSource(this),
    ];
    _subscriptions = Subscriptions()
      ..addAll([
        _hiveController.watchBy('repository_source').listen(_listen),
        _hiveController.watchBy('repository_order_by').listen(_listen),
      ]);
  }

  void _listen(BoxEvent event) {
    ui.WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => refresh(true),
    );
  }

  bool get addMore => isSuccess && _hasMore;

  factory ContentRepository(HiveController hiveController) =>
      _ContentRepositoryImp(hiveController);

  RSource get source => _sources.firstWhere(
        (source) => _deepCollectionEquality.equals(
          source.source,
          _hiveController.source,
        ),
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
  }

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  void dispose() {
    _subscriptions.cancellAll(true);
    super.dispose();
  }
}

class _ContentRepositoryImp extends ContentRepository {
  _ContentRepositoryImp(super._hiveController) : super._internal() {
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
