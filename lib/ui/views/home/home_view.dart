import 'package:chat/chat.dart';
import 'package:document/document.dart';
import 'package:flutter/material.dart';
import 'package:rag/ui/views/home/home_viewmodel.dart';
import 'package:rag/ui/widgets/common/brightness_button.dart';
import 'package:rag_console/rag_console.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';

const largeScreenWidth = 800.0;
const mediumScreenWidth = 600.0;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void closeDrawer() {
    if (scaffoldKey.currentState!.isDrawerOpen) {
      scaffoldKey.currentState!.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      builder: (context, viewModel, child) => LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            key: scaffoldKey,
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
              child: BodyWidget(
                viewModel,
                constraints.maxWidth,
                closeDrawerFunction: closeDrawer,
              ),
            ),
            drawer: constraints.maxWidth < mediumScreenWidth
                ? Drawer(
                    child: LeftWidget(
                      viewModel,
                      closeDrawerFunction: closeDrawer,
                    ),
                  )
                : null,
            endDrawer: constraints.maxWidth < largeScreenWidth
                ? Drawer(
                    child: RightWidget(viewModel),
                  )
                : null,
          );
        },
      ),
      viewModelBuilder: HomeViewModel.new,
    );
  }
}

class BodyWidget extends StatelessWidget {
  const BodyWidget(
    this.viewModel,
    this.maxWidth, {
    super.key,
    this.closeDrawerFunction,
  });

  final double maxWidth;
  final HomeViewModel viewModel;
  final void Function()? closeDrawerFunction;

  @override
  Widget build(BuildContext context) {
    if (maxWidth >= largeScreenWidth) {
      return Row(
        children: [
          Flexible(
            flex: 3,
            child: LeftWidget(
              viewModel,
              closeDrawerFunction: closeDrawerFunction,
            ),
          ),
          Flexible(
            flex: 6,
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
            child: LeftWidget(
              viewModel,
              closeDrawerFunction: closeDrawerFunction,
            ),
          ),
          Flexible(
            flex: 8,
            child: CenterWidget(viewModel),
          ),
        ],
      );
    } else {
      return CenterWidget(viewModel);
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
    return Column(
      children: [
        Expanded(
          child: DefaultTabController(
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
              body: const TabBarView(
                children: [
                  SettingsView(),
                  RagConsoleView(),
                ],
              ),
            ),
          ),
        ),
        ExpansionTile(
          title: Text(
            'Reset Data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          childrenPadding: const EdgeInsets.all(24),
          children: [
            const Center(child: Text('Permanently delete all data?')),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: viewModel.isSettingsDataExcludedFromDeletion,
                  onChanged: (value) =>
                      viewModel.isSettingsDataExcludedFromDeletion = value!,
                ),
                const Text('Excludes settings data'),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: viewModel.deleteAllData,
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Delete'),
            ),
          ],
        ),
      ],
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
    return ChatView();
  }
}

class LeftWidget extends StatelessWidget {
  const LeftWidget(
    this.viewModel, {
    super.key,
    this.closeDrawerFunction,
  });

  final HomeViewModel viewModel;
  final void Function()? closeDrawerFunction;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(
                text: 'Documents',
              ),
              Tab(
                text: 'Chats',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const DocumentListView(),
            ChatListView(closeDrawerFunction: closeDrawerFunction),
          ],
        ),
      ),
    );
  }
}
