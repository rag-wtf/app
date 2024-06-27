import 'package:database/database.dart';
import 'package:document/src/app/app.dialogs.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_item.dart';
import 'package:document/src/services/document_service.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DocumentListViewModel extends ReactiveViewModel {
  DocumentListViewModel(this.tablePrefix, {required this.hasConnectDatabase});
  final String tablePrefix;
  final bool hasConnectDatabase;

  final _documentService = locator<DocumentService>();
  final _settingService = locator<SettingService>();
  final _dialogService = locator<DialogService>();
  final _connectionSettingService = locator<ConnectionSettingService>();

  final _log = getLogger('DocumentListViewModel');

  List<DocumentItem> get items => _documentService.items;

  @override
  List<ListenableServiceMixin> get listenableServices => [_documentService];

  Future<void> initialise() async {
    _log.d('initialise() tablePrefix: $tablePrefix');
    if (hasConnectDatabase) {
      await connectDatabase();
    }
    await _settingService.initialise(tablePrefix);
    await _documentService.initialise(tablePrefix);
  }

  Future<void> connectDatabase() async {
    var confirmed = false;
    if (!await _connectionSettingService.autoConnect()) {
      while (!confirmed) {
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.connection,
          title: 'Connection',
          description: 'Create database connection',
        );

        confirmed = response?.confirmed ?? false;
      }
    }
  }

  bool get hasReachedMax => _documentService.hasReachedMax;

  Future<void> fetchData() async {
    await _documentService.fetchData(tablePrefix);
  }

  Future<void> addItem(Document? document) async {
    await _documentService.addItem(tablePrefix, document);
  }
}
