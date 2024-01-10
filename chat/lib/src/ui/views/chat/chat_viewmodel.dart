import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/conversation.dart';
import 'package:chat/src/services/conversation_message_repository.dart';
import 'package:chat/src/services/conversation_repository.dart';
import 'package:chat/src/services/message.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:ulid/ulid.dart';

const int defaultPageSize = 10;

class ChatViewModel extends FutureViewModel<void> {
  ChatViewModel(this.tablePrefix);
  final String tablePrefix;
  List<Conversation> get conversations => _conversations.toList();
  List<Message> get messages => _messages.toList();
  String get userId => _settingService.get(userIdKey).value;
  int _conversationIndex = -1;
  int _totalConversations = 0;
  final _conversations = <Conversation>[];
  final _messages = <Message>[];
  final _chatService = locator<ChatService>();
  final _conversationRepository = locator<ConversationRepository>();
  final _conversationMessageRepository =
      locator<ConversationMessageRepository>();
  final _settingService = locator<SettingService>();
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

  Future<void> fetchMessages(String conversationId) async {
    final messages =
        await _conversationMessageRepository.getAllMessagesOfConversation(
      tablePrefix,
      conversationId,
    );

    if (messages.isNotEmpty) {
      _messages.addAll(messages);
      notifyListeners();
    }
  }

  Future<void> addMessage(String text) async {
    final now = DateTime.now();
    final conversation = Conversation(
      id: '${tablePrefix}_${Conversation.tableName}:${Ulid()}',
      name: text,
      created: now,
      updated: now,
    );
    final message = Message(
      id: '${tablePrefix}_${Message.tableName}:${Ulid()}',
      authorId: 'user:$userId',
      text: text,
      type: MessageType.text,
      created: now,
      updated: now,
    );
    final txnResults = await _chatService.createConversationAndMessage(
      tablePrefix,
      conversation,
      message,
    );

    final results = List<List<dynamic>>.from(txnResults! as List);
    if (results.every(
      (sublist) => sublist.isNotEmpty,
    )) {
      _conversations.insert(0, conversation);
      _messages.insert(0, message);
      notifyListeners();
    }
  }
}
