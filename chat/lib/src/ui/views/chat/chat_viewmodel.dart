import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/constants.dart';
import 'package:chat/src/services/chat_api_service.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/conversation.dart';
import 'package:chat/src/services/conversation_message_repository.dart';
import 'package:chat/src/services/conversation_repository.dart';
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
  List<Conversation> get conversations => _conversations.toList();
  List<Message> get messages => _messages.toList();
  String get userId => 'user:${_settingService.get(userIdKey).value}';
  int _conversationIndex = -1;
  int _totalConversations = 0;
  final _conversations = <Conversation>[];
  final _messages = <Message>[];
  final _chatService = locator<ChatService>();
  final _conversationRepository = locator<ConversationRepository>();
  final _conversationMessageRepository =
      locator<ConversationMessageRepository>();
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
    await fetchConversations();
  }

  bool get hasReachedMaxConversation {
    final reachedMax = _conversations.length >= _totalConversations;
    _log.d(reachedMax);
    return reachedMax;
  }

  Future<void> fetchConversations() async {
    final page = _conversations.length ~/ defaultPageSize;
    _log.d('page $page');
    final conversationList = await _chatService.getConversationList(
      tablePrefix,
      page: page,
      pageSize: defaultPageSize,
    );
    _log.d('conversationList.total ${conversationList.total}');
    if (conversationList.total > 0) {
      _conversations.addAll(conversationList.items);
      _totalConversations = conversationList.total;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(int conversationIndex) async {
    _conversationIndex = conversationIndex;
    final messages =
        await _conversationMessageRepository.getAllMessagesOfConversation(
      tablePrefix,
      conversations[conversationIndex].id!,
    );

    if (messages.isNotEmpty) {
      _messages
        ..clear()
        ..addAll(messages);
      _log.d('_messages.length ${_messages.length}');
      notifyListeners();
    }
    _log.d('fetchMessages: _conversationIndex $_conversationIndex');
  }

  Future<void> addMessage(
    String authorId,
    String text,
  ) async {
    final now = DateTime.now();
    _log.d('addMessage: _conversationIndex $_conversationIndex');
    final message = Message(
      id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
      authorId: authorId,
      text: text,
      type: MessageType.text,
      created: now,
      updated: now,
    );
    Conversation conversation;
    Object? txnResults;
    if (_conversationIndex == -1) {
      conversation = Conversation(
        id: '${tablePrefix}_${Conversation.tableName}:${Ulid()}',
        name: defaultConversationName,
        created: now,
        updated: now,
      );
      txnResults = await _chatService.createConversationAndMessage(
        tablePrefix,
        conversation,
        message,
      );
    } else {
      conversation = conversations[_conversationIndex];
      _log.d(
          'addMessage: conversation.id ${conversations[_conversationIndex].id}');
      txnResults = await _chatService.createMessage(
        tablePrefix,
        conversation,
        message,
      );
    }

    final results = List<List<dynamic>>.from(txnResults! as List);
    if (results.every(
      (sublist) => sublist.isNotEmpty,
    )) {
      if (_conversationIndex == -1) {
        _conversations.insert(0, conversation);
        _conversationIndex = 0;
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
        await _updateConversationName(text, generatedText);
      }
    }
  }

  Future<void> _updateConversationName(
    String userText,
    String generatedText,
  ) async {
    if (_conversations[_conversationIndex].name == defaultConversationName) {
      var generatedConversationName = await _chatApiService.generate(
        _dio,
        [],
        defaultChatWindow,
        '$summarizeInASentencePrompt$userText $generatedText',
        _generationApiUrl,
        _generationApiKey,
        _model,
        _systemPrompt,
      );
      final words = generatedConversationName.split(englishWordSeparator);
      final stopWords = await StopWordies.getFor(locale: SWLocale.en);
      final result = words
          .where(
            (item) => !stopWords.contains(item.toLowerCase()),
          )
          .toList();
      if (result.isNotEmpty) {
        if (result.length <= 10) {
          generatedConversationName = result.join(englishWordSeparator);
        } else {
          generatedConversationName =
              result.sublist(0, 10).join(englishWordSeparator);
        }
        final updatedConversation =
            await _conversationRepository.updateConversation(
          _conversations[_conversationIndex].copyWith(
            name: generatedConversationName,
            updated: DateTime.now(),
          ),
        );
        if (updatedConversation != null) {
          _conversations[_conversationIndex] = updatedConversation;
        }
      }
    }
  }
}
