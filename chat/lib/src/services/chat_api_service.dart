import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/constants.dart';
import 'package:chat/src/services/chat_api_message.dart';
import 'package:chat/src/services/message.dart' as chat_message;
import 'package:dio/dio.dart';

class ChatApiService {
  final _log = getLogger('ChatApiService');

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
          if (generationApiKey.isNotEmpty)
            'Authorization': 'Bearer $generationApiKey',
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
          'Accept': 'text/event-stream',
          'Content-Type': 'application/json',
          if (generationApiKey.isNotEmpty)
            'Authorization': 'Bearer $generationApiKey',
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
        .transform(_contentTransformer);
  }

  final StreamTransformer<String, String> _contentTransformer =
      StreamTransformer.fromHandlers(
    handleData: (dataLine, sink) {
      print('dataLine $dataLine');
      if (dataLine.isNotEmpty &&
          !dataLine.startsWith(': ping') && // modal_llama-cpp-python
          dataLine != 'data: [DONE]') {
        final map = dataLine.replaceAll('data: ', '');
        final data = Map<String, dynamic>.from(jsonDecode(map) as Map);
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
    final chatMessages = messages.length > 1
        ? messages
            .sublist(1, min(messages.length, chatWindow))
            .reversed
            .map(
              (message) => ChatApiMessage(
                role: message.role == chat_message.Role.user
                    ? Role.user
                    : Role.assistant,
                content: message.text,
                dateTime: message.updated,
              ),
            )
            .toList()
        : <ChatApiMessage>[]
      ..add(
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
}
