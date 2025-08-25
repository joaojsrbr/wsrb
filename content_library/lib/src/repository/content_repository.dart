import 'dart:async';
import 'dart:convert';

import 'package:content_library/content_library.dart';
import 'package:content_library/src/models/slime_read_response.dart';
import 'package:flutter/material.dart' as ui;
import 'package:html/dom.dart';
import 'package:html/parser.dart' hide HtmlParser;

import '../utils/scraping.util.dart';
import 'source/source.dart';

part 'source/anroll_source.dart';
part 'source/better_anime_source.dart';
part 'source/demon_sect_source.dart';
part 'source/goyabu_source.dart';
part 'source/neox_source.dart';
part 'source/slime_read_source.dart';

abstract class ContentRepository extends LoadingMoreBase<Content> {
  int index = 0;
  bool isSuccess = false;
  bool _hasMore = true;
  bool forceRefresh = false;
  Exception? fullScreenError;

  late final DioClient _dio;
  late final Set<RSource> _sources;
  late final ScrapingSession session;

  final Set<int> totalPerPage = {};
  final Subscriptions _subscriptions = Subscriptions();
  final ui.GlobalKey anchor = ui.GlobalKey();

  final AppConfigController? _appConfigController;
  final Source? initialSource;
  final AnimeSkipRepository _animeSkipRepository;

  AppConfigEntity get config =>
      _appConfigController?.repo.config ?? AppConfigEntity.init();

  ContentRepository._internal(
    this._appConfigController,
    this._dio,
    this._animeSkipRepository,
    this.initialSource,
  ) {
    _sources = {
      NeoxSource(this),
      GoyabuSource(this),
      SlimeReadSource(this),
      AnrollSource(this),
      DemonSect(this),
      BetterAnimeSource(this),
    };

    _maybeAddBetterAnimeInterceptor(_appConfigController);

    if (_appConfigController != null) {
      _subscriptions.add(_appConfigController.update.listen(_listen));
    }

    session = ScrapingSession(
      userAgent:
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
      debugLogging: false,
    );
  }

  void _listen(AppConfigController appConfigController) {
    ui.WidgetsBinding.instance.addPostFrameCallback((_) => refresh(true));
    _maybeAddBetterAnimeInterceptor(appConfigController);
  }

  void _maybeAddBetterAnimeInterceptor(AppConfigController? controller) {
    if (controller?.config.source == Source.BETTER_ANIME) {
      _dio.addInterceptor(_BetterAnimeInterceptor());
    } else {
      _dio.removeInterceptor(_BetterAnimeInterceptor);
    }
  }

  bool get addMore => isSuccess && _hasMore;

  factory ContentRepository(
    AppConfigController appConfig,
    DioClient dio,
    AnimeSkipRepository animeSkipRepository,
  ) => _ContentRepositoryImp(appConfig, dio, animeSkipRepository, null);

  factory ContentRepository.test(
    DioClient dio,
    AnimeSkipRepository animeSkipRepository,
    Source initialSource,
  ) => _ContentRepositoryImp.test(animeSkipRepository, dio, initialSource);

  RSource source(Source source) => _sources.firstWhere((s) => source == s.source);

  RSource get currentSource =>
      source(_appConfigController?.repo.config.source ?? initialSource ?? Source.ANROLL);

  Future<Result<Content>> getData(Content content);

  Future<Result<List<Data>>> getContent(Release releases);

  Future<Result<Content>> getReleases(Content content, int page);

  Future<void> searchContents(
    String query, {
    required List<Source> searchSources,
    required ui.ValueChanged<(Source, List<Content>)> onSuccess,
  });

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
      ..queryType(content is Anime ? AnilistMediaType.ANIME : AnilistMediaType.MANGA)
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
    index = currentSource.initialIndex;
    isSuccess = false;
    _hasMore = false;
    forceRefresh = notifyStateChanged;
    final result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    totalPerPage.clear();
    return result;
  }

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  void dispose() {
    session.dispose();
    _subscriptions.cancelAll();
    super.dispose();
  }
}

class _ContentRepositoryImp extends ContentRepository {
  _ContentRepositoryImp(
    super._hiveController,
    super.dio,
    super._animeSkipRepository,
    super.initialSource,
  ) : super._internal();

  factory _ContentRepositoryImp.test(
    AnimeSkipRepository animeSkipRepository,
    DioClient dio,
    Source initialSource,
  ) => _ContentRepositoryImp(null, dio, animeSkipRepository, initialSource);

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async =>
      await currentSource.loadData();

  @override
  Future<Result<Content>> getData(Content content) async {
    final result = await currentSource.getData(content);

    if (result case Success<Content> data when data.data is Anime) {
      Anime anime = data.data as Anime;

      final anilistMedia = await getAnilistMedia(anime);

      if (anilistMedia != null) {
        anime = anime.copyWith(
          sinopse: anime.sinopse.isNotEmpty ? anilistMedia.description : null,
          anilistMedia: AniListMedia.fromJson(AnilistMedia.toJson(anilistMedia)),
          largeImage: anilistMedia.coverImage?.large,
          mediumImage: anilistMedia.coverImage?.medium,
        );
      }

      return Result.success(anime);
    }

    return result;
  }

  @override
  Future<Result<List<Data>>> getContent(Release release) async =>
      await currentSource.getContent(release);

  @override
  Future<Result<Content>> getReleases(Content content, int page) async =>
      await currentSource.getReleases(content, page);

  @override
  Future<void> searchContents(
    String query, {
    required List<Source> searchSources,
    required ui.ValueChanged<(Source, List<Content>)> onSuccess,
  }) async {
    final futures = _sources.where((source) => searchSources.contains(source.source)).map(
      (source) async {
        try {
          final result = await source.search(query);
          result.fold(onSuccess: (data) => onSuccess((source.source, data)));
        } catch (_) {}
      },
    );

    await Future.wait(futures);
  }
}

class _BetterAnimeInterceptor extends Interceptor {
  _BetterAnimeInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final cookies = await CookieUtil.getCookies(WebUri(options.uri.toString()));
    options.headers["Cookie"] = CookieUtil.stringifyCookies(cookies);
    return super.onRequest(options, handler);
  }
}
