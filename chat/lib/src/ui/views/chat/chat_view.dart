// ignore_for_file: depend_on_referenced_packages

import 'package:chat/src/ui/views/chat/chat_viewmodel.dart';
import 'package:chat/src/ui/widgets/message_bar.dart';
import 'package:chat/src/ui/widgets/message_widget.dart';
import 'package:chat/src/ui/widgets/new_chat_panel.dart';
import 'package:document/document.dart';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class ChatView extends StackedView<ChatViewModel> {
  ChatView({
    required this.showDialogFunction,
    this.tablePrefix = 'main',
    this.leftWidgetTabController,
    super.key,
  });
  final String tablePrefix;
  final _scrollController = ScrollController();
  final TabController? leftWidgetTabController;
  final Future<void> Function(Embedding embedding) showDialogFunction;

  @override
  Widget builder(
    BuildContext context,
    ChatViewModel viewModel,
    Widget? child,
  ) {
    return Column(
      children: [
        Flexible(
          child: Align(
            alignment: Alignment.topCenter,
            child: InfiniteList(
              scrollController: _scrollController,
              itemCount: viewModel.messages.length,
              centerEmpty: true,
              emptyBuilder: (context) => NewChatPanel(
                (text) => _onSend(viewModel, text),
              ),
              isLoading: viewModel.isBusy,
              onFetchData: viewModel.fetchMessages,
              reverse: true,
              shrinkWrap: true,
              hasReachedMax: viewModel.hasReachedMax,
              itemBuilder: (context, index) {
                return MessageWidget(
                  viewModel.messages[index],
                  showDialogFunction,
                );
              },
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        MessageBar(
          isSendButtonBusy: viewModel.isGenerating,
          sendButtonColor: Theme.of(context).colorScheme.primary,
          onSend: (text) async => _onSend(viewModel, text),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              padding: const EdgeInsets.all(5),
              onPressed: viewModel.newChat,
              icon: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          messageBarColor: Colors.transparent,
        ),
      ],
    );
  }

  @override
  ChatViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatViewModel(tablePrefix);

  @override
  void onDispose(ChatViewModel viewModel) {
    _scrollController.dispose();
  }

  Future<void> _onSend(ChatViewModel viewModel, String text) async {
    leftWidgetTabController?.animateTo(1);
    _scrollToBottom();
    await viewModel.addMessage(viewModel.userId, text);
  }

  void _scrollToBottom() {
    // Autoscroll to the top after message sent
    // (top is bottom when reverse=True in the infinite list)
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
    );
  }
}
