// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;

import 'package:flutter/foundation.dart' as _i5;
import 'package:flutter/material.dart' as _i4;
import 'package:flutter/material.dart';
import 'package:settings/src/ui/views/settings/settings_view.dart' as _i3;
import 'package:settings/src/ui/views/startup/startup_view.dart' as _i2;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i7;

class Routes {
  static const startupView = '/startup-view';

  static const settingsView = '/settings-view';

  static const all = <String>{
    startupView,
    settingsView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.startupView,
      page: _i2.StartupView,
    ),
    _i1.RouteDef(
      Routes.settingsView,
      page: _i3.SettingsView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartupView: (data) {
      return _i4.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.StartupView(),
        settings: data,
      );
    },
    _i3.SettingsView: (data) {
      final args = data.getArgs<SettingsViewArguments>(
        orElse: () => const SettingsViewArguments(),
      );
      return _i4.MaterialPageRoute<dynamic>(
        builder: (context) => _i3.SettingsView(
            key: args.key,
            tablePrefix: args.tablePrefix,
            hasConnectDatabase: args.hasConnectDatabase,
            redefineEmbeddingIndexFunction:
                args.redefineEmbeddingIndexFunction),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class SettingsViewArguments {
  const SettingsViewArguments({
    this.key,
    this.tablePrefix = 'main',
    this.hasConnectDatabase = false,
    this.redefineEmbeddingIndexFunction,
  });

  final _i5.Key? key;

  final String tablePrefix;

  final bool hasConnectDatabase;

  final _i6.Future<String?> Function(
    String,
    String,
  )? redefineEmbeddingIndexFunction;

  @override
  String toString() {
    return '{"key": "$key", "tablePrefix": "$tablePrefix", "hasConnectDatabase": "$hasConnectDatabase", "redefineEmbeddingIndexFunction": "$redefineEmbeddingIndexFunction"}';
  }

  @override
  bool operator ==(covariant SettingsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.tablePrefix == tablePrefix &&
        other.hasConnectDatabase == hasConnectDatabase &&
        other.redefineEmbeddingIndexFunction == redefineEmbeddingIndexFunction;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        tablePrefix.hashCode ^
        hasConnectDatabase.hashCode ^
        redefineEmbeddingIndexFunction.hashCode;
  }
}

extension NavigatorStateExtension on _i7.NavigationService {
  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSettingsView({
    _i5.Key? key,
    String tablePrefix = 'main',
    bool hasConnectDatabase = false,
    _i6.Future<String?> Function(
      String,
      String,
    )? redefineEmbeddingIndexFunction,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.settingsView,
        arguments: SettingsViewArguments(
            key: key,
            tablePrefix: tablePrefix,
            hasConnectDatabase: hasConnectDatabase,
            redefineEmbeddingIndexFunction: redefineEmbeddingIndexFunction),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSettingsView({
    _i5.Key? key,
    String tablePrefix = 'main',
    bool hasConnectDatabase = false,
    _i6.Future<String?> Function(
      String,
      String,
    )? redefineEmbeddingIndexFunction,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.settingsView,
        arguments: SettingsViewArguments(
            key: key,
            tablePrefix: tablePrefix,
            hasConnectDatabase: hasConnectDatabase,
            redefineEmbeddingIndexFunction: redefineEmbeddingIndexFunction),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
