// ignore_for_file: depend_on_referenced_packages

import 'package:chat/src/ui/views/chat/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:stacked/stacked.dart';

class ChatView extends StackedView<ChatViewModel> {
  const ChatView({super.key, this.tablePrefix = 'main'});
  final String tablePrefix;

  @override
  Widget builder(
    BuildContext context,
    ChatViewModel viewModel,
    Widget? child,
  ) {
    return Chat(
      messages: viewModel.messages.map(
        (message) {
          final json = message.toJson();
          json['author'] = types.User(
            id: message.authorId,
            role: message.authorId.startsWith('user')
                ? types.Role.user
                : types.Role.agent,
          ).toJson();
          return types.Message.fromJson(json);
        },
      ).toList(),
      onAttachmentPressed: _handleAttachmentPressed,
      onMessageTap: _handleMessageTap,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onSendPressed: (partialText) =>
          _handleSendPressed(viewModel, partialText),
      showUserAvatars: true,
      showUserNames: true,
      user: types.User(
        id: viewModel.userId,
      ),
      theme: const DefaultChatTheme(
        seenIcon: Text(
          'read',
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  @override
  bool get disposeViewModel => false;

  @override
  ChatViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatViewModel(tablePrefix);

  void _handleAttachmentPressed() {}

  void _handleMessageTap(BuildContext context, types.Message p1) {}

  void _handlePreviewDataFetched(types.TextMessage p1, types.PreviewData p2) {}

  Future<void> _handleSendPressed(
    ChatViewModel viewModel,
    types.PartialText partialText,
  ) async {
    await viewModel.addMessage(viewModel.userId, partialText.text);
  }
}
