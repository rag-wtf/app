import 'dart:typed_data';

import 'package:analytics/analytics.dart';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:document/src/services/split_config.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

// @stacked-import
import 'test_helpers.mocks.dart';

final locator = StackedLocator.instance;

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
    // Add new mocks
    MockSpec<Dio>(onMissingStub: OnMissingStub.returnDefault),
    // Use the abstract class for mocking
    MockSpec<Surreal>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DocumentApiService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DocumentRepository>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<EmbeddingRepository>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DocumentEmbeddingRepository>(
      onMissingStub: OnMissingStub.returnDefault,
    ),
    MockSpec<SettingService>(onMissingStub: OnMissingStub.returnDefault),
    // If SettingService uses it directly
    MockSpec<SettingRepository>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<AnalyticsFacade>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<GZipEncoder>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<GZipDecoder>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<BatchService>(onMissingStub: OnMissingStub.returnDefault),
    // @stacked-mock-spec
  ],
)
void registerServices() {
  // Clear previous registrations
  _removeRegistrationIfExists<Dio>();
  _removeRegistrationIfExists<Surreal>();
  _removeRegistrationIfExists<NavigationService>();
  _removeRegistrationIfExists<DialogService>();
  _removeRegistrationIfExists<DocumentApiService>();
  _removeRegistrationIfExists<DocumentRepository>();
  _removeRegistrationIfExists<EmbeddingRepository>();
  _removeRegistrationIfExists<DocumentEmbeddingRepository>();
  _removeRegistrationIfExists<SettingService>();
  _removeRegistrationIfExists<SettingRepository>();
  _removeRegistrationIfExists<AnalyticsFacade>();
  _removeRegistrationIfExists<GZipEncoder>();
  _removeRegistrationIfExists<GZipDecoder>();
  _removeRegistrationIfExists<BatchService>();
  _removeRegistrationIfExists<
      DocumentService>(); // Unregister the real service if needed

  // Register mocks
  locator
    ..registerSingleton<MockDio>(MockDio())
    ..registerSingleton<MockSurreal>(MockSurreal()) // Register mock for Surreal
    ..registerSingleton<MockNavigationService>(MockNavigationService())
    ..registerSingleton<MockDialogService>(MockDialogService())
    ..registerSingleton<MockDocumentApiService>(MockDocumentApiService())
    ..registerSingleton<MockDocumentRepository>(MockDocumentRepository())
    ..registerSingleton<MockEmbeddingRepository>(MockEmbeddingRepository())
    ..registerSingleton<MockDocumentEmbeddingRepository>(
      MockDocumentEmbeddingRepository(),
    )
    ..registerSingleton<MockSettingService>(MockSettingService())
    ..registerSingleton<MockSettingRepository>(
      MockSettingRepository(),
    ) // If needed
    ..registerSingleton<MockAnalyticsFacade>(MockAnalyticsFacade())
    ..registerSingleton<MockGZipEncoder>(MockGZipEncoder())
    ..registerSingleton<MockGZipDecoder>(MockGZipDecoder())
    ..registerSingleton<MockBatchService>(MockBatchService());
// @stacked-mock-register
}

MockDocumentApiService get getMockDocumentApiService =>
    locator<MockDocumentApiService>();
MockDocumentRepository get getMockDocumentRepository =>
    locator<MockDocumentRepository>();
MockEmbeddingRepository get getMockEmbeddingRepository =>
    locator<MockEmbeddingRepository>();
MockDocumentEmbeddingRepository get getMockDocumentEmbeddingRepository =>
    locator<MockDocumentEmbeddingRepository>();
MockSettingService get getMockSettingService => locator<MockSettingService>();
MockAnalyticsFacade get getMockAnalyticsFacade =>
    locator<MockAnalyticsFacade>();
MockGZipEncoder get getMockGZipEncoder => locator<MockGZipEncoder>();
MockGZipDecoder get getMockGZipDecoder => locator<MockGZipDecoder>();
MockSurreal get getMockSurreal => locator<MockSurreal>();
MockDio get getMockDio => locator<MockDio>();

