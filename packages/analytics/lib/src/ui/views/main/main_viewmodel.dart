import 'package:stacked/stacked.dart';
import 'package:analytics/src/app/app.logger.dart';

class MainViewModel extends BaseViewModel {
  MainViewModel(this.tablePrefix);
  final String tablePrefix;

  final _log = getLogger('MainViewModel');

  Future<void> initialise() async {
    _log.d('initialise() tablePrefix: $tablePrefix');
  }
}
