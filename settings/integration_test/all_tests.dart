import 'package:settings/src/app/app.locator.dart';

import 'setting_repository_test.dart' as setting_repository;

Future<void> main() async {
  await setupLocator();
  setting_repository.main();
}
