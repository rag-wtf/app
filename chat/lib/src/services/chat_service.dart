import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/constants.dart';
import 'package:chat/src/services/chat.dart';
import 'package:chat/src/services/chat_api_service.dart';
import 'package:chat/src/services/chat_message.dart';
import 'package:chat/src/services/chat_message_repository.dart';
import 'package:chat/src/services/chat_repository.dart';
import 'package:chat/src/services/message.dart';
import 'package:chat/src/services/message_repository.dart';
import 'package:dio/dio.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';

class ChatService with ListenableServiceMixin {
  ChatService() {
    listenToReactiveValues([_chats, _messages, isGeneratingMessage]);
  }

  final _db = locator<Surreal>();
  final _dio = locator<Dio>();
  final _chatApiService = locator<ChatApiService>();
  final _settingService = locator<SettingService>();
  final _chatRepository = locator<ChatRepository>();
  final _messageRepository = locator<MessageRepository>();
  final _chatMessageRepository = locator<ChatMessageRepository>();
  List<Chat> get chats => _chats.toList();
  List<Message> get messages => _messages.toList();
  bool isGeneratingMessage = false;
  String get userId => '$userIdPrefix${_settingService.get(userIdKey).value}';
  int _chatIndex = -1;
  int _totalChats = 0;
  int _totalMessages = 0;
  final _chats = <Chat>[];
  final _messages = <Message>[];

  String get _generationApiUrl =>
      _settingService.get(generationApiUrlKey).value;
  String get _generationApiKey => _settingService.get(generationApiKey).value;
  String get _model => _settingService.get(generationModelKey).value;
  String get _systemPrompt => _settingService.get(systemPromptKey).value;
  final _log = getLogger('ChatService');

  Future<bool> isSchemaCreated(String tablePrefix) async {
    final results = (await _db.query('INFO FOR DB'))! as List;
    final result = Map<String, dynamic>.from(results.first as Map);
    final tables = Map<String, dynamic>.from(result['tables'] as Map);
    return tables.containsKey('${tablePrefix}_${Chat.tableName}') &&
        tables.containsKey('${tablePrefix}_${Message.tableName}') &&
        tables.containsKey('${tablePrefix}_${ChatMessage.tableName}');
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
        },
      );
    } else {
      await _chatRepository.createSchema(tablePrefix, txn);
      await _messageRepository.createSchema(tablePrefix, txn);
      await _chatMessageRepository.createSchema(tablePrefix, txn);
    }
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
    final reachedMax = _chats.length >= _totalChats;
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
    if (chatList.total > 0) {
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
        _messages
          ..clear()
          ..addAll(messageList.items);
        _log.d('_messages.length ${_messages.length}');
        _totalMessages = messageList.total;
        notifyListeners();
      }
      _log.d('fetchMessages: _chatIndex $_chatIndex');
    }
  }

  Future<void> _onMessageTextResponse(String content) async {
    if (content == stopToken) {
      isGeneratingMessage = false;
      var tablePrefix = _messages.first.id!;
      tablePrefix = tablePrefix.substring(0, tablePrefix.indexOf('_'));
      await _addMessageWithChat(tablePrefix, _messages.first);
    } else {
      if (_messages.first.type == MessageType.loading) {
        _messages.first = _messages.first.copyWith(
          type: MessageType.text,
          text: content,
          updated: DateTime.now(),
        );
      } else {
        _messages.first = _messages.first.copyWith(
          text: _messages.first.text + content,
          updated: DateTime.now(),
        );
      }
    }
    notifyListeners();
  }

  Future<void> _onChatNameResponse(String content) async {
    _log.d('_chatIndex $_chatIndex');
    final chat = _chats[_chatIndex];
    if (content == stopToken) {
      await _chatRepository.updateChat(chat);
    } else {
      _chats[_chatIndex] = chat.copyWith(
        name: chat.name != defaultChatName ? chat.name + content : content,
        updated: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void _addLoadingMessage(String tablePrefix) {
    isGeneratingMessage = true;
    final now = DateTime.now();
    _messages.insert(
      0,
      Message(
        id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
        authorId: defaultAgentId,
        role: Role.agent,
        text: '',
        type: MessageType.loading,
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
    final results = List<List<dynamic>>.from(txnResults! as List);
    final isTxnSucess = results.every(
      (sublist) => sublist.isNotEmpty,
    );
    if (isTxnSucess) {
      if (chat.name == defaultChatName) {
        await _chatApiService.generateStream(
          _dio,
          [],
          defaultChatWindow,
          '$summarizeInASentencePrompt${_messages.first.text}',
          _generationApiUrl,
          _generationApiKey,
          _model,
          _systemPrompt,
          _onChatNameResponse,
        );
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
        name: defaultChatName,
        created: now,
        updated: now,
      );
      final txnResults = await createChatAndMessage(
        tablePrefix,
        chat,
        message,
      );
      final results = List<List<dynamic>>.from(txnResults! as List);
      isTxnSucess = results.every(
        (sublist) => sublist.isNotEmpty,
      );
      if (isTxnSucess) {
        _chats.insert(0, chat);
        _chatIndex = 0;
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
        final isStreaming = bool.parse(
          _settingService.get(streamKey, type: bool).value,
        );
        _addLoadingMessage(tablePrefix);
        if (isStreaming) {
          await _chatApiService.generateStream(
            _dio,
            messages,
            defaultChatWindow,
            text,
            _generationApiUrl,
            _generationApiKey,
            _model,
            _systemPrompt,
            _onMessageTextResponse,
          );
        } else {
          final generatedText = await _chatApiService.generate(
            _dio,
            messages,
            defaultChatWindow,
            text,
            _generationApiUrl,
            _generationApiKey,
            _model,
            _systemPrompt,
          );
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

  Future<void> _updateChatName(
    String generatedText,
  ) async {
    if (_chats[_chatIndex].name == defaultChatName) {
      final generatedChatName = await _chatApiService.generate(
        _dio,
        [],
        defaultChatWindow,
        '$summarizeInASentencePrompt$generatedText',
        _generationApiUrl,
        _generationApiKey,
        _model,
        _systemPrompt,
      );

      if (generatedChatName.isNotEmpty) {
        final updatedChat = await _chatRepository.updateChat(
          _chats[_chatIndex].copyWith(
            name: generatedChatName,
            updated: DateTime.now(),
          ),
        );
        if (updatedChat != null) {
          _chats[_chatIndex] = updatedChat;
          notifyListeners();
        }
      }
    }
  }
}
