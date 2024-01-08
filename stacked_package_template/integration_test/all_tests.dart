import 'package:stacked_package_template/src/app/app.locator.dart';

import 'model_repository_test.dart' as model_repository;

Future<void> main() async {
  await setupLocator();
  model_repository.main();
}
