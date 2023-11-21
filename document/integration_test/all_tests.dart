import 'document_embedding_repository_test.dart'
    as document_embedding_repository;
import 'document_repository_test.dart' as document_repository;
import 'embedding_repository_test.dart' as embedding_repository;

void main() {
  document_repository.main();
  embedding_repository.main();
  document_embedding_repository.main();
}
