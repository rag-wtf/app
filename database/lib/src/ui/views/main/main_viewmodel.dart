import 'package:database/src/app/app.dialogs.dart';
import 'package:database/src/app/app.locator.dart';
import 'package:database/src/app/app.logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MainViewModel extends BaseViewModel {
  MainViewModel(this.tablePrefix);
  final String tablePrefix;

  final _log = getLogger('MainViewModel');
  final _dialogService = locator<DialogService>();

  Future<void> initialise() async {
    _log.d('initialise() tablePrefix: $tablePrefix');
  }

  void showDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.connection,
      title: 'Connection',
      description: 'Create database connection',
    );
  }
}
