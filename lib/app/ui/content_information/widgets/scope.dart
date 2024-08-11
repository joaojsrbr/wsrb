// ignore_for_file: constant_identifier_names

import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ContentScope extends InheritedModel<ContentScopeAspect> {
  ContentScope({
    super.key,
    required WidgetBuilder builder,
    required this.isLoading,
    required this.index,
    required this.setListIndex,
    required this.downloadRelease,
    required this.releases,
    required this.bottomTabController,
    required this.content,
    required this.releasesIsLoading,
  }) : super(child: Builder(builder: builder));

  final bool releasesIsLoading;
  final bool isLoading;
  final TabController bottomTabController;
  final Content content;
  final ValueSetter<int> setListIndex;
  final int index;
  final Map<int, Releases> releases;
  final ValueSetter<Release> downloadRelease;

  static ContentScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ContentScope>()!;
  }

  static ContentScope _of(BuildContext context, [ContentScopeAspect? aspect]) {
    assert(debugCheckHasMediaQuery(context));
    return InheritedModel.inheritFrom<ContentScope>(context, aspect: aspect)!;
  }

  static bool isLoadingOf(BuildContext context) =>
      _of(context, ContentScopeAspect.ISLOADING).isLoading;

  static Content contentOf(BuildContext context) =>
      _of(context, ContentScopeAspect.CONTENT).content;

  static int indexOf(BuildContext context) =>
      _of(context, ContentScopeAspect.LISTCHAPTERINDEX).index;

  static bool releasesIsLoadingOf(BuildContext context) =>
      _of(context, ContentScopeAspect.RELEASESISLOADING).releasesIsLoading;

  static Map<int, Releases<Release>> releasesOf(BuildContext context) =>
      _of(context, ContentScopeAspect.ALLRELEASES).releases;

  @override
  bool updateShouldNotifyDependent(
      ContentScope oldWidget, Set<ContentScopeAspect> dependencies) {
    for (final Object dependency in dependencies) {
      if (dependency is ContentScopeAspect) {
        switch (dependency) {
          case ContentScopeAspect.ISLOADING
              when isLoading != oldWidget.isLoading:
            return true;
          case ContentScopeAspect.CONTENT when content != oldWidget.content:
            return true;
          case ContentScopeAspect.LISTCHAPTERINDEX
              when index != oldWidget.index:
            return true;
          case ContentScopeAspect.RELEASESISLOADING
              when releasesIsLoading != oldWidget.releasesIsLoading:
            return true;
          case ContentScopeAspect.ALLRELEASES
              when !mapEquals(releases, oldWidget.releases):
            return true;
          default:
            return true;
        }
      }
    }

    return false;
  }

  @override
  bool updateShouldNotify(ContentScope oldWidget) {
    return isLoading != oldWidget.isLoading ||
        content != oldWidget.content ||
        releasesIsLoading != oldWidget.releasesIsLoading ||
        index != oldWidget.index;
  }
}

enum ContentScopeAspect {
  ISLOADING,
  RELEASESISLOADING,
  LISTCHAPTERINDEX,
  ALLRELEASES,
  CONTENT,
}

enum ContentTabBar {
  CONTENT,
  INFORMATION;

  String getTitle(Content content) {
    return switch (content) {
      Book _ when this == ContentTabBar.INFORMATION => 'Ler',
      Anime _ when this == ContentTabBar.INFORMATION => 'Assistir',
      _ => 'Info',
    };
  }

  IconData getIconData(Content content) {
    return switch (content) {
      Book _ when this == ContentTabBar.INFORMATION => MdiIcons.book,
      Anime _ when this == ContentTabBar.INFORMATION => MdiIcons.play,
      _ => MdiIcons.information,
    };
  }
}
