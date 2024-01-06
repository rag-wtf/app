import 'package:document/document.dart';
import 'package:flutter/material.dart';
import 'package:rag/ui/views/home/home_viewmodel.dart';
import 'package:rag/ui/widgets/common/brightness_button.dart';
import 'package:rag_console/rag_console.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';

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
            title: const Text(appTitle),
            leading: constraints.maxWidth < mediumScreenWidth
                ? Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu_open),
                    ),
                  )
                : null,
            actions: [
              const BrightnessButton(
                showTooltipBelow: false,
              ),
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
              child: BodyWidget(viewModel, constraints.maxWidth),
            ),
          ),
          drawer: constraints.maxWidth < mediumScreenWidth
              ? Drawer(
                  child: LeftWidget(viewModel),
                )
              : null,
          endDrawer: constraints.maxWidth < largeScreenWidth
              ? Drawer(
                  child: RightWidget(viewModel),
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
    this.viewModel,
    this.maxWidth, {
    super.key,
  });

  final double maxWidth;
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (maxWidth >= largeScreenWidth) {
      return Row(
        children: [
          Flexible(
            flex: 3,
            child: LeftWidget(viewModel),
          ),
          Flexible(
            flex: 4,
            child: CenterWidget(viewModel),
          ),
          Flexible(
            flex: 3,
            child: RightWidget(viewModel),
          ),
        ],
      );
    } else if (maxWidth >= mediumScreenWidth) {
      return Row(
        children: [
          Flexible(
            flex: 4,
            child: LeftWidget(viewModel),
          ),
          Flexible(
            flex: 6,
            child: CenterWidget(viewModel),
          ),
        ],
      );
    } else {
      return Center(
        child: CenterWidget(viewModel),
      );
    }
  }
}

class RightWidget extends StatelessWidget {
  const RightWidget(
    this.viewModel, {
    super.key,
  });
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(
                text: 'Settings',
              ),
              Tab(
                text: 'Console',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const SettingsView(),
            RagConsole(
              endpoint: surrealEndpoint,
              ns: surrealNamespace,
              db: surrealDatabase,
              embeddingsApiUrl: viewModel.getSettingValue(embeddingsApiUrlKey),
              embeddingsApiKey: viewModel.getSettingValue(embeddingsApiKey),
              generationApiUrl: viewModel.getSettingValue(generationApiUrlKey),
              generationApiKey: viewModel.getSettingValue(generationApiKey),
            ),
          ],
        ),
      ),
    );
  }
}

class CenterWidget extends StatelessWidget {
  const CenterWidget(
    this.viewModel, {
    super.key,
  });
  final HomeViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.green);
  }
}

class LeftWidget extends StatelessWidget {
  const LeftWidget(
    this.viewModel, {
    super.key,
  });
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return const DocumentListView();
  }
}
