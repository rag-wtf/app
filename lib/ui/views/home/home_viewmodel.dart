import 'package:rag/app/app.bottomsheets.dart';
import 'package:rag/app/app.dialogs.dart';
import 'package:rag/app/app.locator.dart';
import 'package:rag/ui/common/app_strings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart' show SheetResponse;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart' show SheetResponse, SheetRequest;

class HomeViewModel extends FutureViewModel<void> {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
    await Future.delayed(Duration.zero);
  final _settingService = locator<SettingService>();

  String get counterLabel => 'Counter is: $_counter';
 int _counter = 0;
  Future<void> futureToRun() async {

  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void showDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Stacked Rocks!',
      description: 'Give stacked $_counter stars on Github',
    );
  }

  void showBottomSheet() {\n  final bottomSheetService = locator<BottomSheetService>();() {
    _bottomSheetService.showCustomSheet<SheetRequest>(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }

  String getSettingValue(String key, {Type? type}) {
    final setting = _settingService.get(key, type: type);
    return setting.value;
  }

  @override
  Future<void> futureToRun() async {
    await _settingService.initialise(defaultTablePrefix);
  }
}
