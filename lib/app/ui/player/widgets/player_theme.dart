import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlayerTheme extends StatelessWidget {
  const PlayerTheme({
    super.key,
    required this.child,
    required this.setFits,
  });

  final Widget child;

  final VoidCallback setFits;

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
    return MaterialVideoControlsThemeData(
      primaryButtonBar: const [
        Spacer(flex: 2),
        // MaterialSkipPreviousButton(),
        Spacer(),
        MaterialPlayOrPauseButton(iconSize: 48.0),
        Spacer(),
        // MaterialSkipNextButton(),
        Spacer(flex: 2),
      ],
      seekBarThumbSize: 14,
      buttonBarButtonSize: 24.0,
      padding: EdgeInsets.zero,
      seekBarPositionColor: colorScheme.primary,
      buttonBarButtonColor: Colors.white,
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: setFits,
          iconSize: 24,
          icon: Icon(MdiIcons.fitToScreen),
        ),
        MaterialFullscreenButton(
          icon: Icon(MdiIcons.fullscreen),
        ),
      ],
      volumeGesture: true,
      brightnessGesture: true,
      displaySeekBar: true,
      automaticallyImplySkipNextButton: false,
      automaticallyImplySkipPreviousButton: false,
      seekBarHeight: 4,
    );
  }

  MaterialVideoControlsThemeData _fullscreen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.paddingOf(context);
    return MaterialVideoControlsThemeData(
      primaryButtonBar: const [
        Spacer(flex: 2),
        // MaterialSkipPreviousButton(),
        Spacer(),
        MaterialPlayOrPauseButton(iconSize: 48.0),
        Spacer(),
        // MaterialSkipNextButton(),
        Spacer(flex: 2),
      ],
      seekBarHeight: 4,
      padding: padding.copyWith(
        right: 20,
        left: 46,
        bottom: padding.bottom + 32,
      ),
      seekBarPositionColor: colorScheme.primary,
      buttonBarButtonSize: 24.0,
      buttonBarButtonColor: Colors.white,
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: setFits,
          iconSize: 24,
          icon: Icon(MdiIcons.fitToScreen),
        ),
        MaterialFullscreenButton(
          icon: Icon(MdiIcons.fullscreen),
        ),
      ],
      volumeGesture: true,
      brightnessGesture: true,
      displaySeekBar: true,
      automaticallyImplySkipNextButton: false,
      automaticallyImplySkipPreviousButton: false,
    );
  }
}
