// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:database/src/services/connection_setting_repository.dart';
import 'package:database/src/services/connection_setting_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';
import 'package:surrealdb_js/src/surrealdb_js.dart';
import 'package:surrealdb_wasm/src/surreal_wasm.dart';

import '../services/app_setting_service.dart';
import '../services/setting_repository.dart';
import '../services/setting_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AppSettingService());
  locator.registerLazySingleton(() => SettingService());
  locator.registerLazySingleton(() => SettingRepository());
  locator.registerLazySingleton<Surreal>(() => SurrealWasm.getInstance());
  locator.registerLazySingleton(() => FlutterSecureStorage());
  locator.registerLazySingleton(() => ConnectionSettingRepository());
  locator.registerLazySingleton(() => ConnectionSettingService());
}
