// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:console/console.dart';

void main() {
  group('Console', () {
    test('can be instantiated', () {
      expect(Console(), isNotNull);
    });
  });
}
