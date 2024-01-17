import 'package:document/src/ui/views/document_detail/document_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class DocumentDetailView extends StackedView<DocumentDetailViewModel> {
  const DocumentDetailView({super.key});

  @override
  Widget builder(
    BuildContext context,
    DocumentDetailViewModel viewModel,
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
  DocumentDetailViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DocumentDetailViewModel();
}
