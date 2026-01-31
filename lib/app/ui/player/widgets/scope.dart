// ignore_for_file: constant_identifier_names, library_private_types_in_public_api

import 'package:android_pip/actions/pip_action.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../arguments/player_args.dart';

enum _PlayerScopeAspect {
  Player_PLAYERARGS,
  Player_ISLOADING,
  Player_ACTIVEFIT,
  Player_PIP,
  Player_CURRENTVALUECIRULARANIMATION,
  // Player_FOOTERWIDGET,
}

class PlayerScope extends InheritedModel<_PlayerScopeAspect> {
  const PlayerScope({
    super.key,
    required super.child,
    required this.playerArgs,
    required this.isLoading,
    required this.onClickSkipAnime,
    required this.videoController,
    required this.maxValueCircularAnimation,
    required this.currentValueCircularAnimation,
    required this.setFits,
    required this.onTapEpisode,
    required this.activeFit,
    required this.onTapEpisodeInOverlay,
    required this.overlayNextEpisode,
    required this.overlayBoxFit,
    required this.topTitle,
    required this.enterInPip,
    required this.lockPlayer,
    required this.reversedCurrentDuration,
    required this.showAnimeSkip,
    required this.isPipAvailable,
    required this.isPipActivated,
    required this.selectedAnimeTimeStamp,
    required this.onPipAction,
    required this.openMenuInFullScreen,
    required this.animationController,
    required this.onPipChange,
    required this.data,
    required this.mainData,
    required this.onTapData,
    required this.showButtonQuality,
    // required this.draggableScrollableController,
  });

  final void Function(AnimeTimeStamp item) onClickSkipAnime;
  // final DraggableScrollableController draggableScrollableController;
  final List<Data> data;
  final Data? mainData;
  final ValueNotifier<bool> showButtonQuality;
  final ValueChanged<Data> onTapData;
  final void Function(PipAction) onPipAction;
  final AnimationController animationController;
  final void Function() onPipChange;
  final bool isPipAvailable;
  final bool isPipActivated;
  final VoidCallback enterInPip;
  final ValueNotifier<bool> lockPlayer;
  final ValueNotifier<AnimeTimeStamp?> selectedAnimeTimeStamp;
  final ValueNotifier<bool> showAnimeSkip;
  final ValueNotifier<bool> openMenuInFullScreen;
  final ValueNotifier<bool> reversedCurrentDuration;
  final ValueNotifier<String> topTitle;
  final ValueNotifier<String?> overlayBoxFit;
  final ValueNotifier<String?> overlayNextEpisode;
  final AsyncCallback onTapEpisodeInOverlay;
  final ValueChanged<Episode> onTapEpisode;
  final VideoController? videoController;
  final BoxFit activeFit;
  final PlayerArgs playerArgs;
  final VoidCallback setFits;
  final int currentValueCircularAnimation;
  final int maxValueCircularAnimation;
  final bool isLoading;

  static PlayerScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlayerScope>()!;
  }

  static PlayerScope _of(BuildContext context, [_PlayerScopeAspect? aspect]) {
    assert(debugCheckHasMediaQuery(context));
    return InheritedModel.inheritFrom<PlayerScope>(context, aspect: aspect)!;
  }

  static PlayerArgs playerArgsOf(BuildContext context) {
    final playerArgs = _of(context, _PlayerScopeAspect.Player_PLAYERARGS).playerArgs;
    return playerArgs;
  }

  static bool isLoadingOf(BuildContext context) {
    final isLoading = _of(context, _PlayerScopeAspect.Player_ISLOADING).isLoading;
    return isLoading;
  }

  static bool isPipActivatedOf(BuildContext context) {
    final isPipActivated = _of(context, _PlayerScopeAspect.Player_PIP).isPipActivated;
    return isPipActivated;
  }

  static bool isPipAvailableOf(BuildContext context) {
    final isPipAvailable = _of(context, _PlayerScopeAspect.Player_PIP).isPipAvailable;
    return isPipAvailable;
  }

  static int currentValueCircularAnimationOf(BuildContext context) {
    final currentValueCircularAnimation = _of(
      context,
      _PlayerScopeAspect.Player_CURRENTVALUECIRULARANIMATION,
    ).currentValueCircularAnimation;
    return currentValueCircularAnimation;
  }

  static BoxFit activeFitOf(BuildContext context) {
    final activeFit = _of(context, _PlayerScopeAspect.Player_ACTIVEFIT).activeFit;
    return activeFit;
  }

  // static Book bookOf(BuildContext context) {
  //   final args = ModalRoute.of(context)?.settings.arguments as PlayerViewArgs;
  //   final book = _of(context, _PlayerScopeAspect.Player_BOOK).book;
  //   return book ?? args.book;
  // }

  @override
  bool updateShouldNotifyDependent(
    PlayerScope oldWidget,
    Set<_PlayerScopeAspect> dependencies,
  ) {
    for (final Object dependency in dependencies) {
      if (dependency is _PlayerScopeAspect) {
        switch (dependency) {
          case _PlayerScopeAspect.Player_PLAYERARGS
              when playerArgs != oldWidget.playerArgs:
            return true;
          case _PlayerScopeAspect.Player_ISLOADING when isLoading != oldWidget.isLoading:
            return true;
          case _PlayerScopeAspect.Player_PIP
              when isPipAvailable != oldWidget.isPipAvailable ||
                  isPipActivated != oldWidget.isPipActivated:
            return true;
          case _PlayerScopeAspect.Player_ACTIVEFIT when activeFit != oldWidget.activeFit:
            return true;
          case _PlayerScopeAspect.Player_CURRENTVALUECIRULARANIMATION
              when currentValueCircularAnimation !=
                  oldWidget.currentValueCircularAnimation:
            return true;
          default:
            return true;
        }
      }
    }

    return false;
  }

  @override
  bool updateShouldNotify(covariant PlayerScope oldWidget) {
    return playerArgs != oldWidget.playerArgs ||
        isLoading != oldWidget.isLoading ||
        isPipActivated != oldWidget.isPipActivated ||
        isPipAvailable != oldWidget.isPipAvailable ||
        currentValueCircularAnimation != oldWidget.currentValueCircularAnimation ||
        activeFit != oldWidget.activeFit;
  }
}
