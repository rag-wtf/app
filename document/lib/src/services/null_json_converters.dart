import 'package:json_annotation/json_annotation.dart';

class NullJsonConverter<T> extends JsonConverter<T, T> {
  const NullJsonConverter();

  @override
  T fromJson(T json) {
    return json;
  }

  @override
  T toJson(T object) {
    return object;
  }
}

class NullDateTimeJsonConverter extends NullJsonConverter<DateTime> {
  const NullDateTimeJsonConverter();
}
