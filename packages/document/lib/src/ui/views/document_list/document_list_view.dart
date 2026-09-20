import 'dart:io';

import 'package:document/src/constants.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/ui/views/document_list/document_list_viewmodel.dart';
import 'package:document/src/ui/widgets/document_list/document_list_widget.dart';
import 'package:document/src/ui/widgets/document_list/document_upload_zone_widget.dart';
import 'package:document/src/ui/widgets/document_list/message_panel_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mime_type/mime_type.dart' as mime_type;
import 'package:stacked/stacked.dart';

class DocumentListView extends StackedView<DocumentListViewModel> {
  const DocumentListView({
    super.key,
    this.tablePrefix = 'main',
    this.inPackage = false,
  });
  final String tablePrefix;
  final bool inPackage;

  @override
  Widget builder(
    BuildContext context,
    DocumentListViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Column(
        children: [
          if (!viewModel.isBusy && viewModel.splitConfig != null)
            MessagePanelWidget(
              icon: const Icon(Icons.info_outline),
              message: maximumFileSizeMessage.replaceFirst(
                '{}',
                viewModel.splitConfig!.maxFileSizeInMb.toString(),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                DocumentListWidget(viewModel: viewModel),
                if (viewModel.items.isEmpty)
                  DocumentUploadZoneWidget(
                    icon: const Icon(
                      Icons.file_upload_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    message: uploadFileZoneMessage,
                    onTap: () async {
                      final file = await pickFile(viewModel);
                      await viewModel.addItem(file);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: viewModel.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                final file = await pickFile(viewModel);
                await viewModel.addItem(file);
              },
              backgroundColor: Theme.of(context).cardColor,
              child: const Icon(Icons.file_upload_outlined),
            )
          : null,
    );
  }

  @override
  DocumentListViewModel viewModelBuilder(BuildContext context) =>
      DocumentListViewModel(tablePrefix, inPackage: inPackage);

  @override
  Future<void> onViewModelReady(DocumentListViewModel viewModel) async {
    await viewModel.initialise();
  }

  Future<Document?> pickFile(DocumentListViewModel viewModel) async {
    final allowedExtensions = viewModel.splitConfig != null
        ? viewModel.splitConfig!.supportedFileTypes
              .map((mimeType) => extensionFromMime(mimeType) ?? 'null')
              .toList()
        : defaultAllowedExtensions.split(',');
    debugPrint('''
supportedFileTypes ${viewModel.splitConfig?.supportedFileTypes}
allowedExtensions $allowedExtensions
''');
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (file == null) {
      return null;
    }

    String? mimeType;
    var fileName = unknownFileName;
    if (kIsWeb) {
      fileName = file.name;
      mimeType = lookupMimeType(fileName);
    } else {
      final filePath = file.path;
      if (filePath != null) {
        mimeType = lookupMimeType(filePath);
        fileName = filePath.split(Platform.pathSeparator).last;
      } else {
        fileName = file.name;
        mimeType = lookupMimeType(fileName);
      }
    }

    mimeType ??= mime_type.mime(fileName);
    debugPrint('fileName $fileName, mimeType $mimeType');

    final contentType = mimeType != null ? MediaType.parse(mimeType) : null;

    final fileReadStream = file.readAsByteStream();
    // Buffer the stream so that it can be process multiple times
    final fileData = await fileReadStream.toList();
    final fileSize = file.lengthSync() ?? (await file.length()) ?? 0;
    return Document(
      compressedFileSize: 0,
      fileMimeType: contentType!.mimeType,
      name: fileName,
      originFileSize: fileSize,
      status: DocumentStatus.created,
      byteData: fileData,
    );
  }
}
