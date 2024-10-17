import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart';

class HttpStreamClient {
  final client = FetchClient(mode: RequestMode.cors);

  Future<ByteStream> send(Request request) async {
    final response = await client.send(request);
    return response.stream;
  }

  void close() {
    client.close();
  }
}
