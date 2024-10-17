import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('ChatApiServiceTest -', () {
    setUp(registerServices);
    tearDown(locator.reset);
  });
}
