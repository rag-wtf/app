import 'package:document/src/ui/views/document_list/document_list_viewmodel.dart';
import 'package:document/src/ui/widgets/document_list/document_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class DocumentListWidget extends StatelessWidget {
  const DocumentListWidget({required this.viewModel, super.key});
  final DocumentListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return InfiniteList(
      itemCount: viewModel.items.length,
      isLoading: viewModel.isBusy,
      onFetchData: viewModel.onFetchData,
      //hasReachedMax: viewModel.hasReachedMax,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return DocumentItemWidget(item);
      },
    );
  }
}
