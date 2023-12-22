import 'package:env_reader/env_reader.dart';
import 'package:flutter/services.dart';
import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/app/app.logger.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/setting.dart';
import 'package:settings/src/services/setting_repository.dart';

class SettingService {
  final Map<String, Setting> _settings = {};
  final SettingRepository _settingRepository = SettingRepository(db: locator());
  final _log = getLogger('SettingService');

  Setting get(String key, {Type? type}) {
    Setting setting;

    if (_settings.containsKey(key)) {
      setting = _settings[key]!;
    } else {
      setting = _getDefaultSetting(key, type);
    }
    _log.d(setting.toString());
    return setting;
  }

  Setting _getDefaultSetting(String key, Type? type) {
    String value;
    if (type == int) {
      value = Env.read<int>(key).toString();
    } else if (type == double) {
      value = Env.read<double>(key).toString();
    } else {
      value = Env.read<String>(key) ?? undefined;
    }
    return Setting(
      key: key,
      value: value,
      created: DateTime.now(),
    );
  }

  Future<void> initialise(String prefix) async {
    if (Env.read(dataIngestionApiUrlKey) == null) {
      await Env.load(
        EnvStringLoader(
          await rootBundle.loadString('packages/settings/assets/settings'),
        ),
        'yG5~mhzE*;X&ZgF#]tQ,Ue',
      );
    }

    if (_settings.isEmpty) {
      final settings = await _settingRepository.getAllSettings(prefix);
      if (settings.isNotEmpty) {
        for (final setting in settings) {
          _settings[setting.key] = setting;
        }
      }
    }
  }

  Future<void> reset(String prefix) async {
    await _settingRepository.deleteAllSettings(prefix);
    _settings.clear();
  }

  Future<void> set(String prefix, String key, String value) async {
    final newValue = value.trim();
    if (_settings.containsKey(key)) {
      final setting = _settings[key];
      if (setting!.value != newValue) {
        final updatedSetting = await _settingRepository.updateSetting(
          setting.copyWith(
            value: newValue,
            updated: DateTime.now(),
          ),
        );
        if (updatedSetting != null) {
          if (updatedSetting.value == newValue) {
            _settings[key] = updatedSetting;
          } else {
            throw Exception('Unable to update setting of "$key"!');
          }
        } else {
          throw Exception('Setting of key "$key" not found!');
        }
      }
    } else {
      final setting =
          Setting(key: key, value: newValue, created: DateTime.now());

      final createdSetting =
          await _settingRepository.createSetting(prefix, setting);
      if (createdSetting.id != null) {
        _settings[key] = createdSetting;
      } else {
        throw Exception('Unable to create setting of "$key"!');
      }
    }
  }
}
