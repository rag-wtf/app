import 'package:chat/src/ui/views/chat/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class ConversationListView extends StackedView<ChatViewModel> {
  const ConversationListView({super.key, this.tablePrefix = 'main'});
  final String tablePrefix;

  @override
  Widget builder(
    BuildContext context,
    ChatViewModel viewModel,
    Widget? child,
  ) {
    return InfiniteList(
      itemCount: viewModel.items.length,
      isLoading: viewModel.isBusy,
      onFetchData: viewModel.fetchData,
      hasReachedMax: viewModel.hasReachedMax,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return ListTile(
          title: Text(item.name),
          key: ValueKey(item.id),
        );
      },
    );
  }

  @override
  ChatViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatViewModel(tablePrefix);
}
