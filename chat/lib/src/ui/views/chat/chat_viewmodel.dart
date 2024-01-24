import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat_service.dart';
import 'package:chat/src/services/message.dart';
import 'package:document/document.dart';
import 'package:stacked/stacked.dart';

class ChatViewModel extends ReactiveViewModel {
  ChatViewModel(this.tablePrefix);
  final String tablePrefix;
  final _chatService = locator<ChatService>();
  final _log = getLogger('ChatViewModel');
  static const _dummyText =
      'A powerful HTTP networking package for Dart/Flutter, supports Global configuration, Interceptors, FormData, Request cancellation, File uploading/downloading, Timeout, Custom adapters, Transformers, etc.';
  final embeddings = List.generate(
    5,
    (index) => Embedding(
      content: '__Message ${index + 1}__: $_dummyText',
      tokensCount: 10,
      created: DateTime.now(),
      updated: DateTime.now(),
    ),
  );

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
}
