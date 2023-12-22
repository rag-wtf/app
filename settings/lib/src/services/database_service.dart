import 'package:settings/src/constants.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DatabaseService {
  static Surreal getInstance() {
    final db = Surreal();
    db.connect(surrealEndpoint).then(
          (value) => db.use(
            ns: surrealNamespace,
            db: surrealDatabase,
          ),
        );
    return db;
  }
}
