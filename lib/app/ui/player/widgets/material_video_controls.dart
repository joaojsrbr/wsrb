import 'dart:async';

import 'package:app_wsrb_jsr/app/ui/player/view/player_view.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/player_custom_overlay.dart';
import 'package:app_wsrb_jsr/app/ui/player/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/ui/shared/mixins/subscriptions.dart';
import 'package:app_wsrb_jsr/app/ui/shared/widgets/custom_popup.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

MaterialVideoControlsThemeData _theme(BuildContext context) =>
    FullscreenInheritedWidget.maybeOf(context) == null
        ? MaterialVideoControlsTheme.maybeOf(context)?.normal ??
            kDefaultMaterialVideoControlsThemeData
        : MaterialVideoControlsTheme.maybeOf(context)?.fullscreen ??
            kDefaultMaterialVideoControlsThemeDataFullscreen;

class CustomMaterialControls extends StatefulWidget {
  const CustomMaterialControls._({required this.state});
  factory CustomMaterialControls(VideoState state) =>
      CustomMaterialControls._(state: state);

  final VideoState state;

  @override
  State<CustomMaterialControls> createState() => _CustomMaterialControlsState();
}

class _CustomMaterialControlsState extends State<CustomMaterialControls>
    with SubscriptionsMixin {
  late bool mount = _theme(context).visibleOnMount;
  late bool visible = _theme(context).visibleOnMount;

  Timer? _timer;
  final ValueNotifier<Duration> _seekBarDeltaValueNotifier =
      ValueNotifier<Duration>(Duration.zero);

  late final PlayerScope _playerScope =
      PlayerScope.of(PlayerView.videoStateKey.currentContext!);

  double _brightnessValue = 0.0;
  bool _brightnessIndicator = false;
  Timer? _brightnessTimer;

  double _volumeValue = 0.0;
  bool _volumeIndicator = false;

  Timer? _volumeTimer;
  bool _volumeInterceptEventStream = false;

  Offset _dragInitialDelta = Offset.zero;
  int swipeDuration = 0;
  bool showSwipeDuration = false;

  // ignore: prefer_final_fields
  bool _speedUpIndicator = false;
  late Playlist playlist = controller(context).player.state.playlist;
  late bool buffering = controller(context).player.state.buffering;

  bool _mountSeekBackwardButton = false;
  bool _mountSeekForwardButton = false;
  bool _hideSeekBackwardButton = false;
  bool _hideSeekForwardButton = false;
  bool get _lockPlayer => _playerScope.lockPlayer.value;

  set setLockPlayer(bool lockPlayer) {
    if (!mounted) return;
    setState(() {
      _playerScope.lockPlayer.value = lockPlayer;
    });
  }

  double get subtitleVerticalShiftOffset =>
      (_theme(context).padding?.bottom ?? 0.0) +
      (_theme(context).bottomButtonBarMargin.vertical) +
      (_theme(context).bottomButtonBar.isNotEmpty
          ? _theme(context).buttonBarHeight
          : 0.0);
  Offset? _tapPosition;

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
  }

  // void _handleLongPress() {
  //   setState(() {
  //     _speedUpIndicator = true;
  //   });
  //   controller(context).player.setRate(_theme(context).speedUpFactor);
  // }

  // void _handleLongPressEnd(LongPressEndDetails details) {
  //   setState(() {
  //     _speedUpIndicator = false;
  //   });
  //   controller(context).player.setRate(1.0);
  // }

  Future<void> setBrightness(double value) async {
    try {
      await ScreenBrightness().setScreenBrightness(value);
    } catch (_) {}
    setState(() => _brightnessIndicator = true);
    _brightnessTimer?.cancel();
    _brightnessTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _brightnessIndicator = false;
        });
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    Future.microtask(() async {
      widget.state;

      try {
        VolumeController().showSystemUI = false;
        _volumeValue = await VolumeController().getVolume();
        subscriptions.add(
          VolumeController().listener((value) {
            if (mounted && !_volumeInterceptEventStream) {
              setState(() {
                _volumeValue = value;
              });
            }
          }),
        );
      } catch (_) {}
    });

    Future.microtask(() async {
      try {
        _brightnessValue = await ScreenBrightness().current;
        subscriptions.add(
          ScreenBrightness().onCurrentBrightnessChanged.listen((value) {
            if (mounted) {
              setState(() {
                _brightnessValue = value;
              });
            }
          }),
        );
      } catch (_) {}
    });
    super.initState();
  }

  Future<void> setVolume(double value) async {
    try {
      VolumeController().setVolume(value);
    } catch (_) {}
    setState(() {
      _volumeValue = value;
      _volumeIndicator = true;
      _volumeInterceptEventStream = true;
    });
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _volumeIndicator = false;
          _volumeInterceptEventStream = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty) {
      subscriptions.addAll(
        [
          controller(context).player.stream.playlist.listen(
            (event) {
              setState(() => playlist = event);
            },
          ),
          controller(context).player.stream.buffering.listen(
            (event) {
              setState(() => buffering = event);
            },
          ),
        ],
      );

      if (_theme(context).visibleOnMount) {
        _timer = Timer(
          _theme(context).controlsHoverDuration,
          () {
            if (mounted) {
              setState(() {
                visible = false;
              });
              unshiftSubtitle();
            }
          },
        );
      }
    }
  }

  void unshiftSubtitle() {
    if (_theme(context).shiftSubtitlesOnControlsVisibilityChange) {
      state(context).setSubtitleViewPadding(
        state(context).widget.subtitleViewConfiguration.padding,
      );
    }
  }

  void shiftSubtitle() {
    if (_theme(context).shiftSubtitlesOnControlsVisibilityChange) {
      state(context).setSubtitleViewPadding(
        state(context).widget.subtitleViewConfiguration.padding +
            EdgeInsets.fromLTRB(
              0.0,
              0.0,
              0.0,
              subtitleVerticalShiftOffset,
            ),
      );
    }
  }

  void onTap() {
    if (!visible) {
      setState(() {
        mount = true;
        visible = true;
      });
      shiftSubtitle();
      _timer?.cancel();
      _timer = Timer(_theme(context).controlsHoverDuration, () {
        if (mounted && !_playerScope.openMenuInFullScreen.value) {
          setState(() {
            visible = false;
          });

          if (_playerScope.openMenuInFullScreen.value) {
            _playerScope.openMenuInFullScreen.value = false;
          }

          unshiftSubtitle();
        }
      });
    } else {
      setState(() {
        visible = false;
      });
      _playerScope.openMenuInFullScreen.value = false;

      unshiftSubtitle();
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    _timer?.cancel();
    _volumeTimer?.cancel();
    _seekBarDeltaValueNotifier.dispose();
    // for (final subscription in subscriptions) {
    //   subscription.cancel();
    // }
    subscriptions.cancelAll();

    // --------------------------------------------------
    // package:screen_brightness
    Future.microtask(() async {
      try {
        await ScreenBrightness().resetScreenBrightness();
      } catch (_) {}
    });
    // --------------------------------------------------
    super.dispose();
  }

  void onDoubleTapSeekBackward() {
    setState(() {
      _mountSeekBackwardButton = true;
    });
  }

  void onDoubleTapSeekForward() {
    setState(() {
      _mountSeekForwardButton = true;
    });
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_dragInitialDelta == Offset.zero) {
      _dragInitialDelta = details.localPosition;
      return;
    }

    final diff = _dragInitialDelta.dx - details.localPosition.dx;
    final duration = controller(context).player.state.duration.inSeconds;
    final position = controller(context).player.state.position.inSeconds;

    final seconds =
        -(diff * duration / _theme(context).horizontalGestureSensitivity)
            .round();
    final relativePosition = position + seconds;

    if (relativePosition <= duration && relativePosition >= 0) {
      setState(() {
        swipeDuration = seconds;
        showSwipeDuration = true;
        _seekBarDeltaValueNotifier.value = Duration(seconds: seconds);
      });
    }
  }

  void onHorizontalDragEnd() {
    if (swipeDuration != 0) {
      Duration newPosition = controller(context).player.state.position +
          Duration(seconds: swipeDuration);
      newPosition = newPosition.clamp(
        Duration.zero,
        controller(context).player.state.duration,
      );
      controller(context).player.seek(newPosition);
    }

    setState(() {
      _dragInitialDelta = Offset.zero;
      showSwipeDuration = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();

    final orientation = MediaQuery.orientationOf(context);
    final isPortrait = orientation == Orientation.portrait;

    PlayerScope scope =
        PlayerScope.of(PlayerView.videoStateKey.currentContext!);
    final seekOnDoubleTapEnabledWhileControlsAreVisible =
        (_theme(context).seekOnDoubleTap &&
            _theme(context).seekOnDoubleTapEnabledWhileControlsVisible);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (scope.playerArgs.forceEnterFullScreen && isFullscreen(context)) {
          addPostFrameCallback((timer) =>
              Navigator.of(PlayerView.videoStateKey.currentContext!).pop());
        }
      },
      child: Material(
        elevation: 0.0,
        borderOnForeground: false,
        animationDuration: Duration.zero,
        color: const Color(0x00000000),
        shadowColor: const Color(0x00000000),
        surfaceTintColor: const Color(0x00000000),
        child: Focus(
          autofocus: true,
          child: ValueListenableBuilder(
            valueListenable: scope.showAnimeSkip,
            builder: (context, value, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  if (isFullscreen(context) && value && mount)
                    Positioned.fill(
                      child: AnimatedModalBarrier(
                        barrierSemanticsDismissible: value,
                        color: CurvedAnimation(
                          parent: scope.animationController,
                          curve: Curves.ease,
                        ).drive(
                          ColorTween(
                            begin: Colors.black54,
                            end: Colors.black54,
                          ).chain(
                            CurveTween(curve: Curves.ease),
                          ),
                        ),
                        onDismiss: () {
                          scope.showAnimeSkip.value = false;
                        },
                      ),
                    )
                  else ...[
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: onTap,
                        onDoubleTapDown: _lockPlayer ? null : _handleTapDown,
                        // onLongPress: _handleLongPress,
                        // onLongPressEnd: _handleLongPressEnd,
                        onDoubleTap: _lockPlayer
                            ? null
                            : () {
                                if (_tapPosition != null &&
                                    _tapPosition!.dx >
                                        MediaQuery.of(context).size.width / 2) {
                                  if ((!mount) ||
                                      seekOnDoubleTapEnabledWhileControlsAreVisible) {
                                    onDoubleTapSeekForward();
                                  }
                                } else {
                                  if ((!mount) ||
                                      seekOnDoubleTapEnabledWhileControlsAreVisible) {
                                    onDoubleTapSeekBackward();
                                  }
                                }
                              },
                        onHorizontalDragUpdate: _lockPlayer
                            ? null
                            : (details) {
                                if ((!mount)) {
                                  onHorizontalDragUpdate(details);
                                }
                              },
                        onHorizontalDragEnd: _lockPlayer
                            ? null
                            : (details) {
                                onHorizontalDragEnd();
                              },
                        onVerticalDragUpdate: _lockPlayer
                            ? null
                            : (details) async {
                                final delta = details.delta.dy;
                                final Offset position = details.localPosition;

                                if (position.dx <=
                                    MediaQuery.of(context).size.width / 2) {
                                  if (!mount) {
                                    final brightness = _brightnessValue -
                                        delta /
                                            _theme(context)
                                                .verticalGestureSensitivity;
                                    final result = brightness.clamp(0.0, 1.0);
                                    setBrightness(result);
                                  }
                                } else {
                                  if (!mount) {
                                    final volume = _volumeValue -
                                        delta /
                                            _theme(context)
                                                .verticalGestureSensitivity;
                                    final result = volume.clamp(0.0, 1.0);
                                    setVolume(result);
                                  }
                                }
                              },
                        child: AnimatedOpacity(
                          curve: Curves.easeInOut,
                          opacity: visible ? 1.0 : 0.0,
                          duration: _theme(context).controlsTransitionDuration,
                          child: Container(
                            padding: EdgeInsets.zero,
                            color: _theme(context).backdropColor ??
                                Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    if (!mount || seekOnDoubleTapEnabledWhileControlsAreVisible)
                      if (_mountSeekBackwardButton || _mountSeekForwardButton)
                        Positioned.fill(
                          child: Row(
                            children: [
                              Expanded(
                                child: _mountSeekBackwardButton
                                    ? TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                          begin: 0.0,
                                          end: _hideSeekBackwardButton
                                              ? 0.0
                                              : 1.0,
                                        ),
                                        duration:
                                            const Duration(milliseconds: 200),
                                        builder: (context, value, child) =>
                                            Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                        onEnd: () {
                                          if (_hideSeekBackwardButton) {
                                            setState(() {
                                              _hideSeekBackwardButton = false;
                                              _mountSeekBackwardButton = false;
                                            });
                                          }
                                        },
                                        child: _BackwardSeekIndicator(
                                          onChanged: (value) {
                                            _seekBarDeltaValueNotifier.value =
                                                -value;
                                          },
                                          onSubmitted: (value) {
                                            setState(() {
                                              _hideSeekBackwardButton = true;
                                            });
                                            var result = controller(context)
                                                    .player
                                                    .state
                                                    .position -
                                                value;
                                            result = result.clamp(
                                              Duration.zero,
                                              controller(context)
                                                  .player
                                                  .state
                                                  .duration,
                                            );
                                            controller(context)
                                                .player
                                                .seek(result);
                                          },
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              Expanded(
                                child: _mountSeekForwardButton
                                    ? TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                          begin: 0.0,
                                          end: _hideSeekForwardButton
                                              ? 0.0
                                              : 1.0,
                                        ),
                                        duration:
                                            const Duration(milliseconds: 200),
                                        builder: (context, value, child) =>
                                            Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                        onEnd: () {
                                          if (_hideSeekForwardButton) {
                                            setState(() {
                                              _hideSeekForwardButton = false;
                                              _mountSeekForwardButton = false;
                                            });
                                          }
                                        },
                                        child: _ForwardSeekIndicator(
                                          onChanged: (value) {
                                            _seekBarDeltaValueNotifier.value =
                                                value;
                                          },
                                          onSubmitted: (value) {
                                            setState(() {
                                              _hideSeekForwardButton = true;
                                            });
                                            var result = controller(context)
                                                    .player
                                                    .state
                                                    .position +
                                                value;
                                            result = result.clamp(
                                              Duration.zero,
                                              controller(context)
                                                  .player
                                                  .state
                                                  .duration,
                                            );
                                            controller(context)
                                                .player
                                                .seek(result);
                                          },
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                  ],
                  if (isFullscreen(context) &&
                      scope.playerArgs.times.isNotEmpty &&
                      mount)
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomPopup(
                        duration: const Duration(milliseconds: 200),
                        width: 170,
                        show: value,
                        paddingTop: true,
                        shape: RoundedRectangleBorder(),
                        height: MediaQuery.sizeOf(context).height,
                        items: scope.playerArgs.times,
                        builderFunction: (context, index, item) {
                          return ValueListenableBuilder(
                            valueListenable: scope.selectedAnimeTimeStamp,
                            builder: (context, value, child) {
                              return ListTile(
                                dense: true,
                                onTap: () => scope.onClickSkipAnime.call(item),
                                selected: value?.id.contains(item.id) ?? false,
                                leading: Text(
                                  Duration(microseconds: item.at).label(),
                                ),
                                title: Text(item.timeStampType.label),
                                visualDensity: const VisualDensity(
                                  vertical: -4,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  Positioned(
                    right: isFullscreen(context) && value ? 170 : 0,
                    left: 0,
                    bottom: 0,
                    top: 0,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        IgnorePointer(
                            child: Center(child: _CustomIndicator(this))),
                        IgnorePointer(child: _BufferingIndicator(this)),
                        _Controlls(this),
                        IgnorePointer(
                          child: Padding(
                            padding: (isFullscreen(context)
                                ? MediaQuery.of(context).padding
                                : EdgeInsets.zero),
                            child: AnimatedOpacity(
                              duration:
                                  _theme(context).controlsTransitionDuration,
                              opacity: _speedUpIndicator ? 1 : 0,
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  margin: const EdgeInsets.all(16.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0x88000000),
                                    borderRadius: BorderRadius.circular(64.0),
                                  ),
                                  height: 48.0,
                                  width: 108.0,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Text(
                                          '${_theme(context).speedUpFactor.toStringAsFixed(1)}x',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 48.0,
                                        width: 48.0 - 16.0,
                                        alignment: Alignment.centerRight,
                                        child: const Icon(
                                          Icons.fast_forward,
                                          color: Color(0xFFFFFFFF),
                                          size: 24.0,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!mount)
                          if (_mountSeekBackwardButton |
                                  _mountSeekForwardButton ||
                              showSwipeDuration)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: IgnorePointer(
                                child: isFullscreen(context)
                                    ? SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: _MaterialSeekBar(
                                            this,
                                            delta: _seekBarDeltaValueNotifier,
                                          ),
                                        ),
                                      )
                                    : _MaterialSeekBar(
                                        this,
                                        delta: _seekBarDeltaValueNotifier,
                                      ),
                              ),
                            ),
                        IgnorePointer(
                          child: Center(
                            child: AnimatedOpacity(
                              duration:
                                  _theme(context).controlsTransitionDuration,
                              opacity: showSwipeDuration ? 1 : 0,
                              child: _theme(context).seekIndicatorBuilder?.call(
                                      context,
                                      Duration(seconds: swipeDuration)) ??
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0x88000000),
                                      borderRadius: BorderRadius.circular(64.0),
                                    ),
                                    height: 52.0,
                                    width: 108.0,
                                    child: Text(
                                      swipeDuration > 0
                                          ? "+ ${Duration(seconds: swipeDuration).label()}"
                                          : "- ${Duration(seconds: swipeDuration).label()}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),

                        if (!value) ...[
                          Padding(
                            padding: EdgeInsets.only(top: !isPortrait ? 20 : 8),
                            child: PlayerCustomOverlay(
                              key: const ValueKey('custom_overlay_1'),
                              begin: const Offset(-1, 0),
                              notifierChange: scope.overlayBoxFit,
                            ),
                          ),
                          Positioned(
                            bottom: !isPortrait ? 100 : 70,
                            right: 0,
                            top: 0,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: PlayerCustomOverlay(
                                reversedBorder: true,
                                key: const ValueKey('custom_overlay_2'),
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                                enableCancelReversed: false,
                                notifierChange: scope.overlayNextEpisode,
                                onTap: scope.onTapEpisodeInOverlay,
                              ),
                            ),
                          ),
                        ],

                        // if (isFullscreen(context))
                        //   ValueListenableBuilder(
                        //     valueListenable: scope.openMenuInFullScreen,
                        //     builder: (context, value, _) => AnimatedPositioned(
                        //       duration: const Duration(milliseconds: 350),
                        //       width: value ? 200 : 0,
                        //       child: const SizedBox.shrink(),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MaterialSeekBar extends StatefulWidget {
  const _MaterialSeekBar(
    this.state, {
    this.delta,
    this.onSeekStart,
    this.onSeekEnd,
  });
  final _CustomMaterialControlsState state;
  final ValueNotifier<Duration>? delta;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;
  @override
  State<_MaterialSeekBar> createState() => _MaterialSeekBarState();
}

class _MaterialSeekBarState extends State<_MaterialSeekBar> {
  final List<StreamSubscription> subscriptions = [];
  bool tapped = false;
  late bool playing = controller(context).player.state.playing;
  late Duration position = controller(context).player.state.position;
  late Duration duration = controller(context).player.state.duration;
  late Duration buffer = controller(context).player.state.buffer;

  @override
  void initState() {
    super.initState();
    widget.delta?.addListener(listener);
  }

  @override
  void didChangeDependencies() {
    if (subscriptions.isEmpty && widget.delta == null) {
      subscriptions.addAll(
        [
          controller(context).player.stream.playing.listen((event) {
            setState(() {
              playing = event;
            });
          }),
          controller(context).player.stream.completed.listen((event) {
            setState(() {
              position = Duration.zero;
            });
          }),
          controller(context).player.stream.position.listen((event) {
            setState(() {
              if (!tapped) {
                position = event;
              }
            });
          }),
          controller(context).player.stream.duration.listen((event) {
            setState(() {
              duration = event;
            });
          }),
          controller(context).player.stream.buffer.listen((event) {
            setState(() {
              buffer = event;
            });
          }),
        ],
      );
    }
    super.didChangeDependencies();
  }

  void listener() {
    setState(() {
      final delta = widget.delta?.value ?? position;
      position = controller(context).player.state.position + delta;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _onChangeStart(double value) {
    final state = widget.state;
    state._timer?.cancel();
    setState(() => tapped = true);

    widget.onSeekStart?.call();
  }

  void _onChangeEnd(double value) {
    setState(() => tapped = false);

    final newPosition = Duration(milliseconds: value.toInt());
    controller(context).player.seek(newPosition);

    widget.onSeekEnd?.call();
    _disableVisible();
  }

  void _disableVisible() {
    final state = widget.state;
    state._timer?.cancel();

    state._timer = Timer(_theme(context).controlsHoverDuration, () {
      if (state.mounted) {
        state.setState(() => state.visible = false);
        state.unshiftSubtitle();
      }
    });
  }

  void _onChanged(double value) {
    setState(() => tapped = true);

    final newPosition = Duration(milliseconds: value.toInt());

    setState(() {
      position = newPosition;
    });

    _disableVisible();
  }

  @override
  Widget build(BuildContext context) {
    bool disableSlider = duration.inMilliseconds == 0;
    bool disableBufferSlider =
        buffer.inMilliseconds > duration.inMilliseconds.toDouble();

    final lockPlayer = widget.state._lockPlayer;

    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 14,
        showValueIndicator: ShowValueIndicator.always,
        thumbShape: RoundSliderThumbShape(),
      ),
      child: SizedBox(
        height: 38,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 8),
          child: Slider.adaptive(
            divisions: null,
            label: position.label(),
            secondaryTrackValue:
                disableBufferSlider ? null : buffer.inMilliseconds.toDouble(),
            value: disableSlider ? 0.0 : position.inMilliseconds.toDouble(),
            max: disableSlider ? 1.0 : duration.inMilliseconds.toDouble(),
            onChangeStart: lockPlayer || disableSlider ? null : _onChangeStart,
            onChangeEnd: lockPlayer || disableSlider ? null : _onChangeEnd,
            onChanged: lockPlayer || disableSlider ? null : _onChanged,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.delta?.removeListener(listener);
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

class _Controlls extends StatefulWidget {
  const _Controlls(this.state);
  final _CustomMaterialControlsState state;

  @override
  State<_Controlls> createState() => _ControllsState();
}

class _ControllsState extends State<_Controlls>
    with SingleTickerProviderStateMixin, SubscriptionsMixin {
  late Duration _position = controller(context).player.state.position;
  late Duration _duration = controller(context).player.state.duration;

  late final PlayerScope _playerScope =
      PlayerScope.of(PlayerView.videoStateKey.currentContext!);

  late final AnimationController _animation = AnimationController(
    vsync: this,
    value: controller(context).player.state.playing ? 1 : 0,
    duration: const Duration(milliseconds: 200),
  );

  bool get _reversedCurrentDuration =>
      _playerScope.reversedCurrentDuration.value;

  set setReversedCurrentDuration(bool reversedCurrentDuration) {
    if (!mounted) return;
    setState(() {
      _playerScope.reversedCurrentDuration.value = reversedCurrentDuration;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty) {
      subscriptions.addAll(
        [
          controller(context).player.stream.position.listen((event) {
            setState(() {
              _position = event;
            });
          }),
          controller(context).player.stream.duration.listen((event) {
            setState(() {
              _duration = event;
            });
          }),
          controller(context).player.stream.playing.listen((event) {
            if (event) {
              _animation.forward();
            } else {
              _animation.reverse();
            }
          }),
        ],
      );
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayerScope scope =
        PlayerScope.of(PlayerView.videoStateKey.currentContext!);

    final container = IgnorePointer(
      ignoring: !widget.state.visible,
      child: AnimatedOpacity(
        curve: Curves.easeInOut,
        opacity: widget.state.visible ? 1.0 : 0.0,
        duration: _theme(context).controlsTransitionDuration,
        onEnd: () {
          setState(() {
            if (!widget.state.visible) {
              widget.state.mount = false;
            }
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.state.mount)
              _LockWidget(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: isFullscreen(context)
                      ? Padding(
                          // padding: EdgeInsets.zero,
                          padding: isFullscreen(context)
                              ? const EdgeInsets.only(
                                  top: 18.0,
                                  right: 10,
                                  left: 10,
                                )
                              : EdgeInsets.zero,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisSize: MainAxisSize.max,
                            children: [
                              ValueListenableBuilder(
                                valueListenable: scope.topTitle,
                                builder: (context, value, child) => Text(
                                  value,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: const Color(0xFFFFFFFF),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SafeArea(
                          child: Padding(
                            // padding: EdgeInsets.zero,
                            padding: isFullscreen(context)
                                ? const EdgeInsets.only(
                                    top: 18.0,
                                    right: 10,
                                    left: 10,
                                  )
                                : EdgeInsets.zero,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisSize: MainAxisSize.max,
                              children: [
                                ValueListenableBuilder(
                                  valueListenable: scope.topTitle,
                                  builder: (context, value, child) => Text(
                                    value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: const Color(0xFFFFFFFF),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            Center(
              child: AnimatedOpacity(
                curve: Curves.easeInOut,
                opacity: widget.state.buffering ? 0.0 : 1.0,
                duration: _theme(context).controlsTransitionDuration,
                child: IconButton(
                  onPressed: controller(context).player.playOrPause,
                  iconSize: 48,
                  padding: EdgeInsets.zero,
                  icon: IgnorePointer(
                    child: AnimatedIcon(
                      progress: _animation,
                      icon: AnimatedIcons.play_pause,
                    ),
                  ),
                ),
              ),
            ),
            _BottomButtons(this),
          ],
        ),
      ),
    );

    // final orientation = MediaQuery.orientationOf(context);

    // if (orientation == Orientation.landscape) {
    //   return SafeArea(child: container);
    // }
    return container;
  }
}

class _BottomButtons extends StatelessWidget {
  const _BottomButtons(this.state);

  final _ControllsState state;

  @override
  Widget build(BuildContext context) {
    final PlayerScope scope =
        PlayerScope.of(PlayerView.videoStateKey.currentContext!);
    // final hiveController = context.read<HiveController>();
    final fullscreen = isFullscreen(context);

    Widget buttons = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          // textDirection: Directionality.of(context),
          children: [
            _LockWidget(
              child: Container(
                padding: const EdgeInsets.only(left: 18),
                child: TextButton(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity(vertical: -4),
                  ),
                  onPressed: () {
                    state.setReversedCurrentDuration =
                        !state._reversedCurrentDuration;
                  },
                  child: Text(
                    state._reversedCurrentDuration
                        ? "-${(state._duration - state._position).label(reference: state._duration)} / ${state._duration.label(reference: state._duration)}"
                        : '${state._position.label(reference: state._duration)} / ${state._duration.label(reference: state._duration)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFFFFFFFF),
                        ),
                  ),
                ),
              ),
            ),
            if (isFullscreen(context) && scope.playerArgs.times.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              TextButton(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.only(left: 10)),
                  visualDensity: VisualDensity(vertical: -4),
                ),
                onLongPress: () {
                  scope.showAnimeSkip.value = !scope.showAnimeSkip.value;
                  // Timer(const Duration(seconds: 20), () {
                  //   scope.showAnimeSkip.value = false;
                  // });
                },
                onPressed: () {},
                child: ValueListenableBuilder(
                  valueListenable: scope.selectedAnimeTimeStamp,
                  builder: (context, value, child) => Text(
                    value?.timeStampType.label ?? '',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (scope.isPipAvailable)
              _LockWidget(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(vertical: -4),
                  onPressed: scope.enterInPip,
                  iconSize: 22,
                  icon: Icon(MdiIcons.pictureInPictureBottomRight),
                ),
              ),
            _LockWidget(
              child: IconButton(
                padding: EdgeInsets.zero,
                visualDensity: const VisualDensity(vertical: -4),
                onPressed: scope.setFits,
                iconSize: 22,
                icon: Icon(MdiIcons.fitToScreen),
              ),
            ),
            if (isFullscreen(context))
              _LockWidget(
                child: Stack(
                  children: [
                    IconButton(
                      visualDensity: const VisualDensity(vertical: -4),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        scope.openMenuInFullScreen.value =
                            !scope.openMenuInFullScreen.value;
                      },
                      iconSize: 22,
                      icon: Icon(MdiIcons.menu),
                    ),
                    ValueListenableBuilder(
                        valueListenable: scope.openMenuInFullScreen,
                        builder: (context, open, _) {
                          return CustomPopup(
                            height: MediaQuery.of(context).size.height / 1.4,
                            width: 105,
                            show: open,
                            items: scope.playerArgs.anime.releases,
                            builderFunction: (context, index, episode) {
                              final cardTheme = CardTheme.of(context);

                              final borderRadius =
                                  ((cardTheme.shape as RoundedRectangleBorder?)
                                      ?.borderRadius as BorderRadius?);

                              return ListTile(
                                titleAlignment: ListTileTitleAlignment.center,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: index == 0
                                        ? borderRadius?.topLeft ??
                                            const Radius.circular(8)
                                        : Radius.zero,
                                    topRight: index == 0
                                        ? borderRadius?.topLeft ??
                                            const Radius.circular(8)
                                        : Radius.zero,
                                    bottomLeft: index ==
                                            scope.playerArgs.anime.releases
                                                    .length -
                                                1
                                        ? borderRadius?.topLeft ??
                                            const Radius.circular(8)
                                        : Radius.zero,
                                    bottomRight: index ==
                                            scope.playerArgs.anime.releases
                                                    .length -
                                                1
                                        ? borderRadius?.topLeft ??
                                            const Radius.circular(8)
                                        : Radius.zero,
                                  ),
                                ),
                                onTap: () {
                                  customLog(
                                    'tapped name: ${episode.title} - id: ${episode.stringID}',
                                  );
                                  scope.onTapEpisode(episode);
                                },
                                onLongPress: () {
                                  scope.openMenuInFullScreen.value = false;
                                },
                                selected: episode.stringID.contains(
                                    scope.playerArgs.episode.stringID),
                                titleTextStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                title: Text(
                                  'Episódio ${episode.number}',
                                ),
                              );
                            },
                          );
                        }),
                  ],
                ),
              ),
            IconButton(
              visualDensity: const VisualDensity(vertical: -4),
              padding: EdgeInsets.zero,
              onPressed: () {
                state.widget.state.setLockPlayer =
                    !state.widget.state._lockPlayer;
              },
              iconSize: 22,
              icon: Icon(MdiIcons.lock),
            ),
            _LockWidget(
              child: Container(
                width: 65,
                padding: const EdgeInsets.only(
                  right: 30,
                ),
                child: IconButton(
                  visualDensity: const VisualDensity(vertical: -4),
                  onPressed: () {
                    toggleFullscreen(context);
                    if (scope.showAnimeSkip.value) {
                      scope.showAnimeSkip.value = !scope.showAnimeSkip.value;
                    }

                    if (scope.playerArgs.forceEnterFullScreen &&
                        isFullscreen(context)) {
                      WidgetsBinding.instance.addPostFrameCallback((timer) {
                        Navigator.of(PlayerView.videoStateKey.currentContext!)
                            .pop();
                      });
                    }
                  },
                  iconSize: 22,
                  icon: fullscreen
                      ? Icon(MdiIcons.fullscreenExit)
                      : Icon(MdiIcons.fullscreen),
                ),
              ),
            ),
          ],
        ),
        _MaterialSeekBar(
          state.widget.state,
          onSeekStart: state.widget.state._timer?.cancel,
          onSeekEnd: () {
            state.widget.state._timer = Timer(
              _theme(context).controlsHoverDuration,
              () {
                if (context.mounted) {
                  state.setState(() {
                    state.widget.state.visible = false;
                  });
                  state.widget.state.unshiftSubtitle();
                }
              },
            );
          },
        ),
      ],
    );

    if (isFullscreen(context)) {
      buttons = Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(child: buttons),
      );
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: buttons,
    );
  }
}

class _LockWidget extends StatelessWidget {
  const _LockWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state =
        context.findAncestorStateOfType<_CustomMaterialControlsState>();
    // if (state?._lockPlayer == true) return const SizedBox.shrink();
    return IgnorePointer(
      ignoring: state?._lockPlayer == true,
      child: AnimatedOpacity(
        curve: Curves.fastLinearToSlowEaseIn,
        duration: const Duration(milliseconds: 350),
        opacity: state?._lockPlayer == true ? 0.0 : 1.0,
        child: child,
      ),
    );
  }
}

class _BufferingIndicator extends StatelessWidget {
  const _BufferingIndicator(this.state);
  final _CustomMaterialControlsState state;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: (isFullscreen(context)
            ? MediaQuery.of(context).padding
            : EdgeInsets.zero),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0.0,
              end: state.buffering ? 1.0 : 0.0,
            ),
            duration: _theme(context).controlsTransitionDuration,
            builder: (context, value, child) {
              if (value > 0.0) {
                return Opacity(
                  opacity: value,
                  child: _theme(context)
                          .bufferingIndicatorBuilder
                          ?.call(context) ??
                      child!,
                );
              }
              return const SizedBox.shrink();
            },
            child: const CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }
}

class _CustomIndicator extends StatelessWidget {
  const _CustomIndicator(this.state);
  final _CustomMaterialControlsState state;

  @override
  Widget build(BuildContext context) {
    double opacity = 0.0;

    if ((!state.mount || _theme(context).gesturesEnabledWhileControlsVisible) &&
            state._volumeIndicator ||
        state._brightnessIndicator) {
      opacity = 1.0;
    }

    String text = '';

    if (state._volumeIndicator && !state._brightnessIndicator) {
      text = '${(state._volumeValue * 100.0).round()}%';
    } else if (state._brightnessIndicator) {
      text = '${(state._brightnessValue * 100.0).round()}%';
    }

    return IgnorePointer(
      child: AnimatedOpacity(
        curve: Curves.easeInOut,
        opacity: opacity,
        duration: _theme(context).controlsTransitionDuration,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x88000000),
            borderRadius: BorderRadius.circular(64.0),
          ),
          height: 52.0,
          width: 108.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (state._volumeIndicator)
                Builder(
                  builder: (context) {
                    IconData icon = MdiIcons.volumeOff;
                    if (state._volumeValue < 0.5) {
                      icon = MdiIcons.volumeMinus;
                    } else {
                      icon = MdiIcons.volumePlus;
                    }
                    return Container(
                      height: 52.0,
                      width: 42.0,
                      alignment: Alignment.centerRight,
                      child: Icon(
                        icon,
                        color: const Color(0xFFFFFFFF),
                        size: 24.0,
                      ),
                    );
                  },
                )
              else if (state._brightnessIndicator)
                Builder(
                  builder: (context) {
                    IconData icon = MdiIcons.brightness5;
                    if (state._brightnessValue < 2.0 / 3.0) {
                      icon = MdiIcons.brightness6;
                    } else {
                      icon = MdiIcons.brightness7;
                    }
                    return Container(
                      height: 52.0,
                      width: 42.0,
                      alignment: Alignment.centerRight,
                      child: Icon(
                        icon,
                        color: const Color(0xFFFFFFFF),
                        size: 24.0,
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackwardSeekIndicator extends StatefulWidget {
  final void Function(Duration) onChanged;
  final void Function(Duration) onSubmitted;
  const _BackwardSeekIndicator({
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_BackwardSeekIndicator> createState() => _BackwardSeekIndicatorState();
}

class _BackwardSeekIndicatorState extends State<_BackwardSeekIndicator> {
  Duration value = const Duration(seconds: 10);

  Timer? timer;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
    });
  }

  void increment() {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
    });
    widget.onChanged.call(value);
    setState(() {
      value += const Duration(seconds: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x88767676),
            Color(0x00767676),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: InkWell(
        splashColor: const Color(0x44767676),
        onTap: increment,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.fast_rewind,
                size: 24.0,
                color: Color(0xFFFFFFFF),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${value.inSeconds} seconds',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForwardSeekIndicator extends StatefulWidget {
  final void Function(Duration) onChanged;
  final void Function(Duration) onSubmitted;
  const _ForwardSeekIndicator({
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_ForwardSeekIndicator> createState() => _ForwardSeekIndicatorState();
}

class _ForwardSeekIndicatorState extends State<_ForwardSeekIndicator> {
  Duration value = const Duration(seconds: 10);

  Timer? timer;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
    });
  }

  void increment() {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
    });
    widget.onChanged.call(value);
    setState(() {
      value += const Duration(seconds: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x00767676),
            Color(0x88767676),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: InkWell(
        splashColor: const Color(0x44767676),
        onTap: increment,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.fast_forward,
                size: 24.0,
                color: Color(0xFFFFFFFF),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${value.inSeconds} seconds',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
