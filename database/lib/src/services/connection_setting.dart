import 'package:freezed_annotation/freezed_annotation.dart';
part 'connection_setting.freezed.dart';
part 'connection_setting.g.dart';

@freezed
abstract class ConnectionSetting with _$ConnectionSetting {
  const factory ConnectionSetting({
    required String key,
    required String value,
  }) = _ConnectionSetting;

  factory ConnectionSetting.fromJson(Map<String, dynamic> json) =>
      _$ConnectionSettingFromJson(json);

  static const connectionKey = 'connection';
  static const nameKey = 'name';
  static const protocolKey = 'protocol';
  static const addressPortKey = 'addressPort';
  static const namespaceKey = 'namespace';
  static const databaseKey = 'database';
  static const usernameKey = 'username';
  static const passwordKey = 'password';
}
