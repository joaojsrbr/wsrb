import 'dart:async';
import 'dart:collection';

import 'package:content_library/content_library.dart';
import 'package:content_library/src/annotations/source_annotation.dart';
import 'package:content_library/src/constants/content_type.dart';
import 'package:content_library/src/utils/scraping.util.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart' as ui;
import 'package:html/dom.dart';
import 'package:html/parser.dart' hide HtmlParser;
import 'package:intl/intl.dart';

part 'content_repository.g.dart';
part 'generated/content_repository.mapper.dart';
part 'source/goyabu_source.dart';
part 'source/top_animes_source.dart';

/// Registry para criar e gerenciar sources.
class SourceRegistry {
  final Map<Source, RSource Function(SourceContext)> _factories = {};
  final SourceContext context;
  Map<Source, RSource>? _instances;

  SourceRegistry(this.context);

  void register(Source type, RSource Function(SourceContext) factory) {
    _factories[type] = factory;
  }

  RSource get(Source type) {
    final instances = _instances ??= {};
    return instances.putIfAbsent(type, () => _factories[type]!(context));
  }

  bool contains(Source type) => _factories.containsKey(type);

  Iterable<Source> get availableSources => _factories.keys;
}

sealed class ContentRepository extends LoadingMoreBase<Content> {
  late final DioClient _dio;
  late final SourceRegistry _sourceRegistry;
  late final SourceContext _sourceContext;
  late final ScrapingSession session;

  final List<StreamSubscription> _subscriptions = [];
  final ui.GlobalKey anchor = ui.GlobalKey();

  Exception? fullScreenError;

  final AppConfigService? _appConfigService;
  final Source? initialSource;
  final AnimeSkipRepository _animeSkipRepository;

  ContentRepository._internal({
    required AppConfigService? appConfigService,
    required DioClient dio,
    required AnimeSkipRepository animeSkipRepository,
    this.initialSource,
  }) : _appConfigService = appConfigService,
       _dio = dio,
       _animeSkipRepository = animeSkipRepository {
    _sourceContext = SourceContext(
      session: session = ScrapingSession(userAgent: App.USER_AGENT),
      dio: dio,
      state: SourceState(),
      getLength: () => length,
      config: config,
      animeSkipRepository: animeSkipRepository,
      getAnilistMedia: getAnilistMedia,
      anchor: anchor,
      addIfNoContains: addIfNoContains,
      where: where,
    );

    _sourceRegistry = SourceRegistry(_sourceContext);

    for (var source in Source.values) {
      _sourceRegistry.register(source, source.create);
    }

    _maybeAddBetterAnimeInterceptor(appConfigService);

    if (appConfigService != null) {
      _subscriptions.add(
        appConfigService.updateRepository.listen(_onConfigUpdate),
      );
    }
  }

  void _onConfigUpdate(AppConfigService controller) {
    ui.WidgetsBinding.instance.addPostFrameCallback((_) => refresh(true));
    _maybeAddBetterAnimeInterceptor(controller);
  }

  int? get totalPerPage => _sourceState.totalPerPage[currentSource.source];

  AppConfigEntity get config =>
      _appConfigService?.repo.config ?? AppConfigEntity.init();

  SourceState get _sourceState => _sourceContext.state;

  int get index => _sourceState.index;

  void _maybeAddBetterAnimeInterceptor(AppConfigService? controller) {
    return;
    // if (controller?.config.source == Source.TOP_ANIMES) {
    //   _dio.addBetterAnimeInterceptor();
    // } else {
    //   _dio.removeBetterAnimeInterceptor();
    // }
  }

  factory ContentRepository({
    required AppConfigService? appConfigService,
    required DioClient dio,
    required AnimeSkipRepository animeSkipRepository,
  }) = _ContentRepositoryImp;

  factory ContentRepository.test({
    required DioClient dio,
    required AnimeSkipRepository animeSkipRepository,
    required Source initialSource,
  }) = _ContentRepositoryImp.test;

  RSource source(Source type) => _sourceRegistry.get(type);

  RSource get currentSource => source(
    _appConfigService?.repo.config.source ?? initialSource ?? Source.TOP_ANIMES,
  );

  Future<Result<Content>> getDetails(Content content);

  Future<Result<List<Data>>> getReleaseData(Release release, Content content);

  Future<Result<Content>> getContentReleases(Content content, int page);

  Future<Map<Source, SearchResult>> searchContents(
    SearchFilter filter,
    List<Source> searchSources,
  );

