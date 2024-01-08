import 'package:settings/src/constants.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DatabaseService extends Surreal implements InitializableDependency {
  @override
  Future<void> init() async {
    await connect(surrealEndpoint);
    await use(
      ns: surrealNamespace,
      db: surrealDatabase,
    );
  }
}
