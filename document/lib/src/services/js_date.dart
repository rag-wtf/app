import 'dart:js_interop';

@JS('Date')
extension type JSDate._(JSObject _) implements JSObject {
  external JSDate(JSString dateString);
  external int getTime();
}
