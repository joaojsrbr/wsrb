// ignore_for_file: constant_identifier_names

import 'package:app_wsrb_jsr/app/ui/content_information/arguments/content_information_args.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ContentScope extends InheritedModel<ContentScopeAspect> {
  ContentScope({
    super.key,
    Widget? child,
    WidgetBuilder? builder,
    required this.isLoading,
    required this.index,
    required this.noContent,
    required this.setListIndex,
    required this.downloadRelease,

    required this.releases,
    required this.content,
    required this.informationArgs,
    required this.releasesIsLoading,
    required this.onLongPressed,
  }) : super(child: Builder(builder: builder ?? (context) => child ?? SizedBox.shrink()));

  final ContentInformationArgs? informationArgs;
  final bool releasesIsLoading;
  final bool isLoading;
  final bool noContent;
  final Content? content;
  final ValueSetter<int> setListIndex;
  final int index;
  final Map<int, Releases> releases;
  final ValueSetter<Release> downloadRelease;
  final void Function(Release release) onLongPressed;

  static ContentScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ContentScope>()!;
  }

  static ContentScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ContentScope>();
  }

  static ContentScope _of(BuildContext context, [ContentScopeAspect? aspect]) {
    assert(debugCheckHasMediaQuery(context));
    return InheritedModel.inheritFrom<ContentScope>(context, aspect: aspect)!;
  }

  static bool isLoadingOf(BuildContext context) =>
      _of(context, ContentScopeAspect.ISLOADING).isLoading;
  static bool noContentOf(BuildContext context) =>
      _of(context, ContentScopeAspect.noContent).noContent;

  static Content contentOf(BuildContext context) =>
      _of(context, ContentScopeAspect.CONTENT).content ??
      (ModalRoute.settingsOf(context)!.arguments as ContentInformationArgs).content;

  static int indexOf(BuildContext context) =>
      _of(context, ContentScopeAspect.LISTCHAPTERINDEX).index;

  static bool releasesIsLoadingOf(BuildContext context) =>
      _of(context, ContentScopeAspect.RELEASESISLOADING).releasesIsLoading;

  static Map<int, Releases<Release>> releasesOf(BuildContext context) =>
      _of(context, ContentScopeAspect.ALLRELEASES).releases;

  @override
  bool updateShouldNotifyDependent(
    ContentScope oldWidget,
    Set<ContentScopeAspect> dependencies,
  ) {
    for (final Object dependency in dependencies) {
      if (dependency is ContentScopeAspect) {
        switch (dependency) {
          case ContentScopeAspect.ISLOADING when isLoading != oldWidget.isLoading:
            return true;
          case ContentScopeAspect.noContent when noContent != oldWidget.noContent:
            return true;
          case ContentScopeAspect.CONTENT when content != oldWidget.content:
            return true;
          case ContentScopeAspect.LISTCHAPTERINDEX when index != oldWidget.index:
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
        noContent != oldWidget.noContent ||
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
  noContent,
}

enum ContentTabBar {
  CONTENT,
  INFORMATION;

  String getTitle(Content content) {
    return switch (content) {
      Book _ when this == ContentTabBar.CONTENT => 'Ler',
      Anime _ when this == ContentTabBar.CONTENT => 'Assistir',
      _ => 'Info',
    };
  }

  IconData getIconData(Content content) {
    return switch (content) {
      Book _ when this == ContentTabBar.CONTENT => MdiIcons.book,
      Anime _ when this == ContentTabBar.CONTENT => MdiIcons.play,
      _ => MdiIcons.information,
    };
  }
}
