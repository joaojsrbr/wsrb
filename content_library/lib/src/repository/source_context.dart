import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart' as ui;

/// Estado do source que pode ser modificado pelos sources.
class SourceState {
  bool isSuccess = false;
  bool hasMore = true;
  Exception? fullScreenError;

  void reset() {
    isSuccess = false;
    hasMore = false;
    fullScreenError = null;
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
  final void Function(int page) addTotalPerPage;
  final Set<int> Function() getTotalPerPage;
  final ui.GlobalKey anchor;
  final int Function() getIndex;
  final void Function(int) setIndex;
  final bool Function() getAddMore;
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
    required this.addTotalPerPage,
    required this.getTotalPerPage,
    required this.anchor,
    required this.getIndex,
    required this.setIndex,
    required this.getLength,
    required this.getAddMore,
    required this.addIfNoContains,
    required this.where,
  });
}
