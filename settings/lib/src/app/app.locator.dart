// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:settings/src/services/database_service.dart';
import 'package:settings/src/services/setting_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';
import 'package:surrealdb_wasm/src/surrealdb_wasm.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
    environment: environment,
    environmentFilter: environmentFilter,
  );

// Register dependencies
  locator.registerLazySingleton(NavigationService.new);
  locator.registerLazySingleton(SettingService.new);
  locator.registerSingleton<Surreal>(DatabaseService.getInstance());
}
