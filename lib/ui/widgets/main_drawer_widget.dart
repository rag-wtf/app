import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rag/ui/common/ui_helpers.dart';
import 'package:settings/settings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:url_launcher/url_launcher.dart';

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
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;

    var slideWidth = width * 0.3;
    if (width < 600) {
      slideWidth = width * 0.7;
    } else if (width < 840) {
      slideWidth = width * 0.5;
    } else {
      slideWidth = width * 0.3;
    }

    final textAndIconColor = isDarkMode ? Colors.black : Colors.white;
    final listTileTextStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: textAndIconColor,
        );
        
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const FlutterLogo(
                            size: 32,
                          ),
                          horizontalSpaceSmall,
                          Text(
                            appTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: textAndIconColor,
                                ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.close,
                        color: textAndIconColor,
                      ),
                    ],
                  ),
                ),
                verticalSpaceMedium,
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
                ListTile(
                  leading: Icon(
                    Icons.source_outlined,
                    color: textAndIconColor,
                  ),
                  title: Text(
                    'GitHub',
                    style: listTileTextStyle,
                  ),
                  onTap: () async {
                    final url = Uri.parse(gitHubRepoUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
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
                      applicationIcon: const FlutterLogo(),
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
                  } ,
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
