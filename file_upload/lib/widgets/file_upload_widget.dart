import 'package:flutter/material.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

import '../constants.dart';
import '../model.dart';
import '../viewmodel.dart';
import 'message_panel_widget.dart';
import 'upload_file_zone_widget.dart';
import 'upload_file_list_widget.dart';

class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget(
      {Key? key,
      required this.dataIngestionApiUrl,
      required this.embeddingsApiUrl,
      required this.embeddingsApiKey})
      : super(key: key);

  final String dataIngestionApiUrl;
  final String embeddingsApiUrl;
  final String embeddingsApiKey;

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  late UploadFileListViewModel _viewModel;
  final surreal = Surreal();

  @override
  void initState() {
    super.initState();
    _viewModel = UploadFileListViewModel(UploadFileList(
      dataIngestionApiUrl: widget.dataIngestionApiUrl,
      embeddingsApiUrl: widget.embeddingsApiUrl,
      embeddingsApiKey: widget.embeddingsApiKey,
      surreal: surreal,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      const surrealEndpoint = 'indxdb://rag';
      const surrealNamespace = 'rag';
      const surrealDatabase = 'rag';
      await surreal.connect(surrealEndpoint);
      await surreal.use(ns: surrealNamespace, db: surrealDatabase);
    });
  }

  Future<void> addItem() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _viewModel.addItem();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          body: Column(
            children: [
              const MessagePanelWidget(
                icon: Icon(Icons.info_outline),
                message: maximumFileSize,
              ),
              Expanded(
                child: Stack(
                  children: [
                    UploadFileListWidget(
                      viewModel: _viewModel,
                    ),
                    if (_viewModel.items.isEmpty)
                      UploadFileZoneWidget(
                        icon: const Icon(
                          Icons.upload,
                          size: 128,
                          color: Colors.grey,
                        ),
                        message: uploadFileZoneMessage,
                        onTap: () => addItem(),
                      ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _viewModel.items.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => addItem(),
                  child: const Icon(Icons.upload_file_outlined),
                )
              : null,
        );
      },
    );
  }
}
