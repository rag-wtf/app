// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:flutter/foundation.dart' as _i6;
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
      final args = data.getArgs<SettingsViewArguments>(nullOk: false);
      return _i4.MaterialPageRoute<dynamic>(
        builder: (context) => _i3.SettingsView(
            showSystemPromptDialogFunction: args.showSystemPromptDialogFunction,
            showPromptTemplateDialogFunction:
                args.showPromptTemplateDialogFunction,
            key: args.key,
            tablePrefix: args.tablePrefix,
            inPackage: args.inPackage,
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
    required this.showSystemPromptDialogFunction,
    required this.showPromptTemplateDialogFunction,
    this.key,
    this.tablePrefix = 'main',
    this.inPackage = false,
    this.redefineEmbeddingIndexFunction,
  });

  final _i5.Future<void> Function() showSystemPromptDialogFunction;

  final _i5.Future<void> Function() showPromptTemplateDialogFunction;

  final _i6.Key? key;

  final String tablePrefix;

  final bool inPackage;

  final _i5.Future<String?> Function(
    String,
    String,
  )? redefineEmbeddingIndexFunction;

  @override
  String toString() {
    return '{"showSystemPromptDialogFunction": "$showSystemPromptDialogFunction", "showPromptTemplateDialogFunction": "$showPromptTemplateDialogFunction", "key": "$key", "tablePrefix": "$tablePrefix", "inPackage": "$inPackage", "redefineEmbeddingIndexFunction": "$redefineEmbeddingIndexFunction"}';
  }

  @override
  bool operator ==(covariant SettingsViewArguments other) {
    if (identical(this, other)) return true;
    return other.showSystemPromptDialogFunction ==
            showSystemPromptDialogFunction &&
        other.showPromptTemplateDialogFunction ==
            showPromptTemplateDialogFunction &&
        other.key == key &&
        other.tablePrefix == tablePrefix &&
        other.inPackage == inPackage &&
        other.redefineEmbeddingIndexFunction == redefineEmbeddingIndexFunction;
  }

  @override
  int get hashCode {
    return showSystemPromptDialogFunction.hashCode ^
        showPromptTemplateDialogFunction.hashCode ^
        key.hashCode ^
        tablePrefix.hashCode ^
        inPackage.hashCode ^
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
    required _i5.Future<void> Function() showSystemPromptDialogFunction,
    required _i5.Future<void> Function() showPromptTemplateDialogFunction,
    _i6.Key? key,
    String tablePrefix = 'main',
    bool inPackage = false,
    _i5.Future<String?> Function(
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
            showSystemPromptDialogFunction: showSystemPromptDialogFunction,
            showPromptTemplateDialogFunction: showPromptTemplateDialogFunction,
            key: key,
            tablePrefix: tablePrefix,
            inPackage: inPackage,
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
    required _i5.Future<void> Function() showSystemPromptDialogFunction,
    required _i5.Future<void> Function() showPromptTemplateDialogFunction,
    _i6.Key? key,
    String tablePrefix = 'main',
    bool inPackage = false,
    _i5.Future<String?> Function(
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
            showSystemPromptDialogFunction: showSystemPromptDialogFunction,
            showPromptTemplateDialogFunction: showPromptTemplateDialogFunction,
            key: key,
            tablePrefix: tablePrefix,
            inPackage: inPackage,
            redefineEmbeddingIndexFunction: redefineEmbeddingIndexFunction),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
