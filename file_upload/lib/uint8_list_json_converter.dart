import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';

class Uint8ListJsonConverter
    implements JsonConverter<Uint8List, List<Object?>> {
  const Uint8ListJsonConverter();

  @override
  Uint8List fromJson(List<Object?> json) {
    return json.isNotEmpty
        ? Uint8List.fromList(List<int>.from(json))
        : Uint8List(0);
  }

  @override
  List<int> toJson(Uint8List data) {
    return data.toList();
  }
}
