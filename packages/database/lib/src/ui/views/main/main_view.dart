import 'package:database/src/ui/views/main/main_viewmodel.dart';
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
      body: Container(
        padding: const EdgeInsets.only(left: 25, right: 25),
      ),
      appBar: AppBar(
        title: const Text('Database'),
        actions: [
          IconButton(
            onPressed: viewModel.disconnect,
            icon: const Icon(Icons.exit_to_app),
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
