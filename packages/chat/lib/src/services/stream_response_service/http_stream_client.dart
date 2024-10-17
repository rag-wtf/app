import 'package:http/http.dart';

class HttpStreamClient {
  final client = Client();

  Future<ByteStream> send(Request request) async {
    final response = await client.send(request);
    return response.stream;
  }

  void close() {
    client.close();
  }
}
