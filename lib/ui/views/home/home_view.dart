import 'package:env_reader/env_reader.dart';
import 'package:file_upload/widgets/file_upload_widget.dart';
import 'package:flutter/material.dart';
import 'package:rag/ui/common/app_colors.dart';
import 'package:rag/ui/common/ui_helpers.dart';
import 'package:rag/ui/views/home/home_viewmodel.dart';
import 'package:rag_console/rag_console.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    final dataIngestionApiUrl = Env.read<String>('DATA_INGESTION_API_URL') ??
        'DATA_INGESTION_API_URL undefined';
    final embeddingsApiBase = Env.read<String>('EMBEDDINGS_API_BASE') ??
        'EMBEDDINGS_API_BASE undefined';
    final embeddingsApiKey = Env.read<String>('EMBEDDINGS_API_KEY') ??
        'EMBEDDINGS_API_KEY undefined';
    final generationApiBase = Env.read<String>('GENERATION_API_BASE') ??
        'GENERATION_API_BASE undefined';
    final generationApiKey = Env.read<String>('GENERATION_API_KEY') ??
        'GENERATION_API_KEY undefined';

    debugPrint('generationApiBase $generationApiBase');
    debugPrint('generationApiKey $generationApiKey');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 400,
                  child: FileUploadWidget(
                    dataIngestionApiUrl: dataIngestionApiUrl,
                    embeddingsApiBase: embeddingsApiBase,
                    embeddingsApiKey: embeddingsApiKey,
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 500,
                        child: RagConsole(
                          endpoint: 'indxdb://rag',
                          ns: 'rag',
                          db: 'test',
                          embeddingsApiBase: embeddingsApiBase,
                          embeddingsApiKey: embeddingsApiKey,
                          generationApiBase: generationApiBase,
                          generationApiKey: generationApiKey,
                        ),
                      ),
                    ),
                    verticalSpaceSmall,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MaterialButton(
                          color: Colors.black,
                          onPressed: viewModel.incrementCounter,
                          child: Text(
                            viewModel.counterLabel,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        MaterialButton(
                          color: kcDarkGreyColor,
                          onPressed: viewModel.showDialog,
                          child: const Text(
                            'Show Dialog',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        MaterialButton(
                          color: kcDarkGreyColor,
                          onPressed: viewModel.showBottomSheet,
                          child: const Text(
                            'Show Bottom Sheet',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
}
