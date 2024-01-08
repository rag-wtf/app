// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:archive/src/gzip_decoder.dart';
import 'package:archive/src/gzip_encoder.dart';
import 'package:dio/src/dio.dart';
import 'package:document/src/services/document_api_service.dart';
import 'package:document/src/services/document_embedding_repository.dart';
import 'package:document/src/services/document_repository.dart';
import 'package:document/src/services/document_service.dart';
import 'package:document/src/services/embedding_repository.dart';
import 'package:settings/src/services/database_service.dart';
import 'package:settings/src/services/setting_repository.dart';
import 'package:settings/src/services/setting_service.dart';
import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
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
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerFactory(() => Dio());
  locator.registerLazySingleton(() => DocumentApiService());
  locator.registerLazySingleton(() => GZipEncoder());
  locator.registerLazySingleton(() => GZipDecoder());
  locator.registerLazySingleton(() => DocumentService());
  locator.registerLazySingleton(() => DocumentRepository());
  locator.registerLazySingleton(() => EmbeddingRepository());
  locator.registerLazySingleton(() => DocumentEmbeddingRepository());
  locator.registerLazySingleton(() => SettingService());
  locator.registerLazySingleton(() => SettingRepository());
  final databaseService = DatabaseService();
  await databaseService.init();
  locator.registerSingleton<Surreal>(databaseService);
}
