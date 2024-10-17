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
import 'package:mime_type/mime_type.dart';
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
                      Icons.file_upload_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    message: uploadFileZoneMessage,
                    onTap: () async => viewModel.addItem(await pickFile()),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: viewModel.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async => viewModel.addItem(await pickFile()),
              backgroundColor: Theme.of(context).cardColor,
              child: const Icon(Icons.file_upload_outlined),
            )
          : null,
    );
  }

  @override
  DocumentListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DocumentListViewModel(
        tablePrefix,
        inPackage: inPackage,
      );

  @override
  Future<void> onViewModelReady(DocumentListViewModel viewModel) async {
    await viewModel.initialise();
  }

  Future<Document?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions.split(','),
      //allowMultiple: false,
      //withData: false,
      withReadStream: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    String? mimeType;
    var fileName = unknownFileName;
    if (kIsWeb) {
      // REF: https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ#q-how-do-i-access-the-path-on-web
      final fileBytes =
          file.bytes; // Even withData: true, always null in web platform
      fileName = file.name;
      mimeType = lookupMimeType(fileName, headerBytes: fileBytes);
    } else {
      final filePath = file.path;
      if (filePath != null) {
        mimeType = lookupMimeType(filePath);
        fileName = filePath.split(Platform.pathSeparator).last;
      }
    }

    mimeType ??= mime(fileName);
    debugPrint('fileName $fileName, mimeType $mimeType');

    final contentType = mimeType != null ? MediaType.parse(mimeType) : null;

    // REF: https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ#q-how-do-do-i-use-withreadstream
    final fileReadStream = file.readStream;
    if (fileReadStream == null) {
      throw Exception(fileStreamExceptionMessage);
    }

    // Buffer the stream so that it can be process multiple times
    final fileData = await fileReadStream.toList();
    return Document(
      compressedFileSize: 0,
      fileMimeType: contentType!.mimeType,
      name: fileName,
      originFileSize: file.size,
      status: DocumentStatus.created,
      byteData: fileData,
    );
  }
}
