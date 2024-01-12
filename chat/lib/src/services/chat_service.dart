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
import 'package:stopwordies/stopwordies.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';
import 'package:ulid/ulid.dart';

class ChatService with ListenableServiceMixin {
  ChatService() {
    listenToReactiveValues([_chats, _messages]);
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
  String get userId => 'user:${_settingService.get(userIdKey).value}';
  int _chatIndex = -1;
  int _totalChats = 0;
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

  Future<void> fetchMessages(String tablePrefix, int chatIndex) async {
    _chatIndex = chatIndex;
    final messages = await _chatMessageRepository.getAllMessagesOfChat(
      tablePrefix,
      chats[chatIndex].id!,
    );

    if (messages.isNotEmpty) {
      _messages
        ..clear()
        ..addAll(messages);
      _log.d('_messages.length ${_messages.length}');
      notifyListeners();
    }
    _log.d('fetchMessages: _chatIndex $_chatIndex');
  }

  Future<void> addMessage(
    String tablePrefix,
    String authorId,
    String text,
  ) async {
    final now = DateTime.now();
    _log.d('addMessage: _chatIndex $_chatIndex');
    final message = Message(
      id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
      authorId: authorId,
      text: text,
      type: MessageType.text,
      created: now,
      updated: now,
    );
    Chat chat;
    Object? txnResults;
    if (_chatIndex == -1) {
      chat = Chat(
        id: '${tablePrefix}_${Chat.tableName}:${Ulid()}',
        name: defaultChatName,
        created: now,
        updated: now,
      );
      txnResults = await createChatAndMessage(
        tablePrefix,
        chat,
        message,
      );
    } else {
      chat = chats[_chatIndex];
      _log.d('addMessage: chat.id ${chats[_chatIndex].id}');
      txnResults = await createMessage(
        tablePrefix,
        chat,
        message,
      );
    }

    final results = List<List<dynamic>>.from(txnResults! as List);
    if (results.every(
      (sublist) => sublist.isNotEmpty,
    )) {
      if (_chatIndex == -1) {
        _chats.insert(0, chat);
        _chatIndex = 0;
      }
      _messages.insert(0, message);
      notifyListeners();
      if (authorId.startsWith('user')) {
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
        await addMessage(
          tablePrefix,
          defaultAgentId,
          generatedText,
        );
      } else {
        await _updateChatName(text);
      }
    }
  }

  Future<void> _updateChatName(
    String generatedText,
  ) async {
    if (_chats[_chatIndex].name == defaultChatName) {
      var generatedChatName = await _chatApiService.generate(
        _dio,
        [],
        defaultChatWindow,
        '$summarizeInASentencePrompt$generatedText',
        _generationApiUrl,
        _generationApiKey,
        _model,
        _systemPrompt,
      );
      final words = generatedChatName.split(englishWordSeparator);
      final stopWords = await StopWordies.getFor(locale: SWLocale.en);
      final result = words
          .where(
            (item) => !stopWords.contains(item.toLowerCase()),
          )
          .toList();
      if (result.isNotEmpty) {
        if (result.length <= 10) {
          generatedChatName = result.join(englishWordSeparator);
        } else {
          generatedChatName = result.sublist(0, 10).join(englishWordSeparator);
        }
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
