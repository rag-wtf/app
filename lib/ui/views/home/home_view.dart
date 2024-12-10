import 'package:chat/chat.dart';
import 'package:document/document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:rag/ui/common/ui_helpers.dart';
import 'package:rag/ui/views/home/home_viewmodel.dart';
import 'package:rag/ui/widgets/clear_data_widget.dart';
import 'package:rag/ui/widgets/main_drawer_widget.dart';
import 'package:rag_console/rag_console.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:ui/ui.dart';

const largeScreenWidth = 840.0;
const mediumScreenWidth = 600.0;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _leftWidgetTabController;
  final _zoomDrawerController = ZoomDrawerController();

  @override
  void initState() {
    super.initState();
    _leftWidgetTabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _leftWidgetTabController.dispose();
    super.dispose();
  }

  void closeDrawer() {
    if (scaffoldKey.currentState!.isDrawerOpen) {
      scaffoldKey.currentState!.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.totalChats > 0 && _leftWidgetTabController.index == 0) {
            _leftWidgetTabController.animateTo(1);
          } else if (viewModel.totalChats == 0 &&
              _leftWidgetTabController.index == 1) {
            _leftWidgetTabController.animateTo(0);
          }
        });
        
        final appVersionBuildNumber =
            '${viewModel.version} ${viewModel.buildNumber}';
        return MainDrawerWidget(
          controller: _zoomDrawerController,
          logoutFunction: viewModel.disconnect,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Scaffold(
                key: scaffoldKey,
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  title: viewModel.isBusy
                      ? const Logo(
                          darkLogo: darkLogo,
                          lightLogo: lightLogo,
                          size: 32,
                        )
                      : Text(
                          viewModel.appName,
                          overflow: TextOverflow.ellipsis,
                        ),
                  leading: constraints.maxWidth < mediumScreenWidth
                      ? Builder(
                          builder: (context) => IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: Icon(
                              Icons.menu,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        )
                      : null,
                  actions: [
                    if (constraints.maxWidth < largeScreenWidth) ...[
                      horizontalSpaceTiny,
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                          icon: const Icon(Icons.settings),
                        ),
                      ),
                    ],
                    horizontalSpaceTiny,
                    IconButton(
                      icon: const Icon(Icons.more_vert_outlined),
                      onPressed: _zoomDrawerController.toggle,
                    ),
                  ],
                ),
                body: viewModel.isBusy
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SafeArea(
                        child: Column(
                          children: [
                            Flexible(
                              flex: 96,
                              child: BodyWidget(
                                viewModel,
                                constraints.maxWidth,
                                closeDrawer,
                                _leftWidgetTabController,
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: Center(
                                child: Text(
                                  appVersionBuildNumber,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                drawer: constraints.maxWidth < mediumScreenWidth
                    ? Drawer(
                        child: LeftWidget(
                          viewModel,
                          closeDrawer,
                          _leftWidgetTabController,
                        ),
                      )
                    : null,
                endDrawer: constraints.maxWidth < largeScreenWidth
                    ? Drawer(
                        child: RightWidget(
                          viewModel,
                          _leftWidgetTabController,
                        ),
                      )
                    : null,
              );
            },
          ),
        );
      },
      viewModelBuilder: HomeViewModel.new,
      onViewModelReady: (viewModel) => viewModel.initialise(),
    );
  }
}

class BodyWidget extends StatelessWidget {
  const BodyWidget(
    this.viewModel,
    this.maxWidth,
    this.closeDrawerFunction,
    this.leftWidgetTabController, {
    super.key,
  });

  final double maxWidth;
  final HomeViewModel viewModel;
  final void Function()? closeDrawerFunction;
  final TabController leftWidgetTabController;

  @override
  Widget build(BuildContext context) {
    if (maxWidth >= largeScreenWidth) {
      return Row(
        children: [
          Flexible(
            flex: 3,
            child: LeftWidget(
              viewModel,
              closeDrawerFunction,
              leftWidgetTabController,
            ),
          ),
          Flexible(
            flex: 6,
            child: CenterWidget(viewModel, leftWidgetTabController),
          ),
          Flexible(
            flex: 3,
            child: RightWidget(
              viewModel,
              leftWidgetTabController,
            ),
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
              closeDrawerFunction,
              leftWidgetTabController,
            ),
          ),
          Flexible(
            flex: 8,
            child: CenterWidget(viewModel, leftWidgetTabController),
          ),
        ],
      );
    } else {
      return CenterWidget(viewModel, leftWidgetTabController);
    }
  }
}

class RightWidget extends StatelessWidget {
  const RightWidget(
    this.viewModel,
    this.leftWidgetTabController, {
    super.key,
  });
  final HomeViewModel viewModel;
  final TabController leftWidgetTabController;

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
              body: TabBarView(
                children: [
                  SettingsView(
                    redefineEmbeddingIndexFunction:
                        viewModel.redefineEmbeddingIndexFunction,
                    showSystemPromptDialogFunction:
                        viewModel.showSystemPromptDialog,
                    showPromptTemplateDialogFunction:
                        viewModel.showPromptTemplateDialog,
                  ),
                  const RagConsoleView(),
                ],
              ),
            ),
          ),
        ),
        ClearDataWidget(viewModel, leftWidgetTabController),
      ],
    );
  }
}

class CenterWidget extends StatelessWidget {
  const CenterWidget(
    this.viewModel,
    this.leftWidgetTabController, {
    super.key,
  });
  final HomeViewModel viewModel;
  final TabController leftWidgetTabController;

  @override
  Widget build(BuildContext context) {
    return ChatView(
      leftWidgetTabController: leftWidgetTabController,
      showEmbeddingDialogFunction: viewModel.showEmbeddingDialog,
      showNewChatDialogFunction: viewModel.showNewChatDialog,
    );
  }
}

class LeftWidget extends StatelessWidget {
  const LeftWidget(
    this.viewModel,
    this.closeDrawerFunction,
    this.leftWidgetTabController, {
    super.key,
  });

  final HomeViewModel viewModel;
  final void Function()? closeDrawerFunction;
  final TabController leftWidgetTabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: leftWidgetTabController,
          tabs: const [
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
        controller: leftWidgetTabController,
        children: [
          const DocumentListView(),
          ChatListView(closeDrawerFunction: closeDrawerFunction),
        ],
      ),
    );
  }
}
