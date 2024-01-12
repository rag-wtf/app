import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/constants.dart';
import 'package:chat/src/services/chat.dart';
import 'package:chat/src/services/chat_api_service.dart';
import 'package:chat/src/services/chat_message_repository.dart';
import 'package:chat/src/services/chat_repository.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/message.dart';
import 'package:dio/dio.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:stopwordies/stopwordies.dart';
import 'package:ulid/ulid.dart';

const int defaultPageSize = 10;

class ChatViewModel extends FutureViewModel<void> {
  ChatViewModel(this.tablePrefix);
  final String tablePrefix;
  List<Chat> get chats => _chats.toList();
  List<Message> get messages => _messages.toList();
  String get userId => 'user:${_settingService.get(userIdKey).value}';
  int _chatIndex = -1;
  int _totalChats = 0;
  final _chats = <Chat>[];
  final _messages = <Message>[];
  final _chatService = locator<ChatService>();
  final _chatRepository = locator<ChatRepository>();
  final _chatMessageRepository = locator<ChatMessageRepository>();
  final _dio = locator<Dio>();
  final _chatApiService = locator<ChatApiService>();
  final _settingService = locator<SettingService>();
  String get _generationApiUrl =>
      _settingService.get(generationApiUrlKey).value;
  String get _generationApiKey => _settingService.get(generationApiKey).value;
  String get _model => _settingService.get(generationModelKey).value;
  String get _systemPrompt => _settingService.get(systemPromptKey).value;
  final _log = getLogger('ChatViewModel');
  @override
  Future<void> futureToRun() async {
    _log.d('futureToRun() tablePrefix: $tablePrefix');

    final isSchemaCreated = await _chatService.isSchemaCreated(tablePrefix);
    _log.d('isSchemaCreated $isSchemaCreated');

    if (!isSchemaCreated) {
      _log.d('before createSchema()');
      await _chatService.createSchema(tablePrefix);
      _log.d('after createSchema()');
    }
    await fetchChats();
  }

  bool get hasReachedMaxChat {
    final reachedMax = _chats.length >= _totalChats;
    _log.d(reachedMax);
    return reachedMax;
  }

  Future<void> fetchChats() async {
    final page = _chats.length ~/ defaultPageSize;
    _log.d('page $page');
    final chatList = await _chatService.getChatList(
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

  Future<void> fetchMessages(int chatIndex) async {
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
      txnResults = await _chatService.createChatAndMessage(
        tablePrefix,
        chat,
        message,
      );
    } else {
      chat = chats[_chatIndex];
      _log.d('addMessage: chat.id ${chats[_chatIndex].id}');
      txnResults = await _chatService.createMessage(
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
          defaultAgentId,
          generatedText,
        );
        await _updateChatName(text, generatedText);
      }
    }
  }

  Future<void> _updateChatName(
    String userText,
    String generatedText,
  ) async {
    if (_chats[_chatIndex].name == defaultChatName) {
      var generatedChatName = await _chatApiService.generate(
        _dio,
        [],
        defaultChatWindow,
        '$summarizeInASentencePrompt$userText $generatedText',
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
        }
      }
    }
  }
}
