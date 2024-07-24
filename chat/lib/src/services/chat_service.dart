import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/constants.dart';
import 'package:chat/src/services/chat.dart';
import 'package:chat/src/services/chat_api_service.dart';
import 'package:chat/src/services/chat_message.dart';
import 'package:chat/src/services/chat_message_repository.dart';
import 'package:chat/src/services/chat_repository.dart';
import 'package:chat/src/services/message.dart';
import 'package:chat/src/services/message_embedding.dart';
import 'package:chat/src/services/message_embedding_repository.dart';
import 'package:chat/src/services/message_repository.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:surrealdb_js/surrealdb_js.dart';
import 'package:ulid/ulid.dart';

class ChatService with ListenableServiceMixin {
  ChatService() {
    listenToReactiveValues([_chats, _messages, isGeneratingMessage]);
  }

  bool isGeneratingMessage = false;
  List<Chat> get chats => _chats.toList();
  List<Message> get messages => _messages.toList();
  bool get _isStreaming => bool.parse(
        _settingService.get(streamKey, type: bool).value,
      );
  String get userId => '$userIdPrefix${_settingService.get(userIdKey).value}';
  String get _generationApiUrl =>
      _settingService.get(generationApiUrlKey).value;
  String get _generationApiKey => _settingService.get(generationApiKey).value;
  String get _model => _settingService.get(generationModelKey).value;
  String get _systemPrompt => _settingService.get(systemPromptKey).value;
  String get _embeddingsApiUrl =>
      _settingService.get(embeddingsApiUrlKey).value;
  String get _embeddingsApiKey => _settingService.get(embeddingsApiKey).value;
  int get _k => int.parse(
        _settingService.get(retrieveTopNResultsKey, type: int).value,
      );
  String get _promptTemplate => _settingService.get(promptTemplateKey).value;
  String get _searchType => _settingService.get(searchTypeKey).value;

  final _db = locator<Surreal>();
  final _dio = locator<Dio>();
  final _chatApiService = locator<ChatApiService>();
  final _settingService = locator<SettingService>();
  final _documentService = locator<DocumentService>();
  final _chatRepository = locator<ChatRepository>();
  final _messageRepository = locator<MessageRepository>();
  final _chatMessageRepository = locator<ChatMessageRepository>();
  final _embeddingRepository = locator<EmbeddingRepository>();
  final _messageEmbeddingRepository = locator<MessageEmbeddingRepository>();

