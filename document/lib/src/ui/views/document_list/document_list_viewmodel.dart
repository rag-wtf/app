import 'package:document/src/services/document.dart';
import 'package:stacked/stacked.dart';

class DocumentListViewModel extends FutureViewModel<void> {
  DocumentListViewModel(this.tablePrefix);
  final String tablePrefix;
  final List<Document> _items = [];
  List<Document> get items => _items;

  @override
  Future<void> futureToRun() async {}

  void addItem() {}
}
