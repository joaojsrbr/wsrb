import 'dart:collection';

import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsDestination extends StatefulWidget {
  const SettingsDestination({super.key});

  @override
  State<SettingsDestination> createState() => _SettingsDestinationState();
}

class _SettingsDestinationState extends State<SettingsDestination>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final ThemeController _themeController;

  late final Queue<ThemeMode> _themeModeQueue;

  @override
  void initState() {
    super.initState();
    _themeController = context.read<ThemeController>();
    _themeModeQueue = Queue.from(ThemeMode.values.where(test));
  }

  bool test(ThemeMode element) {
    return element != _themeController.themeMode;
  }

  Future<void> _setThemeMode() async {
    final ThemeMode newThemeMode = _themeModeQueue.removeFirst();
    _themeModeQueue.addLast(_themeController.themeMode);
    await _themeController.setThemeMode(newThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;

    return SettingsList(
      brightness: themeData.brightness,
      shrinkWrap: false,
      physics: const NeverScrollableScrollPhysics(),
      darkTheme: SettingsThemeData(
        tileHighlightColor: themeData.highlightColor,
        settingsListBackground: themeData.scaffoldBackgroundColor,
      ),
      lightTheme: SettingsThemeData(
        tileHighlightColor: themeData.highlightColor,
        settingsListBackground: themeData.scaffoldBackgroundColor,
      ),
      sections: [
        _CustomSettingsSection(
          title: Text(
            'Aparência',
            style: textTheme.titleLarge?.copyWith(
              color: themeData.colorScheme.primary,
            ),
          ),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              onPressed: (context) async => await _setThemeMode(),
              leading: Builder(
                builder: (context) {
                  bool enableSecondChild;
                  final themeController = context.watch<ThemeController>();
                  Widget icon;
                  switch (themeController.themeMode) {
                    case ThemeMode.dark:
                      enableSecondChild = true;
                      icon = Icon(MdiIcons.brightness3);
                    case ThemeMode.light:
                      enableSecondChild = false;
                      icon = Icon(MdiIcons.brightness5);
                    case ThemeMode.system:
                      enableSecondChild = true;
                      icon = Icon(
                        MdiIcons.brightnessAuto,
                        color: themeData.colorScheme.primary,
                      );
                  }
                  return FadeThroughTransitionSwitcher(
                    enableSecondChild: enableSecondChild,
                    secondChild: icon,
                    child: icon,
                  );
                },
              ),
              title: const Text('Theme Mode'),
              value: Builder(
                builder: (context) {
                  final themeController = context.watch<ThemeController>();
                  return FadeThroughTransitionSwitcher.noSecondChild(
                    child: switch (themeController.themeMode) {
                      ThemeMode.dark => const Text('Modo Escuro'),
                      ThemeMode.light => const Text('Modo Claro'),
                      ThemeMode.system => const Text('Modo Automático'),
                    },
                  );
                },
              ),
            ),
            SettingsTile.switchTile(
              onToggle: _themeController.setSystemThemeMode,
              initialValue: _themeController.systemThemeMode,
              leading: Icon(MdiIcons.formatPaint),
              title: const Text('Tema do Sistema'),
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomSettingsSection extends SettingsSection {
  const _CustomSettingsSection({
    required super.tiles,
    super.title,
  });

  @override
  Widget build(BuildContext context) {
    final widget = super.build(context);
    return Card(
      semanticContainer: true,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        child: widget,
      ),
    );
  }
}
