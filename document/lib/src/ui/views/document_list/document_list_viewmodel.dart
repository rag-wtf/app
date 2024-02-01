import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_item.dart';
import 'package:document/src/services/document_service.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';

class DocumentListViewModel extends ReactiveViewModel {
  DocumentListViewModel(this.tablePrefix);
  final String tablePrefix;

  final _documentService = locator<DocumentService>();
  final _settingService = locator<SettingService>();
  final _log = getLogger('DocumentListViewModel');

  List<DocumentItem> get items => _documentService.items;

  @override
  List<ListenableServiceMixin> get listenableServices => [_documentService];

  Future<void> initialise() async {
    _log.d('initialise() tablePrefix: $tablePrefix');
    await _settingService.initialise(tablePrefix);
    await _documentService.initialise(tablePrefix);
  }

  bool get hasReachedMax => _documentService.hasReachedMax;

  Future<void> fetchData() async {
    await _documentService.fetchData(tablePrefix);
  }

  Future<void> addItem(Document? document) async {
    await _documentService.addItem(tablePrefix, document);
  }
}
