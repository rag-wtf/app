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
      body: Row(
        children: [
          const Flexible(
            flex: 4,
            child: ChatListView(),
          ),
          Flexible(
            flex: 6,
            child: ChatView(),
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

  @override
  Future<void> onViewModelReady(MainViewModel viewModel) async {
    await viewModel.initialise();
  }
}
