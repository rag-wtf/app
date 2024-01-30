import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/ui/views/document_list/document_list_viewmodel.dart';
import 'package:document/src/ui/widgets/document_list/cancel_button_widget.dart';
import 'package:document/src/ui/widgets/document_list/document_item_widgetmodel.dart';
import 'package:document/src/ui/widgets/document_list/document_progress_indicator_widget.dart';
import 'package:document/src/ui/widgets/document_list/document_status_widget.dart';

import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class DocumentItemWidget extends StackedView<DocumentItemWidgetModel> {
  DocumentItemWidget(
    this._parentViewModel,
    this._itemIndex, {
    super.key,
  });
  static int megaBytes = 1024 * 1024;
  final DocumentListViewModel _parentViewModel;
  final int _itemIndex;
  final _log = getLogger('DocumentItemWidget');

  @override
  Widget builder(
    BuildContext context,
    DocumentItemWidgetModel viewModel,
    Widget? child,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.background,
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
            child: Row(
              children: [
                FileIcon(
                  viewModel.item.name,
                  size: 64,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4,
                      ), // Add some spacing between title and subtitle
                      Row(
                        children: [
                          Text(
                            '${(viewModel.item.originFileSize / megaBytes).toStringAsFixed(2)} MB',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: DocumentProgressIndicatorWidget(
                                    viewModel.item.status,
                                    progress: viewModel.progress,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DocumentStatusWidget(item: viewModel.item),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (viewModel.item.status == DocumentStatus.splitting)
            CancelButtonWidget(viewModel.cancel),
        ],
      ),
    );
  }

  @override
  DocumentItemWidgetModel viewModelBuilder(BuildContext context) {
    _log.d(_itemIndex);
    return DocumentItemWidgetModel(_parentViewModel, _itemIndex);
  }

  @override
  Future<void> onViewModelReady(DocumentItemWidgetModel viewModel) async {
    await viewModel.initialise();
  }
}
