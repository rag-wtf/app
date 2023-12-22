import 'package:env_reader/env_reader.dart';
import 'package:file_upload/widgets/file_upload_widget.dart';
import 'package:flutter/material.dart';
import 'package:rag/ui/common/app_colors.dart';
import 'package:rag/ui/common/ui_helpers.dart';
import 'package:rag/ui/views/home/home_viewmodel.dart';
import 'package:rag_console/rag_console.dart';
import 'package:stacked/stacked.dart';

final dataIngestionApiUrl = Env.read<String>('DATA_INGESTION_API_URL') ??
    'DATA_INGESTION_API_URL undefined';
final embeddingsApiBase =
    Env.read<String>('EMBEDDINGS_API_BASE') ?? 'EMBEDDINGS_API_BASE undefined';
final embeddingsApiKey =
    Env.read<String>('EMBEDDINGS_API_KEY') ?? 'EMBEDDINGS_API_KEY undefined';
final generationApiBase =
    Env.read<String>('GENERATION_API_BASE') ?? 'GENERATION_API_BASE undefined';
final generationApiKey =
    Env.read<String>('GENERATION_API_KEY') ?? 'GENERATION_API_KEY undefined';
const largeScreenWidth = 800.0;
const mediumScreenWidth = 600.0;

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('RAG.WTF'),
            leading: constraints.maxWidth < mediumScreenWidth
                ? Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu_open),
                    ),
                  )
                : null,
            actions: [
              if (constraints.maxWidth < largeScreenWidth)
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.settings),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: BodyWidget(constraints.maxWidth),
            ),
          ),
          drawer: constraints.maxWidth < mediumScreenWidth
              ? const Drawer(
                  child: LeftWidget(),
                )
              : null,
          endDrawer: constraints.maxWidth < largeScreenWidth
              ? const Drawer(
                  child: RightWidget(),
                )
              : null,
        );
      },
    );
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
}

class BodyWidget extends StatelessWidget {
  const BodyWidget(
    this.maxWidth, {
    super.key,
  });

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (maxWidth >= largeScreenWidth) {
      return const Row(
        children: [
          Flexible(
            flex: 3,
            child: LeftWidget(),
          ),
          Flexible(
            flex: 4,
            child: CenterWidget(),
          ),
          Flexible(
            flex: 3,
            child: RightWidget(),
          ),
        ],
      );
    } else if (maxWidth >= mediumScreenWidth) {
      return const Row(
        children: [
          Flexible(
            flex: 4,
            child: LeftWidget(),
          ),
          Flexible(
            flex: 6,
            child: CenterWidget(),
          ),
        ],
      );
    } else {
      return const Center(
        child: CenterWidget(),
      );
    }
  }
}

class RightWidget extends StatelessWidget {
  const RightWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RagConsole(
      endpoint: 'indxdb://rag',
      ns: 'rag',
      db: 'test',
      embeddingsApiBase: embeddingsApiBase,
      embeddingsApiKey: embeddingsApiKey,
      generationApiBase: generationApiBase,
      generationApiKey: generationApiKey,
    );
  }
}

class CenterWidget extends StatelessWidget {
  const CenterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.green);
  }
}

class LeftWidget extends StatelessWidget {
  const LeftWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FileUploadWidget(
      dataIngestionApiUrl: dataIngestionApiUrl,
      embeddingsApiBase: embeddingsApiBase,
      embeddingsApiKey: embeddingsApiKey,
    );
  }
}
