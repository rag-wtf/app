import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:console/console.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
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
  late DocumentService documentService;
  static const helpMessageHint =
      'Type /h to see the list of supported commands.';
  static const helpMessage = '''
/e <input>
Create embeddings for the given <input>.
Example: 
/e this is single input value
/e ["this is", "multiple input", "values"]  

/r <question>
Retrieve contents relevant to the question.
Example: 
/r How to breath properly?
/r What is meditation?  

/sql <query>
Execute <query> statement of SurrealQL.
Example:
/sql INFO FOR DB; 
/sql SELECT * FROM DocumentEmbedding;
''';

  Future<void> initFunction() async {
    await db.connect(widget.endpoint);
    await db.use(ns: widget.ns, db: widget.db);
    documentService = DocumentService(db: db);
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

  Future<Map<String, dynamic>?> embed(String input) async {
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
  }

  Future<List<Map<String, dynamic>>> retrieve(String input) async {
    final responseData = await embed(input);
    final embedding = (responseData?['data'] as List).first as Map;
    final queryVector = List<double>.from(embedding['embedding'] as List);
    final embeddings = await documentService.similaritySearch(queryVector, 3);
    return embeddings.map((e) => e.toJson()).toList();
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
          return embed(input);
        case 'r':
          final input = value.substring(3);
          return retrieve(input);
        case 'sql':
          final query = value.substring(5);
          return db.query(query);
        case 'h':
          return helpMessage;
        default:
          throw Exception('Unsupported command: /$command. $helpMessageHint');
      }
    } else {
      throw Exception(helpMessageHint);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Console(
      content: '''
Connected to ${widget.endpoint}, ns: ${widget.ns}, db: ${widget.db}.
embeddingsApiBase: ${widget.embeddingsApiBase}
$helpMessageHint
''',
      initFunction: initFunction,
      executeFunction: executeFunction,
    );
  }
}
