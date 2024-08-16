import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';

import 'package:chat/src/services/chat_api_message.dart';
import 'package:chat/src/services/message.dart' as chat_message;
import 'package:chat/src/services/stream_response_service/stream_response_service.dart';
import 'package:dio/dio.dart';
import 'package:settings/settings.dart';

enum ApiKeyType { header, body }

class ChatApiService {
  final _gzipEncoder = locator<GZipEncoder>();
  final _streamResponseService = locator<StreamResponseService>();
  final _log = getLogger('ChatApiService');

  Map<String, String>? getGenerationApiKey(
    ApiKeyType type,
    String generationApiUrl,
    String generationApiKey,
  ) {
    if (generationApiKey.isNotEmpty) {
      if (type == ApiKeyType.header && !generationApiUrl.contains('litellm')) {
        return {'Authorization': 'Bearer $generationApiKey'};
      } else if (type == ApiKeyType.body &&
          generationApiUrl.contains('litellm')) {
        return {'api_key': generationApiKey};
      }
    }
    return null;
  }

  Future<String> generate(
    Dio dio,
    List<chat_message.Message> messages,
    int chatWindow,
    String prompt,
    String generationApiUrl,
    String generationApiKey,
    String model,
    String systemPrompt,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      generationApiUrl,
      options: Options(
        headers: {
          'Content-type': 'application/json',
          ...?getGenerationApiKey(
            ApiKeyType.header,
            generationApiUrl,
            generationApiKey,
          ),
        },
      ),
      data: {
        'model': model,
        'messages': _getMessages(
          messages,
          chatWindow,
          prompt,
          systemPrompt,
        ),
        ...?getGenerationApiKey(
          ApiKeyType.body,
          generationApiUrl,
          generationApiKey,
        ),
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

    return content;
  }

  /*Stream<String> fakeStream() async* {
    final words =
        'A powerful HTTP networking package for Dart/Flutter, supports Global configuration, Interceptors, FormData, Request cancellation, File uploading/downloading, Timeout, Custom adapters, Transformers, etc.'
            .split(' ');

    for (final word in words) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      yield '$word ';
    }
  }*/

  Future<void> generateStream(
    List<chat_message.Message> messages,
    int chatWindow,
    String prompt,
    String generationApiUrl,
    String generationApiKey,
    String model,
    String systemPrompt,
    void Function(String content)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) async {
    //generationApiUrl = 'http://localhost:11434/v1/chat/completions';
    //model = 'tinyllama';
    final headers = {
      'Content-Type': 'application/json',
      ...?getGenerationApiKey(
        ApiKeyType.header,
        generationApiUrl,
        generationApiKey,
      ),
    };

    final body = {
      'model': model,
      'messages': _getMessages(
        messages,
        chatWindow,
        prompt,
        systemPrompt,
      ),
      'stream': true,
      ...?getGenerationApiKey(
        ApiKeyType.body,
        generationApiUrl,
        generationApiKey,
      ),
    };

    await _streamResponseService.send(
      generationApiUrl,
      headers,
      body,
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  List<Map<String, dynamic>> _getMessages(
    List<chat_message.Message> messages,
    int chatWindow,
    String prompt,
    String systemPrompt,
  ) {
    final now = DateTime.now();
    // 0 is loading message
    // 1 is current user message which will be formatted with prompt template
    final chatMessages = messages.length > 1
        ? messages
            .sublist(2, min(messages.length, chatWindow))
            .reversed
            .map(
              (message) => ChatApiMessage(
                role: message.role == chat_message.Role.user
                    ? Role.user
                    : Role.assistant,
                content: message.text,
                dateTime: message.updated!,
              ),
            )
            .toList()
        : <ChatApiMessage>[]
      ..add(
        // added back message[1] with formatted prompt template
        ChatApiMessage(
          role: Role.user,
          content: prompt,
          dateTime: now,
        ),
      );
    if (systemPrompt.isNotEmpty) {
      chatMessages.insert(
        0,
        ChatApiMessage(
          role: Role.system,
          content: systemPrompt,
          dateTime: now,
        ),
      );
    }
    final messagesMap = chatMessages
        .map(
          (message) => message.toJson(),
        )
        .toList();
    _log.d(messagesMap);
    return messagesMap;
  }

  dynamic getEmbeddingInput(String input) {
    try {
      return jsonDecode(input);
    } catch (e) {
      return input;
    }
  }

  List<int> _gzipEncoderFunction(String request, RequestOptions options) {
    options.headers.putIfAbsent('Content-Encoding', () => 'gzip');
    return _gzipEncoder.encode(utf8.encode(request))!;
  }

  Future<Map<String, dynamic>?> embed(
    Dio dio,
    String embeddingsApiUrl,
    String embeddingsApiKey,
    String model,
    String input, {
    int dimensions = defaultEmbeddingsDimensions,
    bool compressed = true,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      embeddingsApiUrl,
      options: Options(
        headers: {
          'Content-type': 'application/json',
          if (embeddingsApiKey.isNotEmpty)
            'Authorization': 'Bearer $embeddingsApiKey',
        },
        requestEncoder: compressed ? _gzipEncoderFunction : null,
      ),
      data: {
        'model': model,
        'input': getEmbeddingInput(input),
        'dimensions': dimensions,
      },
    );
    return response.data;
  }
}
