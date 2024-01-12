import 'package:chat/src/ui/views/chat_list/chat_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class ChatListView extends StackedView<ChatListViewModel> {
  const ChatListView({
    super.key,
    this.tablePrefix = 'main',
  });
  final String tablePrefix;

  @override
  Widget builder(
    BuildContext context,
    ChatListViewModel viewModel,
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
  ChatListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatListViewModel(tablePrefix);

  @override
  Future<void> onViewModelReady(ChatListViewModel viewModel) async {
    await viewModel.fetchChats();
  }
}
