import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/constants.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_service.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';

class DocumentListViewModel extends FutureViewModel<void> {
  DocumentListViewModel(this.tablePrefix);
  final String tablePrefix;
  int _total = 0;
  final _items = <Document>[];
  List<Document> get items => _items;
  final _documentService = locator<DocumentService>();
  final _settingService = locator<SettingService>();
  final _log = getLogger('DocumentListViewModel');

  @override
  Future<void> futureToRun() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    _log.d('futureToRun() tablePrefix: $tablePrefix');
    await _settingService.initialise(tablePrefix);
    final isSchemaCreated = await _documentService.isSchemaCreated(tablePrefix);
    _log.d('isSchemaCreated $isSchemaCreated');

    if (!isSchemaCreated) {
      _log.d('before createSchema()');
      //await _documentService.createSchema(tablePrefix);
      _log.d('after createSchema()');
    }
    await fetchData();
  }

  bool get hasReachedMax {
    final reachedMax = items.length >= _total;
    _log.d(reachedMax);
    return reachedMax;
  }

  Future<void> fetchData() async {
    final page = _items.length ~/ defaultPageSize;
    _log.d('page $page');
    final documentList = await _documentService.getDocumentList(
      tablePrefix,
      page: page,
      pageSize: defaultPageSize,
    );
    _log.d('documentList.total ${documentList.total}');
    if (documentList.total > 0) {
      _items.addAll(documentList.items);
      _total = documentList.total;
      notifyListeners();
    }
  }

  Future<void> addItem(Document? document) async {
    if (document != null) {
      final createdDocument =
          await _documentService.createDocument(tablePrefix, document);
      if (createdDocument.id != null) {
        _items.insert(0, createdDocument);
        notifyListeners();
      }
    }
  }

  void setItem(int index, Document document) {
    _items[index] = document;
  }
}