void createMockSettings(
  MockSettingService mockSettingService, {
  String splitUrl = 'http://localhost:8000/split',
  String embeddingsUrl = 'http://localhost:8001/embeddings',
  String embeddingsModel = 'text-embedding-3-small',
  String embeddingsApiKey = 'test-key',
  String embeddingsApiBatchSize = '50',
  String embeddingsDbBatchSize = '50',
  String embeddingsDimensions = '384',
  String embeddingsCompressed = 'true',
  String embeddingsDimensionsEnabled = 'true',
  String maxConcurrency = '3', // IMPORTANT: Set semaphore limit for tests
  String chunkSize = '1000',
  String chunkOverlap = '100',
}) {
  when(mockSettingService.get(splitApiUrlKey))
      .thenReturn(Setting(key: splitApiUrlKey, value: splitUrl));
  when(mockSettingService.get(embeddingsApiUrlKey))
      .thenReturn(Setting(key: embeddingsApiUrlKey, value: embeddingsUrl));
  when(mockSettingService.get(embeddingsModelKey))
      .thenReturn(Setting(key: embeddingsModelKey, value: embeddingsModel));
  when(mockSettingService.get(embeddingsApiKey))
      .thenReturn(Setting(key: embeddingsApiKey, value: embeddingsApiKey));
  when(mockSettingService.get(embeddingsApiBatchSizeKey)).thenReturn(
    Setting(key: embeddingsApiBatchSizeKey, value: embeddingsApiBatchSize),
  );
  when(mockSettingService.get(embeddingsDatabaseBatchSizeKey)).thenReturn(
    Setting(
      key: embeddingsDatabaseBatchSizeKey,
      value: embeddingsDbBatchSize,
    ),
  );
  when(mockSettingService.get(embeddingsDimensionsKey)).thenReturn(
    Setting(key: embeddingsDimensionsKey, value: embeddingsDimensions),
  );
  when(mockSettingService.get(embeddingsCompressedKey)).thenReturn(
    Setting(key: embeddingsCompressedKey, value: embeddingsCompressed),
  );
  when(mockSettingService.get(embeddingsDimensionsEnabledKey)).thenReturn(
    Setting(
      key: embeddingsDimensionsEnabledKey,
      value: embeddingsDimensionsEnabled,
    ),
  );
  when(mockSettingService.get(maxIndexingConcurrencyKey)).thenReturn(
    Setting(
      key: maxIndexingConcurrencyKey,
      value: maxConcurrency,
    ),
  ); // Stub the new setting
  when(mockSettingService.get(chunkSizeKey))
      .thenReturn(Setting(key: chunkSizeKey, value: chunkSize));
  when(mockSettingService.get(chunkOverlapKey))
      .thenReturn(Setting(key: chunkOverlapKey, value: chunkOverlap));
}

// Helper function to create a mock Document
Document createMockDocument({
  String id = 'doc_table:doc1',
  String name = 'test.txt',
  int size = 1000,
  String mime = 'text/plain',
  DocumentStatus status = DocumentStatus.created,
  List<List<int>>? byteData,
  Uint8List? file, // Compressed file
  DateTime? created,
  DateTime? updated,
  DateTime? splitted,
  DateTime? done,
  String? errorMessage,
}) {
  return Document(
    id: id,
    name: name,
    originFileSize: size,
    compressedFileSize: file?.length ?? 0,
    fileMimeType: mime,
    status: status,
    byteData: byteData ??
        [Uint8List.fromList(List.generate(size, (index) => index % 256))],
    file: file, // compressed data
    created: created ?? DateTime.now().subtract(const Duration(minutes: 1)),
    updated: updated ?? DateTime.now().subtract(const Duration(minutes: 1)),
    splitted: splitted,
    done: done,
    errorMessage: errorMessage,
  );
}

// Helper function to create mock SplitConfig
SplitConfig createMockSplitConfig() {
  return const SplitConfig(
    deleteTempFile: true,
    nltkData: '/app/nltk_data',
    maxFileSizeInMb: 50,
    supportedFileTypes: ['text/plain', 'application/pdf'],
    chunkSize: 1000,
    chunkOverlap: 100,
  );
}

// Helper to create mock Embeddings (initially without vector)
List<Embedding> createMockEmbeddings(int count, {String prefix = 'emb'}) {
  return List.generate(
    count,
    (i) => Embedding(
      // Assign ID here as _splitted doesn't return the final
      // created ones directly
      id: 'emb_table:$prefix$i',
      content: 'Chunk content $i for $prefix',
      metadata: {'source_chunk': i},
    ),
  );
}

// Helper to create mock vectors
List<List<double>> createMockVectors(int count, int dimensions) {
  return List.generate(
    count,
    (i) => List.generate(dimensions, (j) => i + j * 0.1),
  );
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockDocumentApiService getAndRegisterApiService() {
  _removeRegistrationIfExists<DocumentApiService>();
  final service = MockDocumentApiService();
  locator.registerSingleton<DocumentApiService>(service);
  return service;
}

MockBatchService getAndRegisterBatchService() {
  _removeRegistrationIfExists<BatchService>();
  final service = MockBatchService();
  locator.registerSingleton<BatchService>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
