import 'package:chat/chat.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:document/document.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:settings/settings.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
import 'package:ulid/ulid.dart';

import 'test_data.dart';

void main({bool wasm = false}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final db = locator<Surreal>();
  final messageRepository = locator<MessageRepository>();
  final embeddingRepository = locator<EmbeddingRepository>();
  final messageEmbeddingRepository = locator<MessageEmbeddingRepository>();
  const tablePrefix = 'msg_emb';
  const defaultSearchType = 'COSINE';

  setUpAll(() async {
    if (wasm) {
      await db.connect(surrealIndxdbEndpoint);
      await db.use(namespace: surrealNamespace, database: surrealDatabase);
    } else {
      await db.connect(surrealHttpEndpoint);
      await db.use(namespace: surrealNamespace, database: surrealDatabase);
      await db
          .signin({'username': surrealUsername, 'password': surrealPassword});
    }
  });

  tearDownAll(() async {
    await db.close();
  });

  tearDown(() async {
    await messageRepository.deleteAllMessages(tablePrefix);
    await embeddingRepository.deleteAllEmbeddings(tablePrefix);
  });

  group('isSchemaCreated', () {
    test('should return false', () async {
      // Assert
      expect(
        await messageRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
      expect(
        await embeddingRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
      expect(
        await messageEmbeddingRepository.isSchemaCreated(tablePrefix),
        isFalse,
      );
    });

    test('should create schemas and return true', () async {
      // Act
      await db.transaction(
        (txn) async {
          if (!await messageRepository.isSchemaCreated(tablePrefix)) {
            await messageRepository.createSchema(tablePrefix, txn);
          }
          if (!await embeddingRepository.isSchemaCreated(tablePrefix)) {
            await embeddingRepository.createSchema(tablePrefix, '384', txn);
          }
          if (!await messageEmbeddingRepository.isSchemaCreated(tablePrefix)) {
            await messageEmbeddingRepository.createSchema(
              tablePrefix,
              txn,
            );
          }
        },
      );

      // Assert
      expect(
        await messageRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
      expect(
        await embeddingRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
      expect(
        await messageEmbeddingRepository.isSchemaCreated(tablePrefix),
        isTrue,
      );
    });
  });

  test('should create message embedding', () async {
    // Arrange
    final message = Message(
      id: Ulid().toString(),
      authorId: 'userId:1',
      role: Role.user,
      value: const Embedding(content: 'user message 1'),
      type: MessageType.text,
    );
    final embedding = Embedding(
      id: Ulid().toString(),
      content: 'apple',
      embedding: testData['apple']!,
    );

    // Act
    final txnResults = await db.transaction(
      (Transaction txn) async {
        await messageRepository.createMessage(
          tablePrefix,
          message,
          txn,
        );
        await embeddingRepository.createEmbedding(
          tablePrefix,
          embedding,
          txn,
        );
        await messageEmbeddingRepository.createMessageEmbedding(
          tablePrefix,
          MessageEmbedding(
            messageId: message.id!,
            embeddingId: embedding.id!,
            score: 0,
            searchType: defaultSearchType,
          ),
          txn,
        );
      },
    );

    // Assert
    final results = List<Map<dynamic, dynamic>>.from(txnResults! as List);
    expect(results.every((sublist) => sublist.isNotEmpty), isTrue);
    expect(
      await db.select('${tablePrefix}_${MessageEmbedding.tableName}'),
      isNotNull,
    );
  });

  test('should create message embeddings', () async {
    // Arrange
    final message = Message(
      id: Ulid().toString(),
      authorId: 'userId:1',
      role: Role.user,
      value: const Embedding(content: 'user message 1'),
      type: MessageType.text,
    );

    final embeddings = [
      Embedding(
        id: Ulid().toString(),
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
      ),
      Embedding(
        id: Ulid().toString(),
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
      ),
      Embedding(
        id: Ulid().toString(),
        content: 'twenty',
        embedding: testData['twenty']!,
        metadata: {'id': 'customId3'},
      ),
      Embedding(
        id: Ulid().toString(),
        content: 'two',
        embedding: testData['two']!,
        metadata: {'id': 'customId4'},
      ),
      Embedding(
        id: Ulid().toString(),
        content: 'banana',
        embedding: testData['banana']!,
        metadata: {'id': 'customId5'},
      ),
    ];

    final messageEmbeddings = <MessageEmbedding>[];
    for (final embedding in embeddings) {
      messageEmbeddings.add(
        MessageEmbedding(
          messageId: message.id!,
          embeddingId: embedding.id!,
          score: 0,
          searchType: defaultSearchType,
        ),
      );
    }
    // Act
    final txnResults = await db.transaction(
      (txn) async {
        await messageRepository.createMessage(
          tablePrefix,
          message,
          txn,
        );
        await embeddingRepository.createEmbeddings(
          tablePrefix,
          embeddings,
          txn,
        );
        await messageEmbeddingRepository.createMessageEmbeddings(
          tablePrefix,
          messageEmbeddings,
          txn,
        );
      },
    );

    // Assert
    final results = txnResults! as List;
    expect(
      results.every(
        (sublist) => sublist is Iterable
            ? sublist.isNotEmpty
            : (sublist as Map).isNotEmpty,
      ),
      isTrue,
    );
    expect(
      await db.select('${tablePrefix}_${MessageEmbedding.tableName}'),
      hasLength(messageEmbeddings.length),
    );
  });

  test('should retrieve embeddings of given message Id', () async {
    // Arrange
    final message1 = Message(
      id: Ulid().toString(),
      authorId: 'userId:1',
      role: Role.user,
      value: const Embedding(content: 'user message 1'),
      type: MessageType.text,
    );

    // Arrange
    final message2 = Message(
      id: Ulid().toString(),
      authorId: 'userId:1',
      role: Role.user,
      value: const Embedding(content: 'user message 2'),
      type: MessageType.text,
    );

    final embeddings1 = [
      Embedding(
        id: Ulid().toString(),
        content: 'apple',
        embedding: testData['apple']!,
        metadata: {'id': 'customId1'},
      ),
      Embedding(
        id: Ulid().toString(),
        content: 'ten',
        embedding: testData['ten']!,
        metadata: {'id': 'customId2'},
      ),
    ];
    final embeddings2 = [
      Embedding(
        id: Ulid().toString(),
        content: 'twenty',
        embedding: testData['twenty']!,
        metadata: {'id': 'customId3'},
      ),
      Embedding(
        id: Ulid().toString(),
        content: 'two',
        embedding: testData['two']!,
        metadata: {'id': 'customId4'},
      ),
      Embedding(
        id: Ulid().toString(),
        content: 'banana',
        embedding: testData['banana']!,
        metadata: {'id': 'customId5'},
      ),
    ];

    final messageEmbeddings1 = <MessageEmbedding>[];
    for (final embedding in embeddings1) {
      messageEmbeddings1.add(
        MessageEmbedding(
          messageId: message1.id!,
          embeddingId: embedding.id!,
          score: 0,
          searchType: defaultSearchType,
        ),
      );
    }

    final messageEmbeddings2 = <MessageEmbedding>[];
    for (final embedding in embeddings2) {
      messageEmbeddings2.add(
        MessageEmbedding(
          messageId: message2.id!,
          embeddingId: embedding.id!,
          score: 0,
          searchType: defaultSearchType,
        ),
      );
    }
    // Act
    final txnResults = await db.transaction(
      (txn) async {
        await messageRepository.createMessage(
          tablePrefix,
          message1,
          txn,
        );
        await messageRepository.createMessage(
          tablePrefix,
          message2,
          txn,
        );
        await embeddingRepository.createEmbeddings(
          tablePrefix,
          embeddings1,
          txn,
        );
        await embeddingRepository.createEmbeddings(
          tablePrefix,
          embeddings2,
          txn,
        );
        await messageEmbeddingRepository.createMessageEmbeddings(
          tablePrefix,
          messageEmbeddings1,
          txn,
        );
        await messageEmbeddingRepository.createMessageEmbeddings(
          tablePrefix,
          messageEmbeddings2,
          txn,
        );
      },
    );

    // Assert
    final results = txnResults! as List;
    expect(
      results.every(
        (sublist) => sublist is Iterable
            ? sublist.isNotEmpty
            : (sublist as Map).isNotEmpty,
      ),
      isTrue,
    );
    expect(
      await messageEmbeddingRepository.getAllEmbeddingsOfMessage(
        tablePrefix,
        message2.id!,
      ),
      hasLength(messageEmbeddings2.length),
    );
  });
}
