import 'package:document/src/app/app.locator.dart';
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
  final documentService = locator<DocumentService>();

  @override
  Future<void> futureToRun() async {
    if (!await documentService.isSchemaCreated(tablePrefix)) {
      await documentService.createSchema(tablePrefix);
    }
  }

  bool get hasReachedMax {
    final reachedMax = items.length >= _total;
    return reachedMax;
  }

  Future<void> fetchData() async {
    final page = items.length ~/ defaultPageSize;
    final documentList = await documentService.getDocumentList(
      tablePrefix,
      page: page,
    );
    _items.addAll(documentList.items);
    _total = documentList.total;
  }

  Future<void> addItem(Document? document) async {
    if (document != null) {
      await documentService.createDocument(tablePrefix, document);
    }
  }
}