  final _chats = <Chat>[];
  final _messages = <Message>[];
  int _chatIndex = -1;
  int _totalChats = -1;
  int _totalMessages = -1;
  final _log = getLogger('ChatService');

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = await _db.query('INFO FOR DB');
    final result = Map<String, dynamic>.from(results! as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Chat.tableName}') &&
        tables.containsKey('${tablePrefix}_${Message.tableName}') &&
        tables.containsKey('${tablePrefix}_${ChatMessage.tableName}') &&
        tables.containsKey('${tablePrefix}_${MessageEmbedding.tableName}');
  }

  Future<void> createSchema(
    String tablePrefix, [
    Transaction? txn,
  ]) async {
    if (txn == null) {
      await _db.transaction(
        (txn) async {
          await _chatRepository.createSchema(tablePrefix, txn);
          await _messageRepository.createSchema(tablePrefix, txn);
          await _chatMessageRepository.createSchema(tablePrefix, txn);
          await _messageEmbeddingRepository.createSchema(tablePrefix, txn);
        },
      );
    } else {
      await _chatRepository.createSchema(tablePrefix, txn);
      await _messageRepository.createSchema(tablePrefix, txn);
      await _chatMessageRepository.createSchema(tablePrefix, txn);
      await _messageEmbeddingRepository.createSchema(tablePrefix, txn);
    }
  }

  Future<void> initialise(String tablePrefix) async {
    if (!await isSchemaCreated(tablePrefix)) {
      await createSchema(tablePrefix);
    }
  }

  void newChat() {
    isGeneratingMessage = false;
    _messages.clear();
    _chatIndex = -1;
    _totalMessages = -1;
    notifyListeners();
  }

  Future<void> clearData(String tablePrefix) async {
    await _chatRepository.deleteAllChats(tablePrefix);
    await _messageRepository.deleteAllMessages(tablePrefix);
    _chats.clear();
    _totalChats = -1;
    newChat();
  }

  Future<Object?> createChatAndMessage(
    String tablePrefix,
    Chat chat,
    Message message, [
    Transaction? txn,
  ]) async {
    final chatMessage = ChatMessage(
      chatId: chat.id!,
      messageId: message.id!,
    );
    if (txn == null) {
      return _db.transaction(
        (txn) async {
          await _chatRepository.createChat(
            tablePrefix,
            chat,
            txn,
          );

          await _messageRepository.createMessage(
            tablePrefix,
            message,
            txn,
          );
          await _chatMessageRepository.createChatMessage(
            tablePrefix,
            chatMessage,
            txn,
          );
        },
      );
    } else {
      await _chatRepository.createChat(
        tablePrefix,
        chat,
        txn,
      );

      await _messageRepository.createMessage(
        tablePrefix,
        message,
        txn,
      );
      await _chatMessageRepository.createChatMessage(
        tablePrefix,
        chatMessage,
        txn,
      );
      return null;
    }
  }

  Future<Object?> createMessage(
    String tablePrefix,
    Chat chat,
    Message message, [
    Transaction? txn,
  ]) async {
    final chatMessage = ChatMessage(
      chatId: chat.id!,
      messageId: message.id!,
    );
    List<MessageEmbedding>? messageEmbeddings;
    if (message.embeddings != null && message.embeddings!.isNotEmpty) {
      messageEmbeddings = message.embeddings!
          .map(
            (embedding) => MessageEmbedding(
              messageId: message.id!,
              embeddingId: embedding.id!,
              score: embedding.score!,
              searchType: _searchType,
            ),
          )
          .toList();
    }

    if (txn == null) {
      return _db.transaction(
        (txn) async {
          await _messageRepository.createMessage(
            tablePrefix,
            message,
            txn,
          );
          await _chatMessageRepository.createChatMessage(
            tablePrefix,
            chatMessage,
            txn,
          );

          if (messageEmbeddings != null) {
            await _messageEmbeddingRepository.createMessageEmbeddings(
              tablePrefix,
              messageEmbeddings,
              txn,
            );
          }
        },
      );
    } else {
      await _messageRepository.createMessage(
        tablePrefix,
        message,
        txn,
      );
      await _chatMessageRepository.createChatMessage(
        tablePrefix,
        chatMessage,
        txn,
      );
      if (messageEmbeddings != null) {
        await _messageEmbeddingRepository.createMessageEmbeddings(
          tablePrefix,
          messageEmbeddings,
          txn,
        );
      }
      return null;
    }
  }

  Future<ChatList> getChatList(
    String tablePrefix, {
    int? page,
    int pageSize = 20,
    bool ascendingOrder = false,
  }) async {
    final items = await _chatRepository.getAllChats(
      tablePrefix,
      page: page,
      pageSize: pageSize,
      ascendingOrder: ascendingOrder,
    );
    final total = await _chatRepository.getTotal(tablePrefix);
    return ChatList(items, total);
  }

  bool get hasReachedMaxChat {
    final reachedMax = _totalChats > -1 && _chats.length >= _totalChats;
    _log.d(reachedMax);
    return reachedMax;
  }

  bool get hasReachedMaxMessage {
    final reachedMax = _messages.length >= _totalMessages;
    _log.d(reachedMax);
    return reachedMax;
  }

  Future<void> fetchChats(String tablePrefix) async {
    final page = _chats.length ~/ defaultPageSize;
    _log.d('page $page');
    final chatList = await getChatList(
      tablePrefix,
      page: page,
      pageSize: defaultPageSize,
    );
    _log.d('chatList.total ${chatList.total}');
    if (chatList.total > 0 && chatList.total > _chats.length) {
      _chats.addAll(chatList.items);
      _totalChats = chatList.total;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String tablePrefix, [int chatIndex = -1]) async {
    if (chatIndex > -1) {
      _chatIndex = chatIndex;
    }

    if (_chatIndex > -1) {
      final page = _messages.length ~/ defaultPageSize;
      final messageList = await _chatMessageRepository.getAllMessagesOfChat(
        tablePrefix,
        chats[_chatIndex].id!,
        page: page,
        pageSize: defaultPageSize,
      );

      if (messageList.total > 0) {
        final messagesWithEmbeddings = <Message>[];
        for (final message in messageList.items) {
          if (message.role == Role.agent) {
            messagesWithEmbeddings.add(
              message.copyWith(
                embeddings:
                    await _messageEmbeddingRepository.getAllEmbeddingsOfMessage(
                  tablePrefix,
                  message.id!,
                ),
              ),
            );
          } else {
            messagesWithEmbeddings.add(message);
          }
        }
        _messages
          ..clear()
          ..addAll(messagesWithEmbeddings);
        _log.d('_messages.length ${_messages.length}');
        _totalMessages = messageList.total;
        notifyListeners();
      }
      _log.d('fetchMessages: _chatIndex $_chatIndex');
    }
  }

  void _onMessageTextResponse(String content) {
    if (_messages.first.status == Status.sending) {
      _messages.first = _messages.first.copyWith(
        text: content,
        status: Status.sent,
      );
    } else {
      _messages.first = _messages.first.copyWith(
        text: _messages.first.text + content,
      );
    }
    notifyListeners();
  }

  Future<void> _onMessageTextResponseCompleted() async {
    isGeneratingMessage = false;
    var tablePrefix = _messages.first.id!;
    tablePrefix = tablePrefix.substring(0, tablePrefix.indexOf('_'));
    await _addMessageWithChat(tablePrefix, _messages.first);
    notifyListeners();
  }

  void _onChatNameResponse(String content) {
    final chat = _chats[_chatIndex];
    _chats[_chatIndex] = chat.copyWith(
      name: chat.name != newChatName ? chat.name + content : content,
    );
    notifyListeners();
  }

  Future<void> _onChatNameResponseCompleted() async {
    final chat = _chats[_chatIndex];
    await _chatRepository.updateChat(chat);
  }

  void _addLoadingMessage(String tablePrefix) {
    final now = DateTime.now();
    _messages.insert(
      0,
      Message(
        id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
        authorId: defaultAgentId,
        role: Role.agent,
        text: '',
        type: MessageType.text,
        status: Status.sending,
        created: now,
        updated: now,
      ),
    );
    notifyListeners();
  }

  Future<bool> _addMessageWithChat(String tablePrefix, Message message) async {
    final chat = _chats[_chatIndex];
    _log.d('addMessage: chat.id ${_chats[_chatIndex].id}');
    final txnResults = await createMessage(
      tablePrefix,
      chat,
      message,
    );
    final results = List<Map<dynamic, dynamic>>.from(txnResults! as List);
    final isTxnSucess = results.every(
      (sublist) => sublist.isNotEmpty,
    );
    if (isTxnSucess) {
      if (chat.name == newChatName) {
        final responseStream = _chatApiService.generateStream(
          _dio,
          [],
          defaultChatWindow,
          '$summarizeInASentencePrompt${_messages.first.text}',
          _generationApiUrl,
          _generationApiKey,
          _model,
          chatNameSummarizerSystemPrompt,
        );
        await for (final content in responseStream) {
          _onChatNameResponse(content);
        }
        await _onChatNameResponseCompleted();
      }
    } else {
      throw Exception('Unable to create message.');
    }
    return isTxnSucess;
  }

  Future<bool> _addMessage(
    String tablePrefix,
    String authorId,
    Role role,
    String text,
  ) async {
    final now = DateTime.now();
    _log.d('addMessage: _chatIndex $_chatIndex');
    final message = Message(
      id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
      authorId: authorId,
      role: role,
      text: text,
      type: MessageType.text,
      created: now,
      updated: now,
    );

    bool isTxnSucess;
    if (_chatIndex == -1) {
      final chat = Chat(
        id: '${tablePrefix}_${Chat.tableName}:${Ulid()}',
        name: newChatName,
        created: now,
        updated: now,
      );
      final txnResults = await createChatAndMessage(
        tablePrefix,
        chat,
        message,
      );
      final results = List<Map<dynamic, dynamic>>.from(txnResults! as List);
      isTxnSucess = results.every(
        (sublist) => sublist.isNotEmpty,
      );
      if (isTxnSucess) {
        _log.d('message ${message.authorId} _chats.length ${_chats.length}}');
        _chats.insert(0, chat);
        _chatIndex = 0;
        _totalChats += 1;
      } else {
        throw Exception('Unable to create chat and message.');
      }
    } else {
      isTxnSucess = await _addMessageWithChat(tablePrefix, message);
    }

    if (isTxnSucess) {
      if (role == Role.user) {
        _messages.insert(0, message);
      } else {
        _messages.first = message;
      }
      notifyListeners();
    }
    return isTxnSucess;
  }

  Future<void> addMessage(
    String tablePrefix,
    String authorId,
    Role role,
    String text,
  ) async {
    final isSuccess = await _addMessage(tablePrefix, authorId, role, text);
    if (isSuccess) {
      if (role == Role.user) {
        isGeneratingMessage = true;
        _addLoadingMessage(tablePrefix); // messages[0] status is sending
        if (_isStreaming) {
          await _rag(tablePrefix, text);
        } else {
          final generatedText = await _rag(tablePrefix, text);
          isGeneratingMessage = false;
          await addMessage(
            tablePrefix,
            defaultAgentId,
            Role.agent,
            generatedText,
          );
        }
      } else {
        await _updateChatName(text);
      }
    }
  }

  Stream<String> generateMessageText(String prompt) async* {
    yield* _chatApiService.generateStream(
      _dio,
      messages,
      defaultChatWindow,
      prompt,
      _generationApiUrl,
      _generationApiKey,
      _model,
      _systemPrompt,
    );
  }

  Future<void> _updateChatName(
    String generatedText,
  ) async {
    if (_chats[_chatIndex].name == newChatName) {
      final generatedChatName = await _chatApiService.generate(
        _dio,
        [],
        defaultChatWindow,
        '$summarizeInASentencePrompt$generatedText',
        _generationApiUrl,
        _generationApiKey,
        _model,
        chatNameSummarizerSystemPrompt,
      );

      if (generatedChatName.isNotEmpty) {
        final updatedChat = await _chatRepository.updateChat(
          _chats[_chatIndex].copyWith(
            name: generatedChatName,
          ),
        );
        if (updatedChat != null) {
          _chats[_chatIndex] = updatedChat;
          notifyListeners();
        }
      }
    }
  }

  Future<List<Embedding>> _retrieve(
    String tablePrefix,
    String input,
  ) async {
    if (await _embeddingRepository.getTotal(tablePrefix) == 0) {
      return List.empty();
    }
    final responseData = await _chatApiService.embed(
      _dio,
      _embeddingsApiUrl,
      _embeddingsApiKey,
      input,
    );
    final embedding = (responseData?['data'] as List).first as Map;
    final queryVector = List<double>.from(embedding['embedding'] as List);
    final embeddings = await _documentService.similaritySearch(
      tablePrefix,
      queryVector,
      _k,
      0.5,
    );
    return embeddings;
  }

  Future<String> _rag(String tablePrefix, String input) async {
    final embeddings = await _retrieve(tablePrefix, input);
    String prompt;
    if (embeddings.isNotEmpty) {
      final context = embeddings.map((e) {
        return '${e.content} ${e.score} ${e.id}';
      }).join('\n');
      prompt = _promptTemplate
          .replaceFirst(contextPlaceholder, context)
          .replaceFirst(instructionPlaceholder, input);
      _messages.first = _messages.first.copyWith(embeddings: embeddings);
    } else {
      prompt = input;
    }

    if (_isStreaming) {
      final responseStream = generateMessageText(prompt);
      await for (final content in responseStream) {
        _onMessageTextResponse(content);
      }
      await _onMessageTextResponseCompleted();
      return '';
    } else {
      final generatedText = await _chatApiService.generate(
        _dio,
        messages,
        defaultChatWindow,
        prompt,
        _generationApiUrl,
        _generationApiKey,
        _model,
        _systemPrompt,
      );
      return generatedText;
    }
  }
}
