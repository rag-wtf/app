import 'dart:async';
import 'dart:convert';

import 'package:chat/src/services/stream_response_service/sse_transformer.dart';

class StreamResponseService {
  StreamTransformer<SseMessage, String> get contentTransformer =>
      _contentTransformer;
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
          if (delta['content'] != null) {
            final content = delta['content'] as String;
            sink.add(content);
          }
        }
      }
    },
  );

  Future<void> send(
    String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
    void Function(String content)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    throw UnimplementedError();
  }

  Future<void> cancel() {
    throw UnimplementedError();
  }
}
