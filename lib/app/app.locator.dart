// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:analytics/src/services/logger_navigator_observer.dart';
import 'package:archive/src/codecs/gzip_decoder.dart';
import 'package:archive/src/codecs/gzip_encoder.dart';
import 'package:chat/src/services/chat_api_service.dart';
import 'package:chat/src/services/chat_message_repository.dart';
import 'package:chat/src/services/chat_repository.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/message_embedding_repository.dart';
import 'package:chat/src/services/message_repository.dart';
import 'package:chat/src/services/stream_response_service/http_stream_response_service.dart';
import 'package:chat/src/services/stream_response_service/stream_response_service.dart';
import 'package:database/src/services/connection_setting_repository.dart';
import 'package:database/src/services/connection_setting_service.dart';
import 'package:dio/src/dio.dart';
import 'package:document/src/services/batch_service.dart';
import 'package:document/src/services/document_api_service.dart';
import 'package:document/src/services/document_embedding_repository.dart';
import 'package:document/src/services/document_repository.dart';
import 'package:document/src/services/document_service.dart';
import 'package:document/src/services/embedding_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:settings/src/services/setting_repository.dart';
import 'package:settings/src/services/setting_service.dart';
import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';
import 'package:surrealdb_js/src/surrealdb_js.dart';
import 'package:surrealdb_wasm/src/surreal_wasm.dart';

import '../src/services/feature_flag_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => FeatureFlagService());
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
  locator.registerLazySingleton(() => BatchService());
  locator.registerLazySingleton(() => ChatRepository());
  locator.registerLazySingleton(() => ChatMessageRepository());
  locator.registerLazySingleton(() => MessageRepository());
  locator.registerLazySingleton(() => MessageEmbeddingRepository());
  locator.registerLazySingleton(() => ChatService());
  locator.registerLazySingleton(() => ChatApiService());
  locator.registerLazySingleton<StreamResponseService>(
      () => HttpStreamResponseService());
  locator.registerLazySingleton(() => SettingService());
  locator.registerLazySingleton(() => SettingRepository());
  locator.registerLazySingleton<Surreal>(() => SurrealWasm.getInstance());
  locator.registerLazySingleton(() => FlutterSecureStorage());
  locator.registerLazySingleton(() => ConnectionSettingRepository());
  locator.registerLazySingleton(() => ConnectionSettingService());
  locator.registerLazySingleton(() => LoggerNavigatorObserver());
}
