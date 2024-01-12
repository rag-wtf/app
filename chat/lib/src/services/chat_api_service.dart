import 'dart:math';

import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat_api_message.dart';
import 'package:chat/src/services/message.dart';
import 'package:dio/dio.dart';

class ChatApiService {
  final _log = getLogger('ChatApiService');

  Future<String> generate(
    Dio dio,
    List<Message> messages,
    int chatWindow,
    String prompt,
    String generationApiUrl,
    String generationApiKey,
    String model,
    String systemPrompt,
  ) async {
    final now = DateTime.now();
    final chatMessages = messages.length > 1
        ? messages
            .sublist(1, min(messages.length, chatWindow))
            .reversed
            .map(
              (message) => ChatApiMessage(
                role: message.authorId.startsWith('user')
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

    return content;
  }
}
