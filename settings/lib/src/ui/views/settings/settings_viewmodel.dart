import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/constants.dart';
import 'package:settings/src/services/setting_service.dart';
import 'package:settings/src/ui/views/settings/settings_view.form.dart';
import 'package:stacked/stacked.dart';

class SettingsViewModel extends FutureViewModel<void> with FormStateHelper {
  SettingsViewModel(this.prefix);
  final String prefix;
  final _isPanelExpanded = List.filled(4, true);
  final SettingService _settingService = locator();
  bool isPanelExpanded(int index) => _isPanelExpanded[index];

  void setPanelExpanded(int index, {required bool isExpanded}) {
    _isPanelExpanded[index] = isExpanded;

    notifyListeners();
  }

  @override
  Future<void> futureToRun() async {
    await _settingService.initialise(prefix);

    final dataIngestionApiUrl = _settingService.get(dataIngestionApiUrlKey);
    if (dataIngestionApiUrl.id != null) {
      dataIngestionApiUrlValue = dataIngestionApiUrl.value;
    }

    final embeddingsApiBatchSize =
        _settingService.get(embeddingsApiBatchSizeKey, type: int);
    if (embeddingsApiBatchSize.id != null) {
      embeddingsApiBatchSizeValue = embeddingsApiBatchSize.value;
    }
  }

  Future<void> setDataIngestionApiUrl() async {
    if (hasDataIngestionApiUrl && !hasDataIngestionApiUrlValidationMessage) {
      await _settingService.set(
        prefix,
        dataIngestionApiUrlKey,
        dataIngestionApiUrlValue!,
      );
    }
  }

  Future<void> setEmbeddingsApiBatchSize() async {
    if (hasEmbeddingsApiBatchSize &&
        !hasEmbeddingsApiBatchSizeValidationMessage) {
      await _settingService.set(
        prefix,
        embeddingsApiBatchSizeKey,
        embeddingsApiBatchSizeValue!,
      );
    }
  }
}
