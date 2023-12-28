import 'package:document/src/ui/views/document_list/document_list_viewmodel.dart';
import 'package:document/src/ui/widgets/document_list/document_item_widget.dart';
import 'package:flutter/material.dart';

class DocumentListWidget extends StatelessWidget {
  const DocumentListWidget({required this.viewModel, super.key});
  final DocumentListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: viewModel.items.length,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return DocumentItemWidget(item);
      },
    );
  }
}
