// Updated settings_appearance.dart
import '../view/settings_view.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsAppearanceView extends StatelessWidget {
  const SettingsAppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExtendedNestedScrollView(
        // overscrollBehavior: OverscrollBehavior.outer,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [const SliverAppBar.medium(title: Text("Aparência"))];
        },
        onlyOneScrollInBody: true,
        body: SettingsList(
          physics: const BouncingScrollPhysics(),
          lightTheme: settingsThemeData(context),
          darkTheme: settingsThemeData(context),
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.switchTile(
                  title: Text(
                    "Tema escuro",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  initialValue: Theme.of(context).brightness == Brightness.dark,
                  onToggle: (val) {
                    // TODO: implementar troca de tema no seu app
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
