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
      required this.embeddingsApiBase,
      required this.embeddingsApiKey})
      : super(key: key);

  final String dataIngestionApiUrl;
  final String embeddingsApiBase;
  final String embeddingsApiKey;

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  late UploadFileListViewModel _viewModel;
  static const ns = 'rag';
  static const db = 'test';
  final surreal = Surreal();

  @override
  void initState() {
    super.initState();
    _viewModel = UploadFileListViewModel(UploadFileList(
      dataIngestionApiUrl: widget.dataIngestionApiUrl,
      embeddingsApiBase: widget.embeddingsApiBase,
      embeddingsApiKey: widget.embeddingsApiKey,
      surreal: surreal,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await surreal.connect('indxdb://$ns');
      await surreal.use(ns: ns, db: db);
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
