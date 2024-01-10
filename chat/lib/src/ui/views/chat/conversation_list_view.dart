import 'package:chat/src/ui/views/chat/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class ConversationListView extends StackedView<ChatViewModel> {
  const ConversationListView(
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
    //  'view.conversations.length ${viewModel.conversations.length}',
    //);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: InfiniteList(
        itemCount: viewModel.conversations.length,
        isLoading: viewModel.isBusy,
        onFetchData: viewModel.fetchConversations,
        hasReachedMax: viewModel.hasReachedMaxConversation,
        itemBuilder: (context, index) {
          final item = viewModel.conversations[index];
          return ListTile(
            title: Text(item.name),
            key: ValueKey(item.id),
            onTap: () => viewModel.fetchMessages(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => viewModel.addMessage(
          viewModel.userId,
          'conversation ${viewModel.conversations.length}',
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  bool get disposeViewModel => false;

  @override
  bool get initialiseSpecialViewModelsOnce => true;

  @override
  bool get fireOnViewModelReadyOnce => true;

  @override
  ChatViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      chatViewModel;
}
