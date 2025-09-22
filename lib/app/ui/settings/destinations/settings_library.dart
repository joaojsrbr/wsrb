// Updated settings_library.dart
import 'package:app_wsrb_jsr/app/ui/settings/view/settings_view.dart';
import 'package:content_library/content_library.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart' hide CustomSettingsTile;

class SettingsLibraryView extends StatefulWidget {
  const SettingsLibraryView({super.key});

  @override
  State<SettingsLibraryView> createState() => _SettingsLibraryViewState();
}

class _SettingsLibraryViewState extends State<SettingsLibraryView> {
  @override
  Widget build(BuildContext context) {
    final AppConfigController appConfigController = context.watch<AppConfigController>();
    final config = appConfigController.repo.config;
    return Scaffold(
      body: ExtendedNestedScrollView(
        // overscrollBehavior: OverscrollBehavior.outer,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [SliverAppBar.medium(title: const Text("Biblioteca"))];
        },
        onlyOneScrollInBody: true,
        body: SettingsList(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          lightTheme: settingsThemeData(context),
          darkTheme: settingsThemeData(context),
          sections: [
            SettingsSection(
              title: Text(
                'Categorias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              tiles: [
                CustomSettingsTile.navigation(
                  title: Text(
                    "Editar categorias",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  value: const Text("1 categoria"),
                  onPressed: (context) {
                    // Não funcional conforme solicitação
                  },
                ),
                CustomSettingsTile(
                  title: Text(
                    "Categoria padrão",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  value: const Text("Padrão"),
                ),
                CustomSettingsTile.switchTile(
                  initialValue: false,
                  enabled: false,
                  onToggle: null,
                  title: Text(
                    "Configurações por categoria para ordenação",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            SettingsSection(
              title: Text(
                'Atualizações automáticas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              tiles: [
                CustomSettingsTile(
                  title: Text(
                    "Atualizações automáticas",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  value: Text(
                    config.autoUpdateInterval.getIntervalText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onPressed: (context) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          "Atualizações automáticas",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: AutoUpdateInterval.values.map((interval) {
                              return RadioListTile<AutoUpdateInterval>(
                                visualDensity: VisualDensity.compact,
                                title: Text(
                                  interval.getIntervalText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                value: interval,
                                groupValue: config.autoUpdateInterval,
                                onChanged: (AutoUpdateInterval? value) {
                                  if (value != null) {
                                    appConfigController.setAutoUpdateInterval(value);
                                    Navigator.pop(context);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancelar",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                CustomSettingsTile(
                  title: Text(
                    "Restrições",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  value: const Text("Somente no Wi-Fi"),
                ),
              ],
            ),
            SettingsSection(
              title: Text(
                'Categorias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              tiles: [
                CustomSettingsTile(
                  title: Text(
                    "Incluir",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  value: const Text("Todas"),
                ),
                CustomSettingsTile(
                  title: Text(
                    "Excluir",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  value: const Text("Nenhuma"),
                ),
              ],
            ),
            SettingsSection(
              title: Text(
                'Atualizações dinâmicas de categorias da biblioteca',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              tiles: [
                CustomSettingsTile(
                  title: Text(
                    "Sempre iniciar atualizações globais",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
