import 'package:settings/settings.dart';
import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/app/app.logger.dart';
import 'package:settings/src/ui/dialogs/prompt_template/prompt_template_dialog.form.dart';
import 'package:stacked/stacked.dart';

class PromptTemplateDialogModel extends FormViewModel {
  PromptTemplateDialogModel(this.tablePrefix);
  final _log = getLogger('PromptTemplateDialogModel');
  final _settingService = locator<SettingService>();
  final String tablePrefix;

  Future<void> initialise() async {
    promptTemplateValue = _settingService.get(promptTemplateKey).value;
    _log.d('promptTemplate $promptTemplateValue');
  }

  Future<void> save() async {
    if (promptTemplateValue != null &&
        promptTemplateValue!.isNotEmpty &&
        promptTemplateValue != _settingService.get(promptTemplateKey).value) {
      await _settingService.set(
        tablePrefix,
        promptTemplateKey,
        promptTemplateValue!,
      );
    }
  }
}
