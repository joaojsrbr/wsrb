// Updated settings_view.dart
import 'package:app_wsrb_jsr/app/ui/settings/destinations/settings_appearance.dart';
import 'package:app_wsrb_jsr/app/ui/settings/destinations/settings_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExtendedNestedScrollView(
        // overscrollBehavior: OverscrollBehavior.outer,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [SliverAppBar.large(title: const Text("Configurações"))];
        },
        onlyOneScrollInBody: true,
        body: SettingsList(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          brightness: Theme.brightnessOf(context),
          lightTheme: settingsThemeData(context),
          darkTheme: settingsThemeData(context),
          applicationType: ApplicationType.both,
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.navigation(
                  leading: Icon(MdiIcons.paletteOutline),
                  title: const Text("Aparência"),
                  description: const Text("Tema, formato de data e hora"),
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsAppearanceView()),
                    );
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(MdiIcons.bookOutline),
                  title: const Text("Biblioteca"),
                  description: const Text(
                    "Categorias, atualização global, ações do capítulo",
                  ),
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsLibraryView()),
                    );
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(MdiIcons.bookOpenOutline),
                  title: const Text("Leitor"),
                  description: const Text("Modo de leitura, exibição, navegação"),
                  onPressed: (context) {
                    // TODO: Implementar navegação para Leitor
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.download),
                  title: const Text("Downloads"),
                  description: const Text("Download automático, download a frente"),
                  onPressed: (context) {
                    // TODO: Implementar navegação para Downloads
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.sync),
                  title: const Text("Monitoramento"),
                  description: const Text(
                    "Sincronização de progresso unidirecional, sincronização aprimorada",
                  ),
                  onPressed: (context) {
                    // TODO: Implementar navegação para Monitoramento
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.search),
                  title: const Text("Navegar"),
                  description: const Text("Fontes, extensões, pesquisa global"),
                  onPressed: (context) {
                    // TODO: Implementar navegação para Navegar
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.storage),
                  title: const Text("Dados e armazenamento"),
                  description: const Text(
                    "Backups manuais e automáticos, espaço de armazenamento",
                  ),
                  onPressed: (context) {
                    // TODO: Implementar navegação para Dados e armazenamento
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.security),
                  title: const Text("Segurança e privacidade"),
                  description: const Text("Bloqueio do aplicativo, tela segura"),
                  onPressed: (context) {
                    // TODO: Implementar navegação para Segurança e privacidade
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(MdiIcons.cat),
                  title: const Text("MangaDex"),
                  onPressed: (context) {
                    // TODO: Implementar navegação para MangaDex
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

class CustomSettingsTile extends SettingsTile {
  CustomSettingsTile({
    super.key,
    required super.title,
    super.value,
    super.description,
    super.enabled,
    super.leading,
    super.onPressed,
    super.trailing,
  });
  CustomSettingsTile.navigation({
    super.key,
    required super.title,
    super.value,
    super.description,
    super.enabled,
    super.leading,
    super.onPressed,
    super.trailing,
  });
  CustomSettingsTile.switchTile({
    super.key,
    required super.title,
    required super.initialValue,
    super.description,
    super.enabled,
    super.leading,
    void Function(bool)? super.onToggle,
    super.trailing,
    super.onPressed,
    super.activeSwitchColor,
  }) : super.switchTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: super.build(context),
    );
  }
}

SettingsThemeData settingsThemeData(BuildContext context) {
  final theme = Theme.of(context); // Pega o tema atual (claro ou escuro)

  return SettingsThemeData(
    // Cor de fundo de toda a tela de configurações
    settingsListBackground: theme.scaffoldBackgroundColor,

    // Cor de fundo de cada seção (o "cartão")
    settingsSectionBackground: theme.colorScheme.surface,

    // Cor do divisor entre os itens
    dividerColor: theme.dividerColor,

    // Cor do destaque ao pressionar um item
    tileHighlightColor: theme.highlightColor,

    // --- Títulos das Seções ---
    // Cor do texto do título (ex: "Geral", "Aparência")
    titleTextColor: theme.colorScheme.primary,

    // --- Itens da Lista (SettingsTile) ---
    // Cor dos ícones à esquerda
    leadingIconsColor: theme.colorScheme.onSurfaceVariant,

    // Cor do texto principal do item
    settingsTileTextColor: theme.colorScheme.onSurface,

    // Cor do subtítulo quando o item está desativado
    inactiveSubtitleColor: theme.disabledColor,

    // Cor do título quando o item está desativado
    inactiveTitleColor: theme.disabledColor,
  );
}
