import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart' as ui;

/// Estado do source que pode ser modificado pelos sources.
class SourceState {
  bool isSuccess = false;
  bool hasMore = true;
  Exception? fullScreenError;
  int index = 0;
  Map<Source, int> totalPerPage = {};
  bool forceRefresh = false;

  bool get addMore => isSuccess && hasMore;

  void reset() {
    isSuccess = false;
    hasMore = false;
    fullScreenError = null;
    index = 0;
    totalPerPage.clear();
  }

  void onSuccess() {
    isSuccess = true;
    hasMore = true;
    fullScreenError = null;
  }

  void onError(Exception error) {
    isSuccess = false;
    hasMore = false;
    fullScreenError = error;
  }
}

/// Contexto passado para cada source com suas dependências.
class SourceContext {
  final ScrapingSession session;
  final DioClient dio;
  final SourceState state;
  final AppConfigEntity config;
  final AnimeSkipRepository animeSkipRepository;
  final Future<AnilistMedia?> Function(Content content) getAnilistMedia;
  final ui.GlobalKey anchor;
  final int Function() getLength;

  final void Function(Content, [bool Function(Content)?]) addIfNoContains;
  final Iterable<Content> Function(bool Function(Content)) where;

  SourceContext({
    required this.session,
    required this.dio,
    required this.state,
    required this.config,
    required this.animeSkipRepository,
    required this.getAnilistMedia,
    required this.anchor,
    required this.addIfNoContains,
    required this.where,
    required this.getLength,
  });
}
