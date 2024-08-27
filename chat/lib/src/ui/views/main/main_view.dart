import 'package:chat/src/ui/views/chat/chat_view.dart';
import 'package:chat/src/ui/views/chat_list/chat_list_view.dart';
import 'package:chat/src/ui/views/main/main_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class MainView extends StackedView<MainViewModel> {
  const MainView({
    super.key,
    this.tablePrefix = 'main',
    this.inPackage = false,
  });
  final String tablePrefix;
  final bool inPackage;

  @override
  Widget builder(
    BuildContext context,
    MainViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Row(
        children: [
          const Flexible(
            flex: 4,
            child: ChatListView(),
          ),
          Flexible(
            flex: 6,
            child: ChatView(showDialogFunction: viewModel.showEmbeddingDialog),
          ),
        ],
      ),
    );
  }

  @override
  MainViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      MainViewModel(tablePrefix, inPackage: inPackage);

  @override
  Future<void> onViewModelReady(MainViewModel viewModel) async {
    await viewModel.initialise();
  }
}
