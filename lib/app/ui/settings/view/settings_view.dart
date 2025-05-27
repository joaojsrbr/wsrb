import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // late final ThemeController _themeController;

  final Debouncer _debouncerColor =
      Debouncer(duration: const Duration(milliseconds: 200));

  // List<Color> _recentColors = [];

  // double _sliderValue = 0.0;

  // late final Queue<ThemeMode> _themeModeQueue;

  @override
  void dispose() {
    _debouncerColor.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _themeController = context.read<ThemeController>();
    // _recentColors.add(_themeController.appColor);
    // _themeModeQueue = Queue.from(ThemeMode.values.where(test));
    // _sliderValue = context.read<HiveController>().historicSavePercent;
  }

  // bool test(ThemeMode element) {
  //   return element != _themeController.themeMode;
  // }

  // Future<void> _setThemeMode() async {
  //   final ThemeMode newThemeMode = _themeModeQueue.removeFirst();
  //   _themeModeQueue.addLast(_themeController.themeMode);
  //   await _themeController.setThemeMode(newThemeMode);
  // }

  @override
  Widget build(BuildContext context) {
    customLog('$widget[build]');

    final ThemeData themeData = Theme.of(context);
    final AppConfigController appConfigController =
        context.watch<AppConfigController>();
    // final ThemeController themeController = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(leading: BackButton()),
      body: SettingsList(
        contentPadding: const EdgeInsets.only(top: 8, bottom: 20),
        brightness: themeData.brightness,
        darkTheme: SettingsThemeData(
          tileHighlightColor: themeData.highlightColor,
          settingsListBackground: themeData.scaffoldBackgroundColor,
        ),
        lightTheme: SettingsThemeData(
          tileHighlightColor: themeData.highlightColor,
          settingsListBackground: themeData.scaffoldBackgroundColor,
        ),
        sections: [
          // _CustomSettingsSection(
          //   title: Text(
          //     'Geral',
          //     style: themeData.textTheme.titleLarge?.copyWith(
          //       color: themeData.colorScheme.primary,
          //     ),
          //   ),
          //   tiles: [
          //     _PersonCustomSettingsTile(
          //       child: LayoutBuilder(builder: (context, boxConstraints) {
          //         final connectivityResult = hiveController
          //                     .connectivityResult ==
          //                 ConnectivityResult.none
          //             ? 'Todos'
          //             : StringExtensions(hiveController.connectivityResult.name)
          //                 .capitalize;

          //         return PopupMenuButton(
          //           padding: EdgeInsets.zero,
          //           initialValue: hiveController.connectivityResult,
          //           tooltip: connectivityResult,
          //           onSelected: hiveController.setConnectivityResult,
          //           constraints: boxConstraints,
          //           offset: const Offset(0, 65),
          //           child: IgnorePointer(
          //             child: SettingsTile(
          //               leading: Icon(MdiIcons.download),
          //               title: const Text('Download'),
          //               trailing: Padding(
          //                 padding: const EdgeInsets.only(right: 8.0),
          //                 child: Text(
          //                   connectivityResult,
          //                   style: themeData.textTheme.titleSmall?.copyWith(),
          //                 ),
          //               ),
          //             ),
          //           ),
          //           // position:  RelativeRect.fromLTRB(left, top + 5, right, 0.0),
          //           itemBuilder: (context) {
          //             return [
          //               ConnectivityResult.none,
          //               ConnectivityResult.wifi,
          //               ConnectivityResult.mobile,
          //               ConnectivityResult.bluetooth,
          //             ].map((e) {
          //               return PopupMenuItem(
          //                 value: e,
          //                 enabled: hiveController.connectivityResult != e,
          //                 child: ListTile(
          //                   title: Text(e == ConnectivityResult.none
          //                       ? 'Todos'
          //                       : StringExtensions(e.name).capitalize),
          //                 ),
          //               );
          //             }).toList();
          //           },
          //         );
          //       }),
          //     ),
          //   ],
          // ),
          // _CustomSettingsSection(
          //   title: Text(
          //     'Aparência',
          //     style: themeData.textTheme.titleLarge?.copyWith(
          //       color: themeData.colorScheme.primary,
          //     ),
          //   ),
          //   tiles: <SettingsTile>[
          //     SettingsTile.navigation(
          //       onPressed: (context) async => _setThemeMode(),
          //       leading: Builder(
          //         builder: (context) {
          //           bool enableSecondChild;
          //           Widget icon;
          //           switch (themeController.themeMode) {
          //             case ThemeMode.dark:
          //               enableSecondChild = true;
          //               icon = Icon(MdiIcons.brightness3);
          //             case ThemeMode.light:
          //               enableSecondChild = false;
          //               icon = Icon(MdiIcons.brightness5);
          //             case ThemeMode.system:
          //               enableSecondChild = true;
          //               icon = Icon(
          //                 MdiIcons.brightnessAuto,
          //                 color: themeData.colorScheme.primary,
          //               );
          //           }
          //           return FadeThroughTransitionSwitcher(
          //             duration: const Duration(milliseconds: 200),
          //             enableSecondChild: enableSecondChild,
          //             secondChild: icon,
          //             child: icon,
          //           );
          //         },
          //       ),
          //       title: const Text('Theme Mode'),
          //       value: FadeThroughTransitionSwitcher.noSecondChild(
          //         child: switch (themeController.themeMode) {
          //           ThemeMode.dark => const Text('Modo Escuro'),
          //           ThemeMode.light => const Text('Modo Claro'),
          //           ThemeMode.system => const Text('Modo Automático'),
          //         },
          //       ),
          //     ),
          //     SettingsTile.switchTile(
          //       onToggle: _themeController.setSystemThemeMode,
          //       initialValue: _themeController.systemThemeMode,
          //       leading: Icon(MdiIcons.formatPaint),
          //       title: const Text('Tema do Sistema'),
          //     ),
          //     SettingsTile.navigation(
          //       onPressed: null,
          //       enabled: !themeController.systemThemeMode,
          //       title: IconTheme(
          //         data: Theme.of(context).iconTheme.copyWith(
          //               color: themeController.systemThemeMode
          //                   ? const Color.fromARGB(255, 118, 117, 122)
          //                   : null,
          //             ),
          //         child: Column(
          //           children: [
          //             Row(
          //               children: [
          //                 if (themeController.appColor !=
          //                     ThemeController.defaultValueAppColor.defaultValue)
          //                   GestureDetector(
          //                     onTap: () async {
          //                       await themeController.setAppColor(
          //                         ThemeController
          //                             .defaultValueAppColor.defaultValue,
          //                       );
          //                       setStateIfMounted(() {
          //                         _recentColors
          //                           ..clear()
          //                           ..add(ThemeController
          //                               .defaultValueAppColor.defaultValue);
          //                       });
          //                     },
          //                     child: Icon(MdiIcons.restore),
          //                   )
          //                 else ...[
          //                   Icon(MdiIcons.formatPaint),
          //                 ],
          //                 const SizedBox(width: 24),
          //                 const Text(
          //                   'Cor do Aplicativo',
          //                   style: TextStyle(
          //                     fontSize: 18,
          //                     fontWeight: FontWeight.w400,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 8),
          //             flex.ColorPicker(
          //               pickersEnabled: const <flex.ColorPickerType, bool>{
          //                 flex.ColorPickerType.primary: true,
          //                 flex.ColorPickerType.both: false,
          //                 flex.ColorPickerType.accent: false,
          //                 flex.ColorPickerType.bw: false,
          //                 flex.ColorPickerType.custom: false,
          //                 flex.ColorPickerType.customSecondary: false,
          //                 flex.ColorPickerType.wheel: false,
          //               },
          //               recentColors: _recentColors,
          //               pickerTypeLabels: const <flex.ColorPickerType, String>{
          //                 flex.ColorPickerType.primary: "Cor Primário",
          //               },
          //               enableTooltips: true,
          //               enableTonalPalette: true,
          //               showColorName: true,
          //               showRecentColors: true,
          //               color: themeController.appColor,
          //               onColorChanged: (value) {
          //                 _debouncerColor.call(() {
          //                   themeController.setAppColor(value);
          //                 });
          //               },
          //               onRecentColorsChanged: (value) {
          //                 setStateIfMounted(() {
          //                   _recentColors = value;
          //                 });
          //               },
          //               onColorChangeEnd: (value) {
          //                 customLog(value);
          //                 themeController.setAppColor(value);
          //               },
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          _CustomSettingsSection(
            title: Text(
              'Player',
              style: themeData.textTheme.titleLarge?.copyWith(
                color: themeData.colorScheme.primary,
              ),
            ),
            tiles: [
              // SettingsTile(
              //   onPressed: null,
              //   leading: Icon(MdiIcons.contentSaveCog),
              //   title: const Text('Salvar histórico quando'),
              //   value: SliderTheme(
              //     data: const SliderThemeData(
              //       thumbShape: RoundSliderThumbShape(),
              //     ),
              //     child: Slider.adaptive(
              //       label: "${(_sliderValue * 100).toString()}%",
              //       value: _sliderValue,
              //       divisions: 8,
              //       onChangeEnd: hiveController.setHistoricSavePercent,
              //       onChanged: (value) {
              //         setStateIfMounted(() => _sliderValue = value);
              //       },
              //     ),
              //   ),
              // ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: false,
                leading: Icon(MdiIcons.brightness7),
                title: const Text('Salvar Brilho'),
              ),
            ],
          )
        ],
      ),
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
    return Card(
      semanticContainer: true,
      margin: const EdgeInsets.only(right: 8, left: 8, bottom: 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        child: super.build(context),
      ),
    );
  }
}

class _PersonCustomSettingsTile extends CustomSettingsTile {
  const _PersonCustomSettingsTile({required super.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        child: super.build(context),
      ),
    );
  }
}
