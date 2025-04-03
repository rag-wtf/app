// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/document_item.dart';
import 'package:fake_async/fake_async.dart'; // Import fake_async
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  final log = getLogger('DocumentServiceTest');
  group('DocumentServiceTest -', () {
    late DocumentService documentService;
    late MockDocumentApiService mockDocumentApiService;
    late MockDocumentRepository mockDocumentRepository;
    late MockEmbeddingRepository mockEmbeddingRepository;
    late MockDocumentEmbeddingRepository mockDocumentEmbeddingRepository;
    late MockSettingService mockSettingService;
    late MockAnalyticsFacade mockAnalyticsFacade;
    late MockGZipEncoder mockGZipEncoder;
    late MockGZipDecoder mockGZipDecoder;
    late MockSurreal mockSurreal;

    const testTablePrefix = 'test_docs';
    const testDimensions = '384';
    const maxConcurrency = 2; // Use a small number for easier testing

    setUp(() {
      registerServices(); // Registers all mocks

      // Get mock instances
      mockDocumentApiService = getMockDocumentApiService;
      mockDocumentRepository = getMockDocumentRepository;
      mockEmbeddingRepository = getMockEmbeddingRepository;
      mockDocumentEmbeddingRepository = getMockDocumentEmbeddingRepository;
      mockSettingService = getMockSettingService;
      mockAnalyticsFacade = getMockAnalyticsFacade;
      mockGZipEncoder = getMockGZipEncoder;
      mockGZipDecoder = getMockGZipDecoder;
      mockSurreal = getMockSurreal;

      // Stub common dependencies
      when(mockGZipEncoder.encode(any)).thenReturn(
        Uint8List.fromList([1, 2, 3]),
      ); // Dummy compressed data
      when(mockGZipDecoder.decodeBytes(any)).thenReturn(
        Uint8List.fromList([4, 5, 6]),
      ); // Dummy decompressed

      // Stub database info/transaction calls (adjust if needed)
      when(mockSurreal.query(any, bindings: anyNamed('bindings')))
          .thenAnswer((_) async => []); // Default answer for queries
      when(mockSurreal.query('INFO FOR DB')).thenAnswer(
        (_) async => {
          'tables': {
            '${testTablePrefix}_documents': <String, Map<String, dynamic>>{},
            '${testTablePrefix}_embeddings': <String, Map<String, dynamic>>{},
            '${testTablePrefix}_document_embeddings':
                <String, Map<String, dynamic>>{},
          }, // Assume schema exists by default in most tests
        },
      );
      when(mockSurreal.transaction(any)).thenAnswer((invocation) async {
        // Execute the transaction function immediately for testing
        final function =
            invocation.positionalArguments[0] as Future<void> Function(dynamic);
        // Assuming a mock transaction type if needed
        final mockTransaction = MockSurrealTransaction();
        when(
          mockTransaction.query(
            '',
            bindings: anyNamed('bindings'),
          ),
        ).thenAnswer((_) async => []);
        await function(mockTransaction);
        // Mock transaction result
        return [
          {'status': 'OK', 'result': <String, Map<String, dynamic>>{}},
        ];
      });
      // Default doc not found
      when(mockSurreal.select(any)).thenAnswer((_) async => null);
      when(mockSurreal.delete(any)).thenAnswer((_) async => {}); // Mock delete

      // Stub settings
      createMockSettings(
        mockSettingService,
        maxConcurrency: maxConcurrency.toString(),
        embeddingsDimensions: testDimensions,
      );

      // Stub SplitConfig fetch
      when(mockDocumentApiService.getSplitConfig(any, any))
          .thenAnswer((_) async => createMockSplitConfig());

      // Create instance AFTER registering mocks
      documentService = DocumentService();
    });

    tearDown(locator.reset);

    // --- Helper Functions for Test ---
    // Capture the callbacks passed to apiService.split
    Future<void> Function(DocumentItem, DocumentStatus)?
        capturedUpdateStatusCallback;
    void Function(DocumentItem, double)? capturedProgressCallback;
    Future<void> Function(DocumentItem, Map<String, dynamic>?)?
        capturedSplitCompletedCallback;

    void captureSplitCallbacks() {
      // Reset specific mock to avoid unwanted interactions
      reset(mockDocumentApiService);
      // Re-stub necessary calls
      when(mockDocumentApiService.getSplitConfig(any, any))
          .thenAnswer((_) async => createMockSplitConfig());

      when(
        mockDocumentApiService.split(
          any, // dio
          any, // url
          any, // documentItem
          any, // onUpdateDocumentStatus
          any, // onProgress
          any, // onSplitCompleted
          any, // onError
        ),
      ).thenAnswer((invocation) async {
        capturedUpdateStatusCallback = invocation.positionalArguments[3]
            as Future<void> Function(DocumentItem, DocumentStatus)?;
        capturedProgressCallback = invocation.positionalArguments[4] as void
            Function(DocumentItem, double)?;
        capturedSplitCompletedCallback = invocation.positionalArguments[5]
            as Future<void> Function(DocumentItem, Map<String, dynamic>?)?;
        // Don't return anything, just capture. Test will manually
        // trigger callbacks.
        return Future.value();
      });
    }

    // Simulate successful splitting and indexing process
    Future<void> simulateSuccessfulProcessing(
      DocumentItem item,
      int embeddingCount,
    ) async {
      final mockDocPending = createMockDocument(
        id: item.item.id!,
        status: DocumentStatus.pending,
      );
      final mockDocSplitting = createMockDocument(
        id: item.item.id!,
        status: DocumentStatus.splitting,
      );
      final mockDocIndexing = createMockDocument(
        id: item.item.id!,
        status: DocumentStatus.indexing,
        splitted: DateTime.now(),
      );
      final mockDocCompleted = createMockDocument(
        id: item.item.id!,
        status: DocumentStatus.completed,
        done: DateTime.now(),
      );
      final mockSplitResponse = {
        'items': List.generate(
          embeddingCount,
          (i) => {
            'content': 'Chunk $i',
            'metadata': {'chunk_no': i},
          },
        ),
        'mime_type': 'text/plain',
      };
      final mockEmbeddings = createMockEmbeddings(
        embeddingCount,
        prefix: item.item.id!.split(':').last,
      );
      final mockVectors = createMockVectors(
        embeddingCount,
        int.parse(testDimensions),
      );

      // 1. Status update to Pending
      // (triggered internally by addItem -> _split)
      when(mockDocumentRepository.updateDocumentStatus(any))
          .thenAnswer((inv) async {
        final docArg = inv.positionalArguments[0] as Document;
        if (docArg.status == DocumentStatus.pending) return mockDocPending;
        // This mock might be called again later for indexing/completed,
        // handle if needed
        return docArg; // Default return
      });

      // 2. Simulate call to apiService.split (callbacks captured)
      // (captureSplitCallbacks should be called before addItem
      // triggers _split)

      // 3. Manually trigger progress and splitting status update
      await capturedUpdateStatusCallback!(item, DocumentStatus.splitting);
      when(mockDocumentRepository.updateDocumentStatus(any)).thenAnswer(
        (inv) async => mockDocSplitting,
      ); // Now return splitting status
      item.item = mockDocSplitting; // Update item state in test
      capturedProgressCallback!(item, 0.5); // Simulate some progress
      capturedProgressCallback!(item, 1);

      // 4. Manually trigger _onSplitCompleted
      // Mock DB calls within _splitted
      when(mockDocumentRepository.updateDocument(any, any)).thenAnswer(
        (_) async => null,
      ); // In transaction
      when(mockEmbeddingRepository.createEmbeddings(any, any, any)).thenAnswer(
        (_) async => mockEmbeddings,
      ); // In transaction
      when(
        mockDocumentEmbeddingRepository.createDocumentEmbeddings(
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async => []); // In transaction
      when(mockSurreal.transaction(any)).thenAnswer((invocation) async {
        final function =
            invocation.positionalArguments[0] as Future<void> Function(dynamic);
        final mockTransaction = MockSurrealTransaction();
        when(mockTransaction.query('', bindings: anyNamed('bindings')))
            .thenAnswer((_) async => []);
        await function(mockTransaction);
        // Mock result structure from transaction containing updated doc
        //and created embeddings
        return [
          // Result for updateDocument
          {'status': 'OK', 'result': mockDocIndexing.toJson()},
          {
            'status': 'OK',
            'result': mockEmbeddings.map((e) => e.toJson()).toList(),
          }, // Result for createEmbeddings
          {
            'status': 'OK',
            'result': <String>[],
          } // Result for createDocumentEmbeddings
        ];
      });

      await capturedSplitCompletedCallback!(item, mockSplitResponse);
      // Verify status is now indexing (state updated within _splitted via
      //transaction mock)
      expect(item.item.status, DocumentStatus.indexing);

      // 5. Mock indexing API call (inside semaphore)
      when(
        mockDocumentApiService.index(
          any,
          any,
          any,
          any,
          any,
          batchSize: anyNamed('batchSize'),
          dimensions: anyNamed('dimensions'),
          compressed: anyNamed('compressed'),
          embeddingsDimensionsEnabled: anyNamed('embeddingsDimensionsEnabled'),
        ),
      ).thenAnswer((_) async {
        // Simulate network delay
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return mockVectors;
      });

      // 6. Mock embedding update in DB
      when(mockEmbeddingRepository.updateEmbeddings(any, any, any))
          .thenAnswer((_) async => []); // Simulate success

      // 7. Mock final status update to Completed
      // Called by updateDocumentDoneStatus
      when(mockDocumentRepository.updateDocument(any)).thenAnswer((inv) async {
        final docArg = inv.positionalArguments[0] as Document;
        if (docArg.status == DocumentStatus.completed) {
          return mockDocCompleted;
        }
        return docArg; // default
      });
      when(mockAnalyticsFacade.trackDocumentUploadCompleted())
          .thenAnswer((_) async {}); // Mock analytics

      // Test runner (e.g., FakeAsync) needs to elapse time for the
      // Future.delayed in index mock
    }

    // --- Test Cases ---

    test('initialise should fetch SplitConfig and setup semaphore', () async {
      // Arrange
      when(mockSurreal.query('INFO FOR DB')).thenAnswer(
        (_) async => {'tables': <String, dynamic>{}},
      ); // Simulate schema *not* existing
      when(mockDocumentApiService.getSplitConfig(any, any))
          .thenAnswer((_) async => createMockSplitConfig());
      // Mock schema creation calls within transaction
      when(mockSurreal.transaction(any)).thenAnswer((invocation) async {
        final function =
            invocation.positionalArguments[0] as Future<void> Function(dynamic);
        final mockTransaction = MockSurrealTransaction();
        when(mockTransaction.query('', bindings: anyNamed('bindings')))
            .thenAnswer((_) async => []);
        await function(mockTransaction);
        return [
          {'status': 'OK', 'result': <String, dynamic>{}},
        ];
      });

      // Act
      await documentService.initialise(testTablePrefix, testDimensions);

      // Assert
      // Verify schema creation transaction
      verify(mockSurreal.transaction(any)).called(1);
      verify(mockDocumentApiService.getSplitConfig(any, any)).called(1);
      expect(documentService.splitConfig, isNotNull);
      // We can't directly check the semaphore, but initialization logic
      // should have run.
      // A log message check could be added if logging is robustly mocked/captured.
    });

    test('addItem successfully processes a single document', () async {
      fakeAsync((async) {
        // Arrange
        final initialDoc = createMockDocument(
          id: 'doc_table:doc1',
        );
        final createdDoc = initialDoc.copyWith(
          status: DocumentStatus.created,
          id: 'doc_table:doc1',
          created: DateTime.now(),
          updated: DateTime.now(),
        ); // Simulate DB return
        final compressedData = Uint8List.fromList([1, 2, 3]);
        when(mockGZipEncoder.encode(any)).thenReturn(compressedData);
        when(mockDocumentRepository.createDocument(any, any)).thenAnswer(
          (_) async => createdDoc,
        );
        // Need file for split
        when(mockDocumentRepository.getDocumentById('doc_table:doc1'))
            .thenAnswer((_) async => createdDoc.copyWith(file: compressedData));
        captureSplitCallbacks(); // Setup capturing before calling addItem

        // Act
        documentService.addItem(testTablePrefix, initialDoc);
        async.flushMicrotasks(); // Allow addItem future to complete

        // Assert: Initial state
        expect(documentService.items.length, 1);
        expect(documentService.items.first.item.id, 'doc_table:doc1');
        expect(documentService.items.first.progress, 0.0); // Initial progress
        verify(mockDocumentRepository.createDocument(testTablePrefix, any))
            .called(1); // Verify creation
        verify(mockDocumentApiService.split(any, any, any, any, any, any, any))
            .called(1); // Verify split was called

        // Simulate the rest of the process
        simulateSuccessfulProcessing(
          documentService.items.first,
          5,
        ); // Assume 5 chunks/embeddings
        // Process futures from simulateSuccessfulProcessing
        async
          ..flushMicrotasks()
          // Elapse time for simulated delays
          ..elapse(const Duration(seconds: 1));

        // Assert: Final state
        expect(
          documentService.items.first.item.status,
          DocumentStatus.completed,
        );
        verify(
          mockDocumentApiService.index(
            any,
            any,
            any,
            any,
            any,
            batchSize: anyNamed('batchSize'),
            dimensions: anyNamed('dimensions'),
            compressed: anyNamed('compressed'),
            embeddingsDimensionsEnabled:
                anyNamed('embeddingsDimensionsEnabled'),
          ),
        ).called(1);
        verify(
          mockEmbeddingRepository.updateEmbeddings(
            testTablePrefix,
            any,
            any,
          ),
        ).called(1);
        // Final update to completed
        verify(mockDocumentRepository.updateDocument(any)).called(1);
        verify(mockAnalyticsFacade.trackDocumentUploadCompleted()).called(1);
      }); // End fakeAsync
    });

    test('addItem handles split API error', () async {
      fakeAsync((async) {
        // Arrange
        final initialDoc = createMockDocument(id: 'doc_table:docError');
        final createdDoc = initialDoc.copyWith(
          status: DocumentStatus.created,
          id: 'doc_table:docError',
          created: DateTime.now(),
          updated: DateTime.now(),
        );
        final compressedData = Uint8List.fromList([1, 2, 3]);
        final mockError = DioException(
          requestOptions: RequestOptions(),
          message: 'Split failed',
        );
        final failedDoc = createdDoc.copyWith(
          status: DocumentStatus.failed,
          errorMessage: mockError.message,
          done: DateTime.now(),
        );

        when(mockGZipEncoder.encode(any)).thenReturn(compressedData);
        when(mockDocumentRepository.createDocument(any, any))
            .thenAnswer((_) async => createdDoc);
        when(mockDocumentRepository.getDocumentById('doc_table:docError'))
            .thenAnswer((_) async => createdDoc.copyWith(file: compressedData));
        // Update status during split attempt
        when(mockDocumentRepository.updateDocumentStatus(any)).thenAnswer(
          (inv) async => createdDoc.copyWith(
            status: (inv.positionalArguments[0] as Document).status,
          ),
        );
        when(mockDocumentRepository.updateDocument(any))
            .thenAnswer((_) async => failedDoc); // Final update to failed
        when(mockAnalyticsFacade.trackDocumentUploadFailed(any))
            .thenAnswer((_) async {});

        captureSplitCallbacks();

        // Act
        documentService.addItem(testTablePrefix, initialDoc);
        async.flushMicrotasks();

        // Assert
        expect(documentService.items.first.item.status, DocumentStatus.failed);
        expect(
          documentService.items.first.item.errorMessage,
          contains('Split failed'),
        );
        verifyNever(
          mockDocumentApiService.index(
            any,
            any,
            any,
            any,
            any,
            batchSize: anyNamed('batchSize'),
            dimensions: anyNamed('dimensions'),
            compressed: anyNamed('compressed'),
            embeddingsDimensionsEnabled:
                // Indexing should not happen
                anyNamed('embeddingsDimensionsEnabled'),
          ),
        );
        // Called by updateDocumentDoneStatus
        verify(mockDocumentRepository.updateDocument(any)).called(1);
        verify(mockAnalyticsFacade.trackDocumentUploadFailed(any)).called(1);
      });
    });

    test('addItem handles indexing API error after splitting', () async {
      await fakeAsync((async) async {
        // Arrange
        final item = createMockDocument(id: 'doc_table:docIdxErr');
        final createdDoc = item.copyWith(
          status: DocumentStatus.created,
          id: item.id,
          created: DateTime.now(),
          updated: DateTime.now(),
        );
        final mockDocIndexing = createdDoc.copyWith(
          status: DocumentStatus.indexing,
          splitted: DateTime.now(),
        );
        final mockSplitResponse = {
          'items': [
            {'content': 'Chunk 0'},
          ],
          'mime_type': 'text/plain',
        };
        final mockEmbeddings =
            createMockEmbeddings(1, prefix: item.id!.split(':').last);
        final indexingError = DioException(
          requestOptions: RequestOptions(),
          message: 'Indexing API unavailable',
        );
        final failedDoc = mockDocIndexing.copyWith(
          status: DocumentStatus.failed,
          errorMessage: 'Error during indexing',
          done: DateTime.now(),
        ); // Error message generated internally

        when(mockGZipEncoder.encode(any)).thenReturn(
          Uint8List.fromList(
            [1, 2, 3],
          ),
        );
        when(mockDocumentRepository.createDocument(any, any))
            .thenAnswer((_) async => createdDoc);
        when(mockDocumentRepository.getDocumentById(item.id)).thenAnswer(
          (_) async => createdDoc.copyWith(
            file: Uint8List.fromList(
              [1, 2, 3],
            ),
          ),
        );
        when(mockDocumentRepository.updateDocumentStatus(any)).thenAnswer(
          (inv) async => createdDoc.copyWith(
            status: (inv.positionalArguments[0] as Document).status,
          ),
        );
        // Mock _splitted transaction
        when(mockSurreal.transaction(any)).thenAnswer((invocation) async {
          final function = invocation.positionalArguments[0] as Future<void>
              Function(dynamic);
          final mockTransaction = MockSurrealTransaction();
          when(mockTransaction.query('', bindings: anyNamed('bindings')))
              .thenAnswer((_) async => []);
          await function(mockTransaction);
          return [
            // Simulate returning indexing status doc
            {'status': 'OK', 'result': mockDocIndexing.toJson()},
            {
              'status': 'OK',
              'result': mockEmbeddings.map((e) => e.toJson()).toList(),
            },
            {'status': 'OK', 'result': <String>[]},
          ];
        });
        // Mock indexing API call to throw error
        when(
          mockDocumentApiService.index(
            any,
            any,
            any,
            any,
            any,
            batchSize: anyNamed('batchSize'),
            dimensions: anyNamed('dimensions'),
            compressed: anyNamed('compressed'),
            embeddingsDimensionsEnabled:
                anyNamed('embeddingsDimensionsEnabled'),
          ),
        ).thenThrow(indexingError);
        // Mock final status update
        when(mockDocumentRepository.updateDocument(any))
            .thenAnswer((_) async => failedDoc);
        when(mockAnalyticsFacade.trackDocumentUploadFailed(any))
            .thenAnswer((_) async {});

        captureSplitCallbacks();

        // Act
        await documentService.addItem(testTablePrefix, item);
        async.flushMicrotasks();

        // Simulate successful split completion
        await capturedSplitCompletedCallback!(
          documentService.items.first,
          mockSplitResponse,
        );
        async
          ..flushMicrotasks() // Process futures up to the index call
          ..elapse(
            const Duration(
              seconds: 1,
            ),
          ); // Allow time for index future to complete/fail

        // Assert
        expect(documentService.items.first.item.status, DocumentStatus.failed);
        expect(
          documentService.items.first.item.errorMessage,
          contains('Error during indexing'),
        );
        verify(
          mockDocumentApiService.index(
            any,
            any,
            any,
            any,
            any,
            batchSize: anyNamed('batchSize'),
            dimensions: anyNamed('dimensions'),
            compressed: anyNamed('compressed'),
            embeddingsDimensionsEnabled:
                anyNamed('embeddingsDimensionsEnabled'),
          ),
        ).called(1); // Indexing was attempted
        // DB update shouldn't happen
        verifyNever(mockEmbeddingRepository.updateEmbeddings(any, any, any));
        // Final status update
        verify(mockDocumentRepository.updateDocument(any)).called(1);
        verify(mockAnalyticsFacade.trackDocumentUploadFailed(any)).called(1);
      });
    });

    test('Semaphore limits concurrent indexing calls', () async {
      // This test requires careful timing simulation using fakeAsync
      await fakeAsync((async) async {
        // Arrange
        const docCount = 5; // More than maxConcurrency
        final docs = List.generate(
          docCount,
          (i) => createMockDocument(
            id: 'doc_table:docConc$i',
          ),
        );
        final createdDocs = docs
            .map(
              (d) => d.copyWith(
                status: DocumentStatus.created,
                id: d.id,
                created: DateTime.now(),
                updated: DateTime.now(),
              ),
            )
            .toList();
        final compressedData = Uint8List.fromList([1, 2, 3]);
        final indexCallCompleters = List.generate(
          docCount,
          (_) => Completer<List<List<double>>>(),
        );
        var concurrentIndexCalls = 0;
        var maxObservedConcurrentCalls = 0;

        // Mock settings (concurrency limit = 2)
        createMockSettings(mockSettingService, maxConcurrency: '2');
        // Re-initialize service with new setting (important!)
        documentService = DocumentService();
        // Await initialization
        await documentService.initialise(testTablePrefix, testDimensions);
        // Mock common steps for all docs
        when(mockGZipEncoder.encode(any)).thenReturn(compressedData);
        for (var i = 0; i < docCount; i++) {
          when(
            mockDocumentRepository.createDocument(
              any,
              argThat(predicate<Document>((doc) => doc.name == docs[i].name)),
            ),
          ).thenAnswer((_) async => createdDocs[i]);
          when(mockDocumentRepository.getDocumentById(createdDocs[i].id))
              .thenAnswer(
            (_) async => createdDocs[i].copyWith(
              file: compressedData,
            ),
          );
        }
        // Mock status updates (simplified)
        when(mockDocumentRepository.updateDocumentStatus(any)).thenAnswer(
          (inv) async => inv.positionalArguments[0] as Document,
        );
        // Mock _splitted transaction (simplified: just return indexing status)
        when(mockSurreal.transaction(any)).thenAnswer((invocation) async {
          final function = invocation.positionalArguments[0] as Future<void>
              Function(dynamic);
          final mockTransaction = MockSurrealTransaction();
          when(mockTransaction.query('', bindings: anyNamed('bindings')))
              .thenAnswer((_) async => []);
          await function(mockTransaction);
          // Find which document this transaction is to return correct status
          // This is tricky, might need more sophisticated mocking or rely on
          // sequential completion assumption in test
          // Simplified - need a way to know
          const docIdInTransaction = 'doc_table:docConcX';
          final indexingDoc = createMockDocument(
            id: docIdInTransaction,
            status: DocumentStatus.indexing,
          );
          return [
            {'status': 'OK', 'result': indexingDoc.toJson()},
            {'status': 'OK', 'result': <String>[]},
            {'status': 'OK', 'result': <String>[]},
          ];
        });
        // Mock final completion
        when(mockDocumentRepository.updateDocument(any)).thenAnswer(
          (inv) async => (inv.positionalArguments[0] as Document).copyWith(
            status: DocumentStatus.completed,
          ),
        );
        when(mockEmbeddingRepository.updateEmbeddings(any, any, any))
            .thenAnswer((_) async => []);
        when(mockAnalyticsFacade.trackDocumentUploadCompleted())
            .thenAnswer((_) async {});

        // Mock index API call to track concurrency and use completers
        when(
          mockDocumentApiService.index(
            any,
            any,
            any,
            any,
            any,
            batchSize: anyNamed('batchSize'),
            dimensions: anyNamed('dimensions'),
            compressed: anyNamed('compressed'),
            embeddingsDimensionsEnabled:
                anyNamed('embeddingsDimensionsEnabled'),
          ),
        ).thenAnswer((invocation) {
          concurrentIndexCalls++;
          maxObservedConcurrentCalls =
              concurrentIndexCalls > maxObservedConcurrentCalls
                  ? concurrentIndexCalls
                  : maxObservedConcurrentCalls;
          // Input chunks identify the doc indirectly
          final docItem = invocation.positionalArguments[3] as List<String>;
          final docIndex = int.parse(
            docItem[0].split('Conc').last.split(' ')[0],
          ); // Hacky way to get index
          log.i(
            '''
Index call START for doc $docIndex, Concurrent: $concurrentIndexCalls''',
          );

          return indexCallCompleters[docIndex].future.whenComplete(() {
            concurrentIndexCalls--;
            log.i('''
Index call END for doc $docIndex, Concurrent: $concurrentIndexCalls''');
          });
        });

        // Mock apiService.split to capture callbacks and return immediately
        final splitCallbacks = List.generate(
          docCount,
          (_) => <Symbol, Function>{},
        );
        when(mockDocumentApiService.split(any, any, any, any, any, any, any))
            .thenAnswer((invocation) async {
          final item = invocation.positionalArguments[2] as DocumentItem;
          final idx = int.parse(item.item.id!.split('Conc').last);
          splitCallbacks[idx][#updateStatus] =
              invocation.positionalArguments[3] as Function;
          splitCallbacks[idx][#onProgress] =
              invocation.positionalArguments[4] as Function;
          splitCallbacks[idx][#onCompleted] =
              invocation.positionalArguments[5] as Function;
          splitCallbacks[idx][#onError] =
              invocation.positionalArguments[6] as Function;
          log.i('Split called for doc $idx');
          // Return immediately, callbacks triggered manually
          return Future.value();
        });

        // Act
        // 1. Add all documents
        for (var i = 0; i < docCount; i++) {
          await documentService.addItem(testTablePrefix, docs[i]);
        }
        async.flushMicrotasks(); // Process addItem futures
        log.i('All items added');

        // 2. Simulate all splits completing almost simultaneously
        for (var i = 0; i < docCount; i++) {
          final item = documentService.items.firstWhere(
            (it) => it.item.id == createdDocs[i].id,
          );
          final mockSplitResponse = {
            'items': [
              {'content': 'Chunk for Conc$i 0'},
            ],
            'mime_type': 'text/plain',
          }; // Simplified
          final mockDocIndexing = createdDocs[i].copyWith(
            status: DocumentStatus.indexing,
            splitted: DateTime.now(),
          );
          final mockEmbeddings = [
            Embedding(
              id: 'emb_table:Conc$i',
              content: 'Chunk for Conc$i 0',
            ),
          ]; // Simplified

          // Mock transaction result specifically for this document during its
          // splitted call
          when(mockSurreal.transaction(any)).thenAnswer((invocation) async {
            final function = invocation.positionalArguments[0] as Future<void>
                Function(dynamic);
            final mockTransaction = MockSurrealTransaction();
            when(mockTransaction.query('', bindings: anyNamed('bindings')))
                .thenAnswer((_) async => []);
            await function(mockTransaction);
            return [
              {'status': 'OK', 'result': mockDocIndexing.toJson()},
              {
                'status': 'OK',
                'result': mockEmbeddings
                    .map(
                      (e) => e.toJson(),
                    )
                    .toList(),
              },
              {'status': 'OK', 'result': <String>[]},
            ];
          });

          log.i('Simulating split completion for doc $i');
          final onCompleted = splitCallbacks[i][#onCompleted]! as Future<void>
              Function(DocumentItem, Map<String, dynamic>?);
          // Don't await here, let them queue at the semaphore
          unawaited(onCompleted(item, mockSplitResponse));
        }
        // Allow _onSplitCompleted futures to run up to semaphore acquire
        async.flushMicrotasks();
        log.i('All splits completed, microtasks flushed');

        // Assert: Check concurrency during execution
        expect(maxObservedConcurrentCalls, lessThanOrEqualTo(maxConcurrency));
        expect(concurrentIndexCalls, maxConcurrency); // Should hit the limit

        // 3. Complete first batch of index calls
        for (var i = 0; i < maxConcurrency; i++) {
          log.i('Completing index call for doc $i');
          indexCallCompleters[i].complete(
            createMockVectors(
              1,
              int.parse(testDimensions),
            ),
          );
        }
        // Process completions and allow waiting calls to acquire semaphore
        async.flushMicrotasks();
        log.i('First batch completed, microtasks flushed');
        // Elapse time to ensure finally blocks execute etc.
        async
          ..elapse(const Duration(milliseconds: 10))
          ..flushMicrotasks();

        // Assert: Concurrency drops, then picks up next batch
        expect(concurrentIndexCalls, maxConcurrency); // Should pick up next one
        // Max shouldn't exceed limit
        expect(maxObservedConcurrentCalls, maxConcurrency);
        // 4. Complete remaining calls
        for (var i = maxConcurrency; i < docCount; i++) {
          log.i('Completing index call for doc $i');
          indexCallCompleters[i].complete(
            createMockVectors(
              1,
              int.parse(testDimensions),
            ),
          );
        }
        async
          ..flushMicrotasks() // Process remaining completions
          ..elapse(const Duration(milliseconds: 10))
          ..flushMicrotasks();

        // Assert: Final state
        expect(concurrentIndexCalls, 0);
        expect(
          documentService.items
              .every((i) => i.item.status == DocumentStatus.completed),
          isTrue,
        );
        verify(
          mockDocumentApiService.index(
            any,
            any,
            any,
            any,
            any,
            batchSize: anyNamed('batchSize'),
            dimensions: anyNamed('dimensions'),
            compressed: anyNamed('compressed'),
            embeddingsDimensionsEnabled:
                anyNamed('embeddingsDimensionsEnabled'),
          ),
        ).called(docCount);
      }); // End fakeAsync
    });
  });
}

// Helper Mock Transaction (if needed for more complex transaction mocking)
class MockSurrealTransaction extends Mock implements Transaction {
  final _log = getLogger('MockSurrealTransaction');

  @override
  Future<dynamic> query(String sql, {Map<String, dynamic>? bindings}) async {
    // Forward to a top-level mock or provide default behavior
    _log.i('MockTransaction query: $sql');
    return super.noSuchMethod(
      Invocation.method(
        #query,
        [sql],
        {#bindings: bindings},
      ),
      returnValue: Future.value([]),
    );
  }
}
