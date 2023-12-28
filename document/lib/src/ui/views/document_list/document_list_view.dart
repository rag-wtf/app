import 'package:document/src/constants.dart';
import 'package:document/src/ui/views/document_list/document_list_viewmodel.dart';
import 'package:document/src/ui/widgets/document_list/document_list_widget.dart';
import 'package:document/src/ui/widgets/document_list/document_upload_zone_widget.dart';
import 'package:document/src/ui/widgets/document_list/message_panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class DocumentListView extends StackedView<DocumentListViewModel> {
  const DocumentListView(this.tablePrefix, {super.key});
  final String tablePrefix;

  @override
  Widget builder(
    BuildContext context,
    DocumentListViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const MessagePanelWidget(
            icon: Icon(Icons.info_outline),
            message: maximumFileSizeMessage,
          ),
          Expanded(
            child: Stack(
              children: [
                DocumentListWidget(
                  viewModel: viewModel,
                ),
                if (viewModel.items.isEmpty)
                  DocumentUploadZoneWidget(
                    icon: const Icon(
                      Icons.upload,
                      size: 128,
                      color: Colors.grey,
                    ),
                    message: uploadFileZoneMessage,
                    onTap: viewModel.addItem,
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: viewModel.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: viewModel.addItem,
              child: const Icon(Icons.upload_file_outlined),
            )
          : null,
    );
  }

  @override
  DocumentListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DocumentListViewModel(tablePrefix);
}
