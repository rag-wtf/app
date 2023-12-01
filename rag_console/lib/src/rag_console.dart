import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:console/console.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:flutter/widgets.dart';
import 'package:rag_console/src/chat_message.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class RagConsole extends StatefulWidget {
  const RagConsole({
    required this.endpoint,
    required this.ns,
    required this.db,
    required this.embeddingsApiBase,
    required this.embeddingsApiKey,
    required this.generationApiBase,
    required this.generationApiKey,
    this.systemMessage =
        'You are a very helpful and friendly assistant that will follow user instructions closely.',
    this.promptTemplate = '''
Answer the question based on the following information:
{context}
If the available information is insufficient or inadequate,
just tell the user you don't know the answer.

Question: {question}

Answer: ''',
    super.key,
  });

  final String endpoint;
  final String ns;
  final String db;
  final String embeddingsApiBase;
  final String embeddingsApiKey;
  final String generationApiBase;
  final String generationApiKey;
  final String systemMessage;
  final String promptTemplate;

  @override
  State<RagConsole> createState() => _RagConsoleState();
}

class _RagConsoleState extends State<RagConsole> {
  final db = Surreal();
  final dio = Dio();
  final _gzipEncoder = GZipEncoder();
  final messages = <ChatMessage>[];
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

/g <question>
Generate response to the question.
Example: 
/g What is your name?
/g Tell me more about LLM. 

/c
Clear chat messages stored in the memory

/rag <question>
Generate response based on information retrieved from the question.
Example: 
/rag What is fine-tuning?
/rag List all advanced RAG techniques. 


/sql <query>
Execute <query> statement of SurrealQL.
Example:
/sql INFO FOR DB; 
/sql SELECT * FROM DocumentEmbedding;
''';

  void initMessages([String? systemMessage]) {
    messages
      ..clear()
      ..add(
        ChatMessage(
          role: Role.system,
          content: systemMessage ?? widget.systemMessage,
          dateTime: DateTime.now(),
        ),
      );
  }

  Future<void> initFunction() async {
    await db.connect(widget.endpoint);
    await db.use(ns: widget.ns, db: widget.db);
    documentService = DocumentService(db: db);
    initMessages();
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

  Future<String> generate(String prompt, [String? input]) async {
    messages.add(
      ChatMessage(
        role: Role.user,
        content: prompt,
        dateTime: DateTime.now(),
      ),
    );
    final messagesMap = messages.map((message) => message.toJson()).toList();
    debugPrint(messagesMap.toString());
    final response = await dio.post<Map<String, dynamic>>(
      '${widget.generationApiBase}/chat/completions',
      options: Options(
        headers: {
          'Content-type': 'application/json',
          if (widget.generationApiKey.isNotEmpty)
            'Authorization': 'Bearer ${widget.generationApiKey}',
        },
      ),
      data: {
        'messages': messagesMap,
      },
    );
    final responseData = response.data;
    final choice = Map<String, dynamic>.from(
      (responseData?['choices'] as List).first as Map,
    );
    final message = Map<String, dynamic>.from(
      choice['message'] as Map,
    );
    final content = (message['content'] as String).trimLeft();

    if (input != null) {
      final chatMessage = messages.removeLast();
      messages.add(
        ChatMessage(
          role: Role.user,
          content: input,
          dateTime: chatMessage.dateTime,
        ),
      );
    }
    messages.add(
      ChatMessage(
        role: Role.assistant,
        content: content,
        dateTime: DateTime.now(),
      ),
    );
    return content;
  }

  Future<List<Embedding>> retrieve(String input) async {
    final responseData = await embed(input);
    final embedding = (responseData?['data'] as List).first as Map;
    final queryVector = List<double>.from(embedding['embedding'] as List);
    final embeddings = await documentService.similaritySearch(queryVector, 3);
    return embeddings;
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
          final embeddings = await retrieve(input);
          return embeddings.map((e) => e.toJson()).toList();
        case 'g':
          final input = value.substring(3);
          return generate(input);
        case 'c':
          initMessages();
          return 'Chat messages is cleared from the memory.';
        case 'rag':
          final input = value.substring(5);
          final embeddings = await retrieve(input);
          final context = embeddings.map((e) {
            return '${e.content} ${e.score} ${e.id}';
          }).join('\n');
          final prompt = widget.promptTemplate
              .replaceFirst('{context}', context)
              .replaceFirst('{question}', input);
          return generate(prompt, input);
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
embeddingsApiBaseUrl: ${widget.embeddingsApiBase}
generationApiBaseUrl: ${widget.generationApiBase}
$helpMessageHint
''',
      initFunction: initFunction,
      executeFunction: executeFunction,
    );
  }
}
