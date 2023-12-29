import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'document_detail_viewmodel.dart';

class DocumentDetailView extends StackedView<DocumentDetailViewModel> {
  const DocumentDetailView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DocumentDetailViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      ),
    );
  }

  @override
  DocumentDetailViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DocumentDetailViewModel();
}
