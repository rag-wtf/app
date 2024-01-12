import 'package:chat/src/ui/views/chat/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class ChatListView extends StackedView<ChatViewModel> {
  const ChatListView(
    this.chatViewModel, {
    super.key,
    this.tablePrefix = 'main',
  });
  final String tablePrefix;
  final ChatViewModel chatViewModel;

  @override
  Widget builder(
    BuildContext context,
    ChatViewModel viewModel,
    Widget? child,
  ) {
    //debugPrint(
    //  'view.chats.length ${viewModel.chats.length}',
    //);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: InfiniteList(
        itemCount: viewModel.chats.length,
        isLoading: viewModel.isBusy,
        onFetchData: viewModel.fetchChats,
        hasReachedMax: viewModel.hasReachedMaxChat,
        itemBuilder: (context, index) {
          final item = viewModel.chats[index];
          return ListTile(
            title: Text(item.name, overflow: TextOverflow.ellipsis),
            key: ValueKey(item.id),
            onTap: () => viewModel.fetchMessages(index),
          );
        },
      ),
    );
  }

  @override
  bool get disposeViewModel => false;

  @override
  ChatViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      chatViewModel;
}