  Future<AnilistMedia?> getAnilistMedia(Content content) async {
    final charSelect = AnilistCharacterSelect()
      ..withName()
      ..withImage();

    final staffSelect = AnilistStaffSelect()
      ..withName()
      ..withImage();

    final title = content.title
        .replaceAll(RegExp(' -? ?Dublado', caseSensitive: false), '')
        .trim();

    final request = AnilistMediaRequest(client: _dio.client)
      ..withIdMal()
      ..withTitle()
      ..withType()
      ..withEpisodes()
      ..withFormat()
      ..withStatus()
      ..withDescription()
      ..withStartDate()
      ..withEndDate()
      ..withSeason()
      ..withCountryOfOrigin()
      ..withIsLicensed()
      ..withSource()
      ..withHashtag()
      ..withTrailer()
      ..withUpdatedAt()
      ..withCoverImage()
      ..withBannerImage()
      ..withGenres()
      ..withSynonyms()
      ..withMeanScore()
      ..withAverageScore()
      ..withPopularity()
      ..withIsLocked()
      ..withFavourites()
      ..withTrending()
      ..withTagsId()
      ..withTagsName()
      ..withCharcters(AnilistSubquery(page: 1, perPage: 5, charSelect))
      ..withStaff(AnilistSubquery(page: 1, perPage: 5, staffSelect))
      ..queryType(
        content is Anime ? AnilistMediaType.ANIME : AnilistMediaType.MANGA,
      )
      ..querySearch(title);

    try {
      final results = (await request.list(2, 1)).results;
      return results?.firstOrNull;
    } catch (e) {
      customLog(e.toString());
      return null;
    }
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _sourceState.reset();
    _sourceState.index = currentSource.initialIndex;
    _sourceState.forceRefresh = notifyStateChanged;
    final result = await super.refresh(notifyStateChanged);
    _sourceState.forceRefresh = false;

    return result;
  }

  @override
  void dispose() {
    session.dispose();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}

class _ContentRepositoryImp extends ContentRepository {
  _ContentRepositoryImp({
    required super.appConfigService,
    required super.dio,
    required super.animeSkipRepository,
    super.initialSource,
  }) : super._internal();

  factory _ContentRepositoryImp.test({
    required DioClient dio,
    required AnimeSkipRepository animeSkipRepository,
    required Source initialSource,
  }) => _ContentRepositoryImp(
    appConfigService: null,
    dio: dio,
    animeSkipRepository: animeSkipRepository,
    initialSource: initialSource,
  );

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async =>
      await currentSource.loadPage();

  @override
  Future<Result<Content>> getDetails(Content content) async {
    final result = await source(content.source).getDetails(content);

    if (result case Success<Content> data when data.data is Anime) {
      Anime anime = data.data as Anime;

      final anilistMedia = await getAnilistMedia(anime);

      if (anilistMedia != null) {
        anime = anime.copyWith(
          anilistMedia: AniListMedia.fromJson(
            AnilistMedia.toJson(anilistMedia),
          ),
          largeImage: anilistMedia.coverImage?.large,
          mediumImage: anilistMedia.coverImage?.medium,
        );
      }

      return Result.success(anime);
    }

    return result;
  }

  @override
  Future<Result<List<Data>>> getReleaseData(
    Release release,
    Content content,
  ) async => await source(content.source).getReleaseData(release);

  @override
  Future<Result<Content>> getContentReleases(Content content, int page) async =>
      await source(content.source).getContentReleases(content, page);

  @override
  Future<Map<Source, SearchResult>> searchContents(
    SearchFilter filter,
    List<Source> searchSources,
  ) async {
    final results = <Source, SearchResult>{};
    final emptyResult = SearchResult(contents: SplayTreeSet(), page: 0);

    await Future.wait(
      searchSources.where((s) => _sourceRegistry.contains(s)).map((s) async {
        final source = _sourceRegistry.get(s);
        try {
          final result = await source.search(filter);
          results[source.source] =
              result.fold(
                onSuccess: (data) => data,
                onError: (_) => emptyResult,
                onCancel: () => emptyResult,
                onEmpty: () => emptyResult,
              ) ??
              emptyResult;
        } catch (_) {
          results[source.source] = emptyResult;
        }
      }),
    );

    return results;
  }
}

class _BetterAnimeInterceptor extends Interceptor {
  _BetterAnimeInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final cookies = await CookieUtil.getCookies(WebUri(options.uri.toString()));
    options.headers["Cookie"] = CookieUtil.stringifyCookies(cookies);
    return super.onRequest(options, handler);
  }
}

extension DioClientBetterAnimeExtension on DioClient {
  void addBetterAnimeInterceptor() => addInterceptor(_BetterAnimeInterceptor());
  void removeBetterAnimeInterceptor() =>
      removeInterceptor(_BetterAnimeInterceptor);
}
