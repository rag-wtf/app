// ignore_for_file: depend_on_referenced_packages

import 'package:chat/src/ui/views/chat/chat_viewmodel.dart';
import 'package:chat/src/ui/widgets/horizontal_list.dart';
import 'package:chat/src/ui/widgets/message_bar.dart';
import 'package:chat/src/ui/widgets/message_widget.dart';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class ChatView extends StackedView<ChatViewModel> {
  ChatView({super.key, this.tablePrefix = 'main'});
  final String tablePrefix;
  final _scrollController = ScrollController();

  @override
  Widget builder(
    BuildContext context,
    ChatViewModel viewModel,
    Widget? child,
  ) {
    return Column(
      children: [
        //HorizontalList(viewModel.embeddings),
        Flexible(
          child: InfiniteList(
            scrollController: _scrollController,
            itemCount: viewModel.messages.length,
            isLoading: viewModel.isBusy,
            onFetchData: viewModel.fetchMessages,
            reverse: true,
            hasReachedMax: viewModel.hasReachedMax,
            itemBuilder: (context, index) {
              return MessageWidget(viewModel.messages[index]);
            },
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        MessageBar(
          sendButtonEnabled: !viewModel.isGenerating,
          onSend: (text) => _onSend(viewModel, text),
          actions: [
            InkWell(
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 24,
              ),
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: InkWell(
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.green,
                  size: 24,
                ),
                onTap: () {},
              ),
            ),
          ],
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
