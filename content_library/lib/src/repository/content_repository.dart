import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:content_library/src/exceptions/anroll_get_id_exception.dart';
import 'package:content_library/src/exceptions/book_exception.dart';
import 'package:content_library/src/extensions/custom_extensions/list_extensions.dart';
import 'package:content_library/src/extensions/custom_extensions/string_extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' as ui;

import 'package:hive/hive.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'package:loading_more_list/loading_more_list.dart';

import '../constants/app.dart';
import '../constants/source.dart';
import '../models/anime.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../models/content.dart';
import '../models/data.dart';
import '../models/episode.dart';
import '../models/genre.dart';
import '../models/release.dart';
import '../services/dio_client.dart';
import '../services/hive/hive_controller.dart';
import '../utils/custom_log.dart';
import '../utils/releases.dart';
import '../utils/result.dart';
import '../utils/scraping.util.dart';
import '../utils/subscriptions.dart';
import 'source/source.dart';

part 'source/neox_source.dart';
part 'source/demon_sect_source.dart';
part 'source/anroll_source.dart';

abstract class ContentRepository extends LoadingMoreBase<Content> {
  int index = 0;
  bool isSuccess = false;
  bool _hasMore = true;
  bool forceRefresh = false;
  Exception? fullScreenError;

  late final DioClient _dio;
  // late final JikanService _jikanService;
  late final Subscriptions _subscriptions;
  late final List<RSource> _sources;
  final HiveController _hiveController;

  ContentRepository._internal(
    this._hiveController,
    this._dio,
  ) {
    _dio.addInterceptor(_DefaultAppHeadersInterceptor());
    // _jikanService = JikanService();
    _sources = [
      NeoxSource(this),
      AnrollSource(this),
      DemonSect(this),
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

  factory ContentRepository(HiveController hiveController, DioClient dio) =>
      _ContentRepositoryImp(hiveController, dio);

  RSource get source => _sources.firstWhere(
        (source) => source.source == _hiveController.source,
      );

  Future<Result<Content>> getData(Content content);

  Future<Result<List<Data>>> getContent(Release releases);

  Future<Result<Content>> getReleases(Content content, int page);

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
    _subscriptions.dispose();
    super.dispose();
  }
}

class _ContentRepositoryImp extends ContentRepository {
  _ContentRepositoryImp(
    super._hiveController,
    super.dio,
  ) : super._internal() {
    // ui.WidgetsBinding.instance
    //     .addPostFrameCallback((timeStamp) => refresh(true));
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async =>
      await source.loadData();

  @override
  Future<Result<Content>> getData(Content content) async =>
      await source.getData(content);

  @override
  Future<Result<List<Data>>> getContent(Release release) async =>
      await source.getContent(release);

  @override
  Future<Result<Content>> getReleases(Content content, int page) async =>
      await source.getReleases(content, page);
}

class _DefaultAppHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers = App.HEADERS;
    super.onRequest(options, handler);
  }
}
