import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:stacked_package_template/src/ui/views/main/main_viewmodel.dart';

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
      body: Container(
        padding: const EdgeInsets.only(left: 25, right: 25),
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
