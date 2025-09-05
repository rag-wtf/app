class SurrealDB {
  Future<void> connect(String url) async {}
  Future<void> close() async {}
  Future<dynamic> signup(Map<String, dynamic> data) async {}
  Future<dynamic> signin(Map<String, dynamic> data) async {}
  Future<void> use(String ns, String db) async {}
  Future<dynamic> query(String query) async {}
  Future<dynamic> select(String table) async {}
  Future<dynamic> create(String table, Map<String, dynamic> data) async {}
  Future<dynamic> update(String record, Map<String, dynamic> data) async {}
  Future<dynamic> delete(String record) async {}
}
