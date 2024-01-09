import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/conversation.dart';
import 'package:chat/src/services/conversation_repository.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';

const int defaultPageSize = 10;

class ChatViewModel extends FutureViewModel<void> {
  ChatViewModel(this.tablePrefix);
  final String tablePrefix;
  int _total = 0;
  final _items = <Conversation>[];
  List<Conversation> get items => _items;
  final _chatService = locator<ChatService>();
  final _conversationRepository = locator<ConversationRepository>();
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
    await fetchData();
  }

  bool get hasReachedMax {
    final reachedMax = _items.length >= _total;
    _log.d(reachedMax);
    return reachedMax;
  }

  Future<void> fetchData() async {
    final page = _items.length ~/ defaultPageSize;
    _log.d('page $page');
    final conversationList = await _chatService.getConversationList(
      tablePrefix,
      page: page,
      pageSize: defaultPageSize,
    );
    _log.d('conversationList.total ${conversationList.total}');
    if (conversationList.total > 0) {
      _items.addAll(conversationList.items);
      _total = conversationList.total;
      notifyListeners();
    }
  }

  Future<void> addItem(Conversation conversation) async {
    final createdConversation =
        await _conversationRepository.createConversation(
      tablePrefix,
      conversation,
    );
    if (createdConversation.id != null) {
      _items.insert(0, createdConversation);
      notifyListeners();
    }
  }
}
