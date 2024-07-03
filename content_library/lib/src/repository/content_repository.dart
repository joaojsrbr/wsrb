import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:content_library/src/exceptions/anime_exception.dart';
import 'package:content_library/src/exceptions/book_exception.dart';
import 'package:content_library/src/extensions/custom_extensions/list_extensions.dart';
import 'package:content_library/src/extensions/custom_extensions/string_extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' as ui;
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart' as plugin;
import 'package:hive/hive.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'package:loading_more_list/loading_more_list.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
part 'source/goyabu_source.dart';
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
    _sources = [
      NeoxSource(this),
      GoyabuSource(this),
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

  RSource source(Source source) => _sources.firstWhere(
        (element) => source == element.source,
      );

  Future<Result<Content>> getData(Content content);

  Future<Result<List<Data>>> getContent(Release releases);

  Future<Result<Content>> getReleases(Content content, int page);

  Future<void> searchContents(
    String query, {
    required List<Source> searchSources,
    required ui.ValueChanged<(Source, List<Content>)> onSuccess,
  });

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    index = source(_hiveController.source).initialIndex;
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
    _subscriptions.cancelAll();
    super.dispose();
  }
}

class _ContentRepositoryImp extends ContentRepository {
  _ContentRepositoryImp(
    super._hiveController,
    super.dio,
  ) : super._internal();

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async =>
      await source(_hiveController.source).loadData();

  @override
  Future<Result<Content>> getData(Content content) async =>
      await source(_hiveController.source).getData(content);

  @override
  Future<Result<List<Data>>> getContent(Release release) async =>
      await source(_hiveController.source).getContent(release);

  @override
  Future<Result<Content>> getReleases(Content content, int page) async =>
      await source(_hiveController.source).getReleases(content, page);

  @override
  Future<void> searchContents(
    String query, {
    required List<Source> searchSources,
    required ui.ValueChanged<(Source, List<Content>)> onSuccess,
  }) async {
    final futures =
        _sources.where((source) => searchSources.contains(source.source)).map(
              (source) => source.search(query).then((value) => value.fold(
                  onSuccess: (data) => onSuccess((source.source, data)))),
            );
    for (final future in futures) {
      try {
        await future;
      } on Exception catch (_) {}
    }
  }
}

class _DefaultAppHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addEntries(App.HEADERS.entries);
    super.onRequest(options, handler);
  }
}
