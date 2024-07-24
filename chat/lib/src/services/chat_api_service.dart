import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/app/app.logger.dart';

import 'package:chat/src/services/chat_api_message.dart';
import 'package:chat/src/services/message.dart' as chat_message;
import 'package:chat/src/services/sse_transformer.dart';
import 'package:dio/dio.dart';

enum ApiKeyType { header, body }

class ChatApiService {
  final _gzipEncoder = locator<GZipEncoder>();
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

  Stream<String> generateStream(
    Dio dio,
    List<chat_message.Message> messages,
    int chatWindow,
    String prompt,
    String generationApiUrl,
    String generationApiKey,
    String model,
    String systemPrompt, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async* {
    final response = await dio.post<ResponseBody>(
      generationApiUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          ...?getGenerationApiKey(
            ApiKeyType.header,
            generationApiUrl,
            generationApiKey,
          ),
        },
        responseType: ResponseType.stream,
      ),
      data: {
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
      },
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    if (response.data == null) {
      throw Exception('Response data is null');
    }
    yield* response.data!.stream
        .transform(_uint8Transformer)
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .transform(const SseTransformer())
        .transform(_contentTransformer);
  }

  final StreamTransformer<SseMessage, String> _contentTransformer =
      StreamTransformer.fromHandlers(
    handleData: (message, sink) {
      final dataLine = message.data;
      if (dataLine.isNotEmpty &&
          !dataLine.startsWith(': ping') && // modal_llama-cpp-python
          !dataLine.contains('[DONE]')) {
        //final map = dataLine.replaceAll('data: ', '');
        final data = Map<String, dynamic>.from(jsonDecode(dataLine) as Map);
        final choices = List<dynamic>.from(data['choices'] as List);
        final choice = Map<String, dynamic>.from(choices[0] as Map);
        if (choice['finish_reason'] == null) {
          final delta = Map<String, dynamic>.from(choice['delta'] as Map);
          final content = delta['content'] as String;
          sink.add(content);
        }
      }
    },
  );

  final StreamTransformer<Uint8List, List<int>> _uint8Transformer =
      StreamTransformer.fromHandlers(
    handleData: (data, sink) {
      sink.add(List<int>.from(data));
    },
  );

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
    String input,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      embeddingsApiUrl,
      options: Options(
        headers: {
          'Content-type': 'application/json',
          if (embeddingsApiKey.isNotEmpty)
            'Authorization': 'Bearer $embeddingsApiKey',
        },
        requestEncoder: _gzipEncoderFunction,
      ),
      data: {
        'input': getEmbeddingInput(input),
      },
    );
    return response.data;
  }
}
