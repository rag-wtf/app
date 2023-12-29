import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/constants.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_service.dart';
import 'package:stacked/stacked.dart';

class DocumentListViewModel extends FutureViewModel<void> {
  DocumentListViewModel(this.tablePrefix);
  final String tablePrefix;
  int _total = -1;
  final _items = <Document>[];
  List<Document> get items => _items;
  final _documentService = locator<DocumentService>();
  final _log = getLogger('DocumentListViewModel');

  @override
  Future<void> futureToRun() async {
    _log.d('futureToRun() tablePrefix: $tablePrefix');
    final isSchemaCreated = await _documentService.isSchemaCreated(tablePrefix);
    _log.d('isSchemaCreated $isSchemaCreated');

    if (!isSchemaCreated) {
      _log.d('before createSchema()');
      await _documentService.createSchema(tablePrefix);
    }

    await test();
  }

  bool get hasReachedMax {
    final reachedMax = _total > -1 && items.length >= _total;
    _log.d(reachedMax);
    return reachedMax;
  }

  Future<void> test() async {
    _log.d('test()');
  }

  Future<void> onFetchData() async {
    _log.d('onFetchData()');
    final page = _items.length ~/ defaultPageSize;
    _log.d('page $page');
    final documentList = await _documentService.getDocumentList(
      tablePrefix,
      page: page,
    );
    _items.addAll(documentList.items);
    _total = documentList.total;
    notifyListeners();
  }

  Future<void> addItem(Document? document) async {
    if (document != null) {
      final createdDocument =
          await _documentService.createDocument(tablePrefix, document);
      if (createdDocument != null) {
        notifyListeners();
      }
    }
  }
}
