import 'package:chat/src/ui/views/chat/chat_view.dart';
import 'package:chat/src/ui/views/chat_list/chat_list_view.dart';
import 'package:chat/src/ui/views/main/main_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class MainView extends StackedView<MainViewModel> {
  const MainView({super.key, this.tablePrefix = 'main'});
  final String tablePrefix;

  @override
  Widget builder(
    BuildContext context,
    MainViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: viewModel.isBusy
          ? const CircularProgressIndicator()
          : Row(
              children: [
                Flexible(
                  flex: 4,
                  child: ChatListView(viewModel.chatViewModel),
                ),
                Flexible(
                  flex: 6,
                  child: ChatView(viewModel.chatViewModel),
                ),
              ],
            ),
    );
  }

  @override
  MainViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      MainViewModel(tablePrefix);
}
