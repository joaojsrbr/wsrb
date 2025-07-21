import 'dart:async';
import 'dart:convert';

import 'package:anilist_dart/anilist.dart';
import 'package:collection/collection.dart';
import 'package:content_library/src/controllers/app_config_controller.dart';
import 'package:content_library/src/entities/anilist_media.dart';
import 'package:content_library/src/entities/app_config_entity.dart';
import 'package:content_library/src/exceptions/anime_exception.dart';
import 'package:content_library/src/exceptions/book_exception.dart';
import 'package:content_library/src/extensions/custom_extensions/list_extensions.dart';
import 'package:content_library/src/extensions/custom_extensions/string_extensions.dart';
import 'package:content_library/src/models/anime_skip.dart';
import 'package:content_library/src/repository/anime_skip_imp.dart';
import 'package:content_library/src/repository/models/slime_read_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' as ui;
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
import '../utils/custom_log.dart';
import '../utils/releases.dart';
import '../utils/result.dart';
import '../utils/scraping.util.dart';
import '../utils/subscriptions.dart';
import 'source/source.dart';

part 'source/anroll_source.dart';
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
  // late final JikanService _jikanService;
  late final Subscriptions _subscriptions;
  late final List<RSource> _sources;
  final AppConfigController? _appConfigController;
  final Source? initialSource;
  final AnimeSkipRepository _animeSkipRepository;

  AppConfigEntity get config => _appConfigController?.repo.config ?? AppConfigEntity.init();

  ContentRepository._internal(this._appConfigController, this._dio, this._animeSkipRepository, this.initialSource) {
    _sources = [NeoxSource(this), GoyabuSource(this), SlimeReadSource(this), AnrollSource(this), DemonSect(this)];

    if (_appConfigController != null) {
      _appConfigController.orderOrSourceUpdate = () {
        _listen();
      };
    }
  }

  void _listen() {
    ui.WidgetsBinding.instance.addPostFrameCallback((timeStamp) => refresh(true));
  }

  bool get addMore => isSuccess && _hasMore;

  factory ContentRepository(AppConfigController appConfig, DioClient dio, AnimeSkipRepository animeSkipRepository) => _ContentRepositoryImp(appConfig, dio, animeSkipRepository, null);

  factory ContentRepository.test(DioClient dio, AnimeSkipRepository animeSkipRepository, Source initialSource) => _ContentRepositoryImp.test(animeSkipRepository, dio, initialSource);

  RSource source(Source source) => _sources.firstWhere((element) => source == element.source);

  Future<Result<Content>> getData(Content content);

  Future<Result<List<Data>>> getContent(Release releases);

  Future<Result<Content>> getReleases(Content content, int page);

  Future<void> searchContents(String query, {required List<Source> searchSources, required ui.ValueChanged<(Source, List<Content>)> onSuccess});

  Future<AnilistMedia?> getAnilistMedia(Content content) async {
    final charSelect = AnilistCharacterSelect()
      ..withName()
      ..withImage();

    final staffSelect = AnilistStaffSelect()
      ..withName()
      ..withImage();

    final title = content.title.replaceAll(' - Dublado', '').replaceAll('dublado', '').replaceAll('Dublado', '').trim();

    final request = AnilistMediaRequest(client: _dio.client)
      ..withIdMal()
      ..withTitle()
      ..withType()
      ..withEpisodes()
      ..withFormat()
      ..withIdMal()
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
      ..withBannerImage()
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
      final animeMedia = results?.firstWhereOrNull((media) => media.type == (content is Anime ? AnilistMediaType.ANIME : AnilistMediaType.MANGA));
      return animeMedia;
    } catch (e) {
      customLog(e.toString());
      return null;
    }
  }

  RSource get currentSource => source(_appConfigController?.repo.config.source ?? initialSource ?? Source.ANROLL);

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    index = currentSource.initialIndex;
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
  _ContentRepositoryImp(super._hiveController, super.dio, super._animeSkipRepository, super.initialSource) : super._internal();

  factory _ContentRepositoryImp.test(AnimeSkipRepository animeSkipRepository, DioClient dio, Source initialSource) {
    return _ContentRepositoryImp(null, dio, animeSkipRepository, initialSource);
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async => await currentSource.loadData();

  @override
  Future<Result<Content>> getData(Content content) async {
    final result = await currentSource.getData(content);
    if (result is Success<Content> && result.data is Anime) {
      Anime anime = result.data as Anime;
      final anilistMedia = await getAnilistMedia(anime);

      if (anilistMedia != null) {
        anime = anime.copyWith(
          sinopse: anime.sinopse?.isEmpty == true || anime.sinopse == null ? anilistMedia.description : null,
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
  Future<Result<List<Data>>> getContent(Release release) async => await currentSource.getContent(release);

  @override
  Future<Result<Content>> getReleases(Content content, int page) async => await currentSource.getReleases(content, page);

  @override
  Future<void> searchContents(String query, {required List<Source> searchSources, required ui.ValueChanged<(Source, List<Content>)> onSuccess}) async {
    final futures = _sources
        .where((source) => searchSources.contains(source.source))
        .map((source) => source.search(query).then((value) => value.fold(onSuccess: (data) => onSuccess((source.source, data)))));
    for (final future in futures) {
      try {
        await future;
      } catch (_) {}
    }
  }
}
