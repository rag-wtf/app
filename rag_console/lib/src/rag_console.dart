import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:console/console.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class RagConsole extends StatefulWidget {
  const RagConsole({
    required this.endpoint,
    required this.ns,
    required this.db,
    required this.embeddingsApiBase,
    required this.embeddingsApiKey,
    super.key,
  });

  final String endpoint;
  final String ns;
  final String db;
  final String embeddingsApiBase;
  final String embeddingsApiKey;

  @override
  State<RagConsole> createState() => _RagConsoleState();
}

class _RagConsoleState extends State<RagConsole> {
  final db = Surreal();
  final dio = Dio();
  final _gzipEncoder = GZipEncoder();

  Future<void> initFunction() async {
    await db.connect(widget.endpoint);
    await db.use(ns: widget.ns, db: widget.db);
  }

  // gzip request
  List<int> gzipEncoder(String request, RequestOptions options) {
    options.headers.putIfAbsent('Content-Encoding', () => 'gzip');
    return _gzipEncoder.encode(utf8.encode(request))!;
  }

  dynamic getEmbeddingInput(String input) {
    debugPrint('input #$input#');
    try {
      return jsonDecode(input);
    } catch (e) {
      return input;
    }
  }

  Future<Object?> executeFunction(String value) async {
    final regex =
        RegExp(r'^/(\w+)'); // Matches the first word starting with "/"
    final match = regex.firstMatch(value);

    if (match != null) {
      final command = match.group(1);
      debugPrint('command $command');
      switch (command) {
        case 'e':
          final input = value.substring(3);
          final response = await dio.post<Map<String, dynamic>>(
            '${widget.embeddingsApiBase}/embeddings',
            options: Options(
              headers: {
                'Content-type': 'application/json',
                if (widget.embeddingsApiKey.isNotEmpty)
                  'Authorization': 'Bearer ${widget.embeddingsApiKey}',
              },
              requestEncoder: gzipEncoder,
            ),
            data: {
              'input': getEmbeddingInput(input),
            },
          );
          return response.data;

        default:
          throw Exception('Unsupported command: /$command');
      }
    } else {
      throw Exception(
        'All supported commands must be started with /, type /? or /h to see the list of supported commands.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Console(
      content: '''
Connected to ${widget.endpoint}, ns: ${widget.ns}, db: ${widget.db}.
embeddingsApiBase: ${widget.embeddingsApiBase}
''',
      initFunction: initFunction,
      executeFunction: executeFunction,
    );
  }
}
