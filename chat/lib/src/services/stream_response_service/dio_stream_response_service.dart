import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chat/src/services/stream_response_service/sse_transformer.dart';
import 'package:chat/src/services/stream_response_service/stream_response_service.dart';
import 'package:dio/dio.dart';

class DioStreamResponseService extends StreamResponseService {
  final _uint8Transformer =
      StreamTransformer<Uint8List, List<int>>.fromHandlers(
    handleData: (data, sink) {
      sink.add(List<int>.from(data));
    },
  );
  final dio = Dio();
  final cancelToken = CancelToken();

  @override
  Future<void> send(
    String url,
    Map<String, dynamic> headers,
    Map<String, dynamic> body,
    void Function(String content)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) async {
    final response = await dio.post<ResponseBody>(
      url,
      data: body,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
      ),
      //onReceiveProgress: (count, total) => print('$count/$total'),
      cancelToken: cancelToken,
    );

    response.data?.stream
        .transform(_uint8Transformer)
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .transform(const SseTransformer())
        .transform(contentTransformer)
        .listen(
          onData,
          onDone: onDone,
          onError: onError,
          cancelOnError: cancelOnError,
        );
  }

  @override
  Future<void> cancel() async {
    cancelToken.cancel();
  }
}
