import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class DatabaseService {
  static const documentsTableSql = '''
    DEFINE TABLE documents SCHEMAFULL;
    DEFINE FIELD id ON TABLE documents TYPE uuid;
    DEFINE FIELD content ON TABLE documents TYPE string;
    DEFINE FIELD embedding ON TABLE documents TYPE array<float, 384>; --768 or 1024
    DEFINE FIELD metadata ON TABLE documents TYPE object;
    DEFINE INDEX idx_mtree_embedding ON documents FIELDS embedding MTREE DIMENSION 384 DIST COSINE;
  ''';

  static const insertDocumentsSql = r'INSERT INTO documents $documents';
  static const ns = 'rag';
  final db = Surreal();

  Future<void> connect() async {
    await db.connect('indxdb://$ns');
  }

  Future<void> use({
    bool createSchema = false,
  }) async {
    await db.use(ns: ns, db: 'test');
    if (createSchema) {
      await db.query(documentsTableSql);
    }
  }

  Future<dynamic> insertDocuments(List<Map<String, dynamic>> documents) async {
    return db.query(
      insertDocumentsSql,
      {
        'documents': documents,
      },
    );
  }
}
