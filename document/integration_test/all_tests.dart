import 'package:document/src/app/app.locator.dart';

import 'document_embedding_repository_test.dart'
    as document_embedding_repository;
import 'document_repository_test.dart' as document_repository;
import 'document_service_test.dart' as document_service;
import 'embedding_repository_test.dart' as embedding_repository;

Future<void> main() async {
  await setupLocator();
  await Future<void>.delayed(const Duration(seconds: 3));
  document_repository.main();
  embedding_repository.main();
  document_embedding_repository.main();
  document_service.main();
}
