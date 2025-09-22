import 'package:content_library/src/models/app_config_entity.dart';

class AppConfigRepository {
  AppConfigEntity _config = AppConfigEntity.init();

  void updateConfig(AppConfigEntity Function(AppConfigEntity config) update) {
    _config = update(_config);
  }

  AppConfigEntity get config => _config;
}
