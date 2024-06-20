import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/message.dart';
import 'package:stacked/stacked.dart';

class ChatViewModel extends ReactiveViewModel {
  ChatViewModel(this.tablePrefix);
  final String tablePrefix;
  final _chatService = locator<ChatService>();
  final _log = getLogger('ChatViewModel');

  @override
  List<ListenableServiceMixin> get listenableServices => [_chatService];

  String get userId => _chatService.userId;

  bool get hasReachedMax => _chatService.hasReachedMaxMessage;

  List<Message> get messages => _chatService.messages;

  bool get isGenerating => _chatService.isGeneratingMessage;

  Future<void> addMessage(
    String authorId,
    String text,
  ) async {
    _log.d('addMessage($authorId, $text)');
    await _chatService.addMessage(
      tablePrefix,
      authorId,
      Role.user,
      text,
    );
  }

  Future<void> fetchMessages() async {
    await _chatService.fetchMessages(tablePrefix);
  }

  void newChat() {
    _chatService.newChat();
  }
}
