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
      messages: viewModel.messages
          .map(
            (message) => types.Message.fromJson(
              message.toJson(),
            ),
          )
          .toList(),
      onAttachmentPressed: _handleAttachmentPressed,
      onMessageTap: _handleMessageTap,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onSendPressed: _handleSendPressed,
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
  bool get initialiseSpecialViewModelsOnce => true;

  @override
  ChatViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatViewModel(tablePrefix);

  void _handleAttachmentPressed() {}

  void _handleMessageTap(BuildContext context, types.Message p1) {}

  void _handlePreviewDataFetched(types.TextMessage p1, types.PreviewData p2) {}

  void _handleSendPressed(types.PartialText p1) {}
}
