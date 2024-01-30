import 'package:env_reader/env_reader.dart';
import 'package:flutter/services.dart';
import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/app/app.logger.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/setting.dart';
import 'package:settings/src/services/setting_repository.dart';
import 'package:stacked/stacked.dart';
import 'package:ulid/ulid.dart';

class SettingService with ListenableServiceMixin {
  SettingService() {
    listenToReactiveValues([_settings]);
  }
  final Map<String, Setting> _settings = {};
  final _settingRepository = locator<SettingRepository>();
  void Function()? clearFormValuesFunction;
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
    } else if (type == bool) {
      value = Env.read<bool>(key).toString();
    } else {
      value = Env.read<String>(key) ?? undefined;
    }
    return Setting(
      key: key,
      value: value,
      created: DateTime.now(),
    );
  }

  Future<void> initialise(String tablePrefix) async {
    if (Env.read(dataIngestionApiUrlKey) == null) {
      String settings;
      try {
        // load from rag
        settings =
            await rootBundle.loadString('packages/settings/assets/settings');
      } catch (_) {
        // load in the package
        settings = await rootBundle.loadString('settings');
      }
      await Env.load(
        EnvStringLoader(settings),
        'yG5~mhzE*;X&ZgF#]tQ,Ue',
      );
    }

    if (_settings.isEmpty) {
      // create user id if not found.
      if (await _settingRepository.getSettingByKey(
            tablePrefix,
            userIdKey,
          ) ==
          null) {
        final userId = Setting(
          key: userIdKey,
          value: Ulid().toString(),
          created: DateTime.now(),
        );
        await _settingRepository.createSetting(tablePrefix, userId);
      }
      final settings = await _settingRepository.getAllSettings(tablePrefix);
      if (settings.isNotEmpty) {
        for (final setting in settings) {
          _settings[setting.key] = setting;
        }
      }
    }
  }

  Future<void> clearData(String tablePrefix) async {
    await _settingRepository.deleteAllSettings(tablePrefix);
    _settings.clear();
    await initialise(tablePrefix);
    clearFormValuesFunction?.call();
    notifyListeners();
  }

  Future<void> set(String tablePrefix, String key, String value) async {
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
            notifyListeners();
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
          await _settingRepository.createSetting(tablePrefix, setting);
      if (createdSetting.id != null) {
        _settings[key] = createdSetting;
        notifyListeners();
      } else {
        throw Exception('Unable to create setting of "$key"!');
      }
    }
  }
}
