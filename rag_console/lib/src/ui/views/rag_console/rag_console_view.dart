import 'package:console/console.dart';
import 'package:flutter/material.dart';
import 'package:rag_console/src/ui/views/rag_console/rag_console_viewmodel.dart';
import 'package:stacked/stacked.dart';

class RagConsoleView extends StackedView<RagConsoleViewModel> {
  const RagConsoleView({
    super.key,
    this.tablePrefix = 'main',
    this.inPackage = false,
  });
  final String tablePrefix;
  final bool inPackage;

  @override
  String get title => 'RAG Console';

  @override
  Widget builder(
    BuildContext context,
    RagConsoleViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: viewModel.isBusy
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Console(
              content: '''
Connected to ${viewModel.surrealEndpoint}, ns: ${viewModel.surrealNamespace}, db: ${viewModel.surrealDatabase}
${viewModel.surrealVersion}.

${RagConsoleViewModel.helpMessageHint}
''',
              executeFunction: viewModel.execute,
            ),
    );
  }

  @override
  RagConsoleViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      RagConsoleViewModel(tablePrefix, inPackage: inPackage);

  @override
  Future<void> onViewModelReady(RagConsoleViewModel viewModel) async {
    await viewModel.initialise();
  }
}
