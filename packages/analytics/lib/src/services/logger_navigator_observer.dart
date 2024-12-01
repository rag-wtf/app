import 'package:analytics/src/app/app.locator.dart';
import 'package:analytics/src/app/app.logger.dart';
import 'package:analytics/src/services/analytics_facade.dart';
import 'package:flutter/widgets.dart';

class LoggerNavigatorObserver extends NavigatorObserver {
  final AnalyticsFacade _analytics = locator<AnalyticsFacade>();
  final _log = getLogger('LoggerNavigatorObserver');

  static const _name = 'Navigation';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logNavigation(route.settings.name, 'push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logNavigation(route.settings.name, 'pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _logNavigation(newRoute.settings.name, 'replace');
    }
  }

  void _logNavigation(String? routeName, String action) {
    if (routeName != null) {
      _analytics.trackScreenView(routeName, action);
    } else {
      _log.d('$_name: Route name is missing', time: DateTime.now());
    }
  }
}
