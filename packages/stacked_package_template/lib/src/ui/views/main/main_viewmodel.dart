import 'package:logger/src/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_package_template/src/app/app.logger.dart';

class MainViewModel extends BaseViewModel {
  MainViewModel(this.tablePrefix);
  final String tablePrefix;

  final Logger _log = getLogger('MainViewModel');

  Future<void> initialise() async {
    _log.d('initialise() tablePrefix: $tablePrefix');
  }
}
