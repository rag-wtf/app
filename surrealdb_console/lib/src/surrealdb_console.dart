import 'package:console/console.dart';
import 'package:flutter/widgets.dart';
import 'package:surrealdb_wasm/surrealdb_wasm.dart';

class SurrealdbConsole extends StatefulWidget {
  const SurrealdbConsole({
    required this.endpoint,
    required this.ns,
    required this.db,
    super.key,
  });

  final String endpoint;
  final String ns;
  final String db;

  @override
  State<SurrealdbConsole> createState() => _SurrealdbConsoleState();
}

class _SurrealdbConsoleState extends State<SurrealdbConsole> {
  final db = Surreal();

  Future<void> initFunction() async {
    await db.connect(widget.endpoint);
    await db.use(ns: widget.ns, db: widget.db);
  }

  Future<Object?> executeFunction(String value) async {
    return db.query(value);
  }

  @override
  Widget build(BuildContext context) {
    return Console(
      content:
          'Connected to ${widget.endpoint}, ns: ${widget.ns}, db: ${widget.db}.\n',
      initFunction: initFunction,
      executeFunction: executeFunction,
    );
  }
}
