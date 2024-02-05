import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:chat/chat.dart';
// ignore: implementation_imports
import 'package:chat/src/services/chat_api_message.dart' as chat_api;
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:rag_console/src/app/app.locator.dart';
import 'package:rag_console/src/app/app.logger.dart';

import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class RagConsoleViewModel extends BaseViewModel {
  RagConsoleViewModel(this.tablePrefix);
  final String tablePrefix;
  final _settingService = locator<SettingService>();
  final _db = locator<Surreal>();
  final _dio = locator<Dio>();
  final _gzipEncoder = locator<GZipEncoder>();
  final _messages = <chat_api.ChatApiMessage>[];
  final _documentService = locator<DocumentService>();
  final _chatService = locator<ChatService>();
  final _log = getLogger('RagConsoleViewModel');
  late String _surrealVersion;
  String get embeddingsApiUrl => _settingService.get(embeddingsApiUrlKey).value;
  String get generationApiUrl => _settingService.get(generationApiUrlKey).value;
  String get surrealVersion => _surrealVersion;

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

  void _initMessages() {
    final systemPrompt = _settingService.get(systemPromptKey).value;
    _messages
      ..clear()
      ..add(
        chat_api.ChatApiMessage(
          role: chat_api.Role.system,
          content: systemPrompt,
          dateTime: DateTime.now(),
        ),
      );
  }

  // gzip request
  List<int> gzipEncoder(String request, RequestOptions options) {
    options.headers.putIfAbsent('Content-Encoding', () => 'gzip');
    return _gzipEncoder.encode(utf8.encode(request))!;
  }

  Future<void> initialise() async {
    _log.d('initialise() tablePrefix: $tablePrefix');
    await _settingService.initialise(tablePrefix);
    await _documentService.initialise(tablePrefix);
    await _chatService.initialise(tablePrefix);
    _initMessages();
  }

  dynamic getEmbeddingInput(String input) {
    _log.d('input #$input#');
    try {
      return jsonDecode(input);
    } catch (e) {
      return input;
    }
  }

  Future<Map<String, dynamic>?> embed(String input) async {
    final embeddingsApiKeyValue = _settingService.get(embeddingsApiKey).value;
    final response = await _dio.post<Map<String, dynamic>>(
      embeddingsApiUrl,
      options: Options(
        headers: {
          'Content-type': 'application/json',
          if (embeddingsApiKeyValue.isNotEmpty)
            'Authorization': 'Bearer $embeddingsApiKeyValue',
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
    _messages.add(
      chat_api.ChatApiMessage(
        role: chat_api.Role.user,
        content: prompt,
        dateTime: DateTime.now(),
      ),
    );
    final messagesMap = _messages.map((message) => message.toJson()).toList();
    _log.d(messagesMap);

    final generationApiKeyValue = _settingService.get(generationApiKey).value;
    final response = await _dio.post<Map<String, dynamic>>(
      generationApiUrl,
      options: Options(
        headers: {
          'Content-type': 'application/json',
          if (generationApiKeyValue.isNotEmpty)
            'Authorization': 'Bearer $generationApiKeyValue',
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
      final chatMessage = _messages.removeLast();
      _messages.add(
        chat_api.ChatApiMessage(
          role: chat_api.Role.user,
          content: input,
          dateTime: chatMessage.dateTime,
        ),
      );
    }
    _messages.add(
      chat_api.ChatApiMessage(
        role: chat_api.Role.assistant,
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
    final k = int.parse(
      _settingService.get(retrieveTopNResultsKey, type: int).value,
    );
    final embeddings = await _documentService.similaritySearch(
      tablePrefix,
      queryVector,
      k,
      0.5,
    );
    return embeddings;
  }

  Future<Object?> execute(String value) async {
    final regex =
        RegExp(r'^/(\w+)'); // Matches the first word starting with "/"
    final match = regex.firstMatch(value);

    if (match != null) {
      final command = match.group(1);
      _log.d('command $command');
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
          _initMessages();
          return 'Chat messages is cleared from the memory.';
        case 'rag':
          final input = value.substring(5);
          final embeddings = await retrieve(input);
          final context = embeddings.map((e) {
            return '${e.content} ${e.score} ${e.id}';
          }).join('\n');
          final promptTemplate = _settingService.get(promptTemplateKey).value;
          final prompt = promptTemplate
              .replaceFirst(contextPlaceholder, context)
              .replaceFirst(instructionPlaceholder, input);
          return generate(prompt, input);
        case 'sql':
          final query = value.substring(5);
          return _db.query(query);
        case 'h':
          return helpMessage;
        default:
          throw Exception('Unsupported command: /$command. $helpMessageHint');
      }
    } else {
      throw Exception(helpMessageHint);
    }
  }
}
