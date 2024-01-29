import 'dart:async';

/// Source: https://github.com/wilinz/openai-dart-dio/blob/main/lib/src/util/sse_transformer.dart
class SseTransformer extends StreamTransformerBase<String, SseMessage> {
  const SseTransformer();
  @override
  Stream<SseMessage> bind(Stream<String> stream) {
    return Stream.eventTransformed(stream, SseEventSink.new);
  }
}

class SseEventSink implements EventSink<String> {
  SseEventSink(this._eventSink);
  final EventSink<SseMessage> _eventSink;

  String? _id;
  String _event = 'message';
  String _data = '';
  int? _retry;

  @override
  void add(String event) {
    if (event.startsWith('id:')) {
      _id = event.substring(3);
      return;
    }
    if (event.startsWith('event:')) {
      _event = event.substring(6);
      return;
    }
    if (event.startsWith('data:')) {
      _data = event.substring(5);
      return;
    }
    if (event.startsWith('retry:')) {
      _retry = int.tryParse(event.substring(6));
      return;
    }
    if (event.isEmpty) {
      _eventSink
          .add(SseMessage(id: _id, event: _event, data: _data, retry: _retry));
      _id = null;
      _event = 'message';
      _data = '';
      _retry = null;
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _eventSink.addError(error, stackTrace);
  }

  @override
  void close() {
    _eventSink.close();
  }
}

class SseMessage {
  const SseMessage({
    required this.event,
    required this.data,
    this.id,
    this.retry,
  });
  final String? id;
  final String event;
  final String data;
  final int? retry;
}
