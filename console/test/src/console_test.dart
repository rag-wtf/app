// ignore_for_file: prefer_const_constructors

import 'package:console/console.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Console', () {
    test('can be instantiated', () {
      expect(Console(), isNotNull);
    });
  });
}
