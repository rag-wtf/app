import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:stacked/stacked.dart';

class ChatListViewModel extends ReactiveViewModel {
  ChatListViewModel(this.tablePrefix);
  final String tablePrefix;
  final _chatService = locator<ChatService>();
  final _log = getLogger('ChatListViewModel');

  @override
  List<ListenableServiceMixin> get listenableServices => [_chatService];

  List<Chat> get chats => _chatService.chats;

  bool get hasReachedMaxChat => _chatService.hasReachedMaxChat;

  Future<void> fetchChats() async {
    await _chatService.fetchChats(tablePrefix);
  }

  Future<void> fetchMessages(int chatIndex) async {
    await _chatService.fetchMessages(tablePrefix, chatIndex);
  }
}
