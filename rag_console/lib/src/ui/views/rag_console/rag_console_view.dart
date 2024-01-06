import 'package:console/console.dart';
import 'package:flutter/material.dart';
import 'package:rag_console/src/ui/views/rag_console/rag_console_viewmodel.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';

class RagConsoleView extends StackedView<RagConsoleViewModel> {
  const RagConsoleView({super.key, this.tablePrefix = 'main'});
  final String tablePrefix;

  @override
  Widget builder(
    BuildContext context,
    RagConsoleViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Console(
        content: '''
Connected to $surrealEndpoint, ns: $surrealNamespace, db: $surrealDatabase.
embeddingsApiUrl: ${viewModel.embeddingsApiUrl}
generationApiUrl: ${viewModel.generationApiUrl}
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
      RagConsoleViewModel(tablePrefix);
}
