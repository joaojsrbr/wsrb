import 'package:app_wsrb_jsr/app/ui/player/widgets/scope.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlayerTheme extends StatelessWidget {
  const PlayerTheme({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialVideoControlsTheme(
      normal: _normal(context),
      fullscreen: _fullscreen(context),
      child: child,
    );
  }

  MaterialVideoControlsThemeData _normal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final setFits = PlayerScope.of(context).setFits;
    final topTitle = PlayerScope.of(context).topTitle;
    return MaterialVideoControlsThemeData(
      buttonBarHeight: 20,
      bottomButtonBarMargin: const EdgeInsets.only(left: 14),
      topButtonBar: [
        SafeArea(
          child: ValueListenableBuilder(
            valueListenable: topTitle,
            builder: (context, value, child) => Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(),
            ),
          ),
        ),
      ],
      padding: const EdgeInsets.only(top: 12),
      primaryButtonBar: const [
        Spacer(flex: 2),
        // MaterialSkipPreviousButton(),
        Spacer(),
        MaterialPlayOrPauseButton(iconSize: 48.0),
        Spacer(),
        // MaterialSkipNextButton(),
        Spacer(flex: 2),
      ],
      seekBarHeight: 12,
      buttonBarButtonSize: 24,
      seekBarPositionColor: colorScheme.primary,
      buttonBarButtonColor: Colors.white,
      bottomButtonBar: [
        MaterialPositionIndicator(
          style:
              Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12.0),
        ),
        const Spacer(),
        IconButton(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.zero,
          onPressed: setFits,
          iconSize: 24,
          color: Colors.white,
          icon: Icon(MdiIcons.fitToScreen),
        ),
        Builder(builder: (context) {
          return IconButton(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.zero,
            onPressed: () => toggleFullscreen(context),
            iconSize: 24,
            color: Colors.white,
            icon: isFullscreen(context)
                ? Icon(MdiIcons.fullscreenExit)
                : Icon(MdiIcons.fullscreen),
          );
        }),
      ],
      volumeGesture: true,
      brightnessGesture: true,
      displaySeekBar: true,
      automaticallyImplySkipNextButton: false,
      automaticallyImplySkipPreviousButton: false,
    );
  }

  MaterialVideoControlsThemeData _fullscreen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.paddingOf(context);
    final topTitle = PlayerScope.of(context).topTitle;
    final setFits = PlayerScope.of(context).setFits;

    return MaterialVideoControlsThemeData(
      buttonBarHeight: 20,
      seekBarAlignment: Alignment.bottomCenter,
      bottomButtonBarMargin: const EdgeInsets.only(left: 16),
      topButtonBar: [
        ValueListenableBuilder(
          valueListenable: topTitle,
          builder: (context, value, child) => Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(),
          ),
        ),
      ],
      primaryButtonBar: const [
        Spacer(flex: 2),
        // MaterialSkipPreviousButton(),
        Spacer(),
        MaterialPlayOrPauseButton(iconSize: 48.0),
        Spacer(),
        // MaterialSkipNextButton(),
        Spacer(flex: 2),
      ],
      padding: padding.copyWith(
        right: 20,
        left: 46,
        top: 20,
        bottom: padding.bottom + 12,
      ),
      seekBarHeight: 12,
      seekBarPositionColor: colorScheme.primary,
      buttonBarButtonSize: 20,
      buttonBarButtonColor: Colors.white,
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: setFits,
          iconSize: 24,
          color: Colors.white,
          icon: Icon(MdiIcons.fitToScreen),
        ),
        Builder(builder: (context) {
          return IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => toggleFullscreen(context),
            iconSize: 24,
            color: Colors.white,
            icon: isFullscreen(context)
                ? Icon(MdiIcons.fullscreenExit)
                : Icon(MdiIcons.fullscreen),
          );
        }),
      ],
      volumeGesture: true,
      brightnessGesture: true,
      displaySeekBar: true,
      automaticallyImplySkipNextButton: false,
      automaticallyImplySkipPreviousButton: false,
    );
  }
}
