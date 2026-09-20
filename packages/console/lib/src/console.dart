// Dynamic calls are needed for flexible console execution.
// ignore_for_file: avoid_dynamic_calls

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_console_widget/flutter_console.dart';

class Console extends StatefulWidget {
  const Console({
    required this.content,
    required this.executeFunction,
    this.initFunction,
    super.key,
  });
  final String content;
  final Future<String?> Function()? initFunction;
  final Future<Object?> Function(String value) executeFunction;

  @override
  State<Console> createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  late FlutterConsoleController controller;
  static const commandSymbol = '>';

  Future<dynamic> execute(Function function, String message) async {
    controller.print(
      message: '$commandSymbol $message',
      endline: false,
    );
    dynamic result;
    try {
      result = await function();
      controller.print(
        message: ' ✅',
        endline: true,
      );
      if (result != null) {
        // debugPrint('Console: result $result');
        if (result is Iterable) {
          if (result.isNotEmpty) {
            if (result.first is List) {
              // nested list for multiple statements
              final list = result.reduce((value, element) => value + element);
              if (list.isNotEmpty == true) {
                controller.print(
                  message: result.toString(),
                  endline: true,
                );
              }
            } else {
              controller.print(
                message: result.toString(),
                endline: true,
              );
            }
          }
        } else {
          controller.print(
            message: result.toString(),
            endline: true,
          );
        }
      }
    } on Object catch (error) {
      controller.print(
        message: ' ❎ $error',
        endline: true,
      );
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    controller = FlutterConsoleController(consoleContent: widget.content);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.initFunction != null) {
        final message = await widget.initFunction!();
        if (message != null) {
          controller.print(
            message: message,
            endline: true,
          );
        }
      }
      unawaited(echoLoop());
    });
  }

  Future<void> echoLoop() async {
    while (mounted) {
      final value = await controller.scan();
      if (!mounted) return;
      await execute(
        () => widget.executeFunction(value),
        value,
      );
      if (!mounted) return;
      controller.focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FlutterConsole(
      controller: controller,
      height: size.height,
      width: size.width,
    );
  }
}
