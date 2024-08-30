import 'dart:js_interop';

import 'package:document/src/services/js_date.dart';
import 'package:json_annotation/json_annotation.dart';

class JSDateJsonConverter implements JsonConverter<DateTime, JSDate> {
  const JSDateJsonConverter();

  @override
  DateTime fromJson(JSDate jsDate) {
    return DateTime.fromMillisecondsSinceEpoch(jsDate.getTime());
  }

  @override
  JSDate toJson(DateTime dateTime) {
    return JSDate(dateTime.toUtc().toIso8601String().toJS);
  }
}
