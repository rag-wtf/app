import 'dart:math';

import 'package:chat/src/app/app.logger.dart';
import 'package:chat/src/services/chat_message.dart';
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
  ) async {
    final chatMessages = messages.length > 1
        ? messages
            .sublist(1, min(messages.length, chatWindow))
            .reversed
            .map(
              (message) => ChatMessage(
                role: message.authorId.startsWith('user')
                    ? Role.user
                    : Role.assistant,
                content: message.text,
                dateTime: message.updated,
              ),
            )
            .toList()
        : <ChatMessage>[]
      ..add(
        ChatMessage(
          role: Role.user,
          content: prompt,
          dateTime: DateTime.now(),
        ),
      );
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
