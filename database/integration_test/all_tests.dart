import 'package:database/src/app/app.locator.dart';

import 'connection_setting_repository_test.dart'
    as connection_setting_repository;
// import 'model_repository_test.dart' as model_repository;

Future<void> main() async {
  await setupLocator();
  connection_setting_repository.main();
  //model_repository.main();
}
