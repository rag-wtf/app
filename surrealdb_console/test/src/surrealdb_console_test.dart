// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:surrealdb_console/surrealdb_console.dart';

void main() {
  group('SurrealdbConsole', () {
    test('can be instantiated', () {
      expect(SurrealdbConsole(), isNotNull);
    });
  });
}
