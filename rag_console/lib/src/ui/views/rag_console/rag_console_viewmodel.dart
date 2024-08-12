import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:chat/chat.dart';
// ignore: implementation_imports
import 'package:chat/src/services/chat_api_message.dart' as chat_api;
import 'package:database/database.dart';
import 'package:dio/dio.dart';
import 'package:document/document.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rag_console/src/app/app.locator.dart';
import 'package:rag_console/src/app/app.logger.dart';

import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:surrealdb_js/surrealdb_js.dart';

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
  final _storage = locator<FlutterSecureStorage>();
  final _connectionSettingRepository = locator<ConnectionSettingRepository>();
  final _log = getLogger('RagConsoleViewModel');
  late String _surrealVersion;
  late String surrealEndpoint;
  late String surrealNamespace;
  late String surrealDatabase;
  String get _embeddingsApiUrl =>
      _settingService.get(embeddingsApiUrlKey).value;
  String get _generationApiUrl =>
      _settingService.get(generationApiUrlKey).value;
  String get _generationApiKeyValue =>
      _settingService.get(generationApiKey).value;
  String get _generationModel => _settingService.get(generationModelKey).value;
  double get _searchThreshold =>
      _settingService.get(searchThresholdKey).value as double;
  String get surrealVersion => _surrealVersion;
  bool get _embeddingsCompressed => bool.parse(
        _settingService.get(embeddingsCompressedKey).value,
      );

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
    setBusy(true);
    _log.d('initialise() tablePrefix: $tablePrefix');
    await _settingService.initialise(tablePrefix);
    final dimensions = _settingService.get(embeddingsDimensionsKey).value;
    await _documentService.initialise(tablePrefix, dimensions);
    await _chatService.initialise(tablePrefix);
    _initMessages();
    _surrealVersion = await _db.version();
    final lastConnectionKey =
        await _storage.read(key: ConnectionSetting.lastConnectionKey);
    if (lastConnectionKey != null) {
      final connectionSettings = await _connectionSettingRepository
          .getAllConnectionSettings(lastConnectionKey);
      final protocol = connectionSettings[
          '${lastConnectionKey}_${ConnectionSetting.protocolKey}']!;
      final addressPort = connectionSettings[
          '${lastConnectionKey}_${ConnectionSetting.addressPortKey}']!;
      surrealEndpoint = '$protocol://$addressPort';
      surrealNamespace = connectionSettings[
          '${lastConnectionKey}_${ConnectionSetting.namespaceKey}']!;
      surrealDatabase = connectionSettings[
          '${lastConnectionKey}_${ConnectionSetting.databaseKey}']!;
    }
    setBusy(false);
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
    final dimensions = int.parse(
      _settingService.get(embeddingsDimensionsKey).value,
    );
    final response = await _dio.post<Map<String, dynamic>>(
      _embeddingsApiUrl,
      options: Options(
        headers: {
          'Content-type': 'application/json',
          if (embeddingsApiKeyValue.isNotEmpty)
            'Authorization': 'Bearer $embeddingsApiKeyValue',
        },
        requestEncoder: _embeddingsCompressed ? gzipEncoder : null,
      ),
      data: {
        'model': _settingService.get(embeddingsModelKey).value,
        'input': getEmbeddingInput(input),
        'dimensions': dimensions,
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
    final isLiteLlmProxy = _generationApiUrl.contains(litellm);
    final response = await _dio.post<Map<String, dynamic>>(
      _generationApiUrl,
      options: Options(
        headers: {
          'Content-type': 'application/json',
          if (!isLiteLlmProxy && _generationApiKeyValue.isNotEmpty)
            'Authorization': 'Bearer $_generationApiKeyValue',
        },
      ),
      data: {
        'model': _generationModel,
        'messages': messagesMap,
        if (isLiteLlmProxy && _generationApiKeyValue.isNotEmpty)
          'api_key': _generationApiKeyValue,
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
      _settingService.get(retrieveTopNResultsKey).value,
    );
    final embeddings = await _documentService.similaritySearch(
      tablePrefix,
      queryVector,
      k,
      _searchThreshold,
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
