import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rag/app/app.locator.dart';
import 'package:rag/ui/common/ui_helpers.dart';
import 'package:rag/app/app.router.dart';
import 'package:rag/ui/widgets/link_tile.dart';
import 'package:settings/settings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:ui/ui.dart';

class MainDrawerWidget extends StatefulWidget {
  const MainDrawerWidget({
    required this.child,
    required this.controller,
    required this.logoutFunction,
    super.key,
  });
  final Widget child;
  final ZoomDrawerController controller;
  final Future<void> Function() logoutFunction;
  @override
  State<MainDrawerWidget> createState() => _MainDrawerWidgetState();
}

class _MainDrawerWidgetState extends State<MainDrawerWidget> {
  final AnalyticsFacade _analyticsFacade = locator<AnalyticsFacade>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;

    var slideWidth = width * 0.3;
    if (width < 600) {
      slideWidth = width * 0.9;
    } else if (width < 840) {
      slideWidth = width * 0.6;
    } else {
      slideWidth = width * 0.3;
    }

    final textAndIconColor = isDarkMode ? Colors.black : Colors.white;
    final listTileTextStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: textAndIconColor,
        );
    const expansionTileChildrenPadding = EdgeInsets.only(left: 16);

    return ZoomDrawer(
      isRtl: true,
      controller: widget.controller,
      openCurve: Curves.fastOutSlowIn,
      slideWidth: slideWidth,
      duration: const Duration(milliseconds: 500),
      menuScreenTapClose: true,
      angle: 0,
      menuBackgroundColor: isDarkMode ? Colors.white : Colors.black,
      mainScreen: widget.child,
      menuScreen: Scaffold(
        backgroundColor: isDarkMode ? Colors.white : Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Logo(
                          darkLogo: darkLogo,
                          lightLogo: lightLogo,
                          size: 32,
                          inverse: true,
                        ),
                        horizontalSpaceSmall,
                        Text(
                          appTitle,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: textAndIconColor,
                                  ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.close,
                        color: textAndIconColor,
                      ),
                    ),
                  ],
                ),
                verticalSpaceSmall,
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.share_outlined,
                          color: textAndIconColor,
                        ),
                        title: Text(
                          'Share',
                          style: listTileTextStyle,
                        ),
                        onTap: () async {
                          final result = await Share.share(
                            'Check out our app at https://',
                            subject: '$appSubTitle: $appTitle',
                          );

                          if (result.status == ShareResultStatus.success) {
                            await showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (BuildContext context) {
                                return const ThankYouDialog();
                              },
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.insights,
                          color: textAndIconColor,
                        ),
                        title: Text(
                          'Evaluation',
                          style: listTileTextStyle,
                        ),
                        onTap: () {
                          locator<NavigationService>()
                              .navigateTo(Routes.evaluationView);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          isDarkMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: textAndIconColor,
                        ),
                        title: Text(
                          '${isDarkMode ? 'Dark' : 'Light'} Mode',
                          style: listTileTextStyle,
                        ),
                        onTap: () async {
                          getThemeManager(context).toggleDarkLightTheme();
                        },
                      ),
                      LinkTile(
                        imagePath: isDarkMode
                            ? 'assets/images/github_light.png'
                            : 'assets/images/github_dark.png',
                        title: 'GitHub',
                        url: Uri.parse(gitHubRepoUrl + defaultUtmParams),
                        textStyle: listTileTextStyle,
                        onUrlLaunched: _analyticsFacade.trackUrlOpened,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: textAndIconColor,
                        ),
                        title: Text(
                          'About Us',
                          style: listTileTextStyle,
                        ),
                        onTap: () async {
                          final aboutBoxChildren = <Widget>[
                            verticalSpaceMedium,
                            Text(
                              appSubTitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ];
                          final packageInfo = await PackageInfo.fromPlatform();
                          showAboutDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            applicationIcon: const Logo(
                              darkLogo: darkLogo,
                              lightLogo: lightLogo,
                              size: 32,
                            ),
                            applicationName: appTitle,
                            applicationVersion: '''
${packageInfo.version} ${packageInfo.buildNumber}''',
                            applicationLegalese:
                                '\u{a9}${DateTime.now().year} Lim Chee Kin',
                            children: aboutBoxChildren,
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.logout_outlined,
                          color: textAndIconColor,
                        ),
                        title: Text(
                          'Logout',
                          style: listTileTextStyle,
                        ),
                        onTap: () async {
                          await widget.controller.close!();
                          await widget.logoutFunction();
                        },
                      ),
                      ExpansionTile(
                        leading: Icon(
                          Icons.workspaces_outline,
                          color: textAndIconColor,
                        ),
                        title: Text(
                          'Related Projects',
                          style: listTileTextStyle,
                        ),
                        childrenPadding: expansionTileChildrenPadding,
                        shape: const Border(),
                        children: [
                          LinkTile(
                            imagePath: 'assets/images/pubdev.png',
                            title: 'surrealdb_js',
                            url: Uri.parse('https://pub.dev/packages/surrealdb_js$defaultUtmParams'),
                            textStyle: listTileTextStyle,
                            onUrlLaunched: _analyticsFacade.trackUrlOpened,
                          ),
                          LinkTile(
                            imagePath: 'assets/images/pubdev.png',
                            title: 'surrealdb_wasm',
                            url: Uri.parse('https://pub.dev/packages/surrealdb_wasm$defaultUtmParams'),
                            textStyle: listTileTextStyle,
                            onUrlLaunched: _analyticsFacade.trackUrlOpened,
                          ),
                          LinkTile(
                            imagePath: 'assets/images/pypi.png',
                            title: 'open-text-embeddings',
                            url: Uri.parse('https://pypi.org/project/open-text-embeddings$defaultUtmParams'),
                            textStyle: listTileTextStyle,
                            onUrlLaunched: _analyticsFacade.trackUrlOpened,
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: Icon(
                          Icons.flash_on_outlined,
                          color: textAndIconColor,
                        ),
                        title: Text(
                          'Powered By',
                          style: listTileTextStyle,
                        ),
                        childrenPadding: expansionTileChildrenPadding,
                        shape: const Border(),
                        children: [
                          LinkTile(
                            imagePath: 'assets/images/flutter.png',
                            title: 'Flutter',
                            url: Uri.parse('https://flutter.dev$defaultUtmParams'),
                            textStyle: listTileTextStyle,
                            onUrlLaunched: _analyticsFacade.trackUrlOpened,
                          ),
                          LinkTile(
                            imagePath: 'assets/images/surrealdb.png',
                            title: 'SurrealDB',
                            url: Uri.parse('https://surrealdb.com$defaultUtmParams'),
                            textStyle: listTileTextStyle,
                            onUrlLaunched: _analyticsFacade.trackUrlOpened,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThankYouDialog extends StatelessWidget {
  const ThankYouDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thank You!'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.thumb_up,
            color: Colors.green,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Thank you for sharing our app!',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
