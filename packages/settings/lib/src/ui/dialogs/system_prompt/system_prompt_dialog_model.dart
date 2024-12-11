import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:settings/settings.dart';
import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/app/app.logger.dart';
import 'package:settings/src/ui/dialogs/system_prompt/system_prompt_dialog.form.dart';
import 'package:stacked/stacked.dart';

class SystemPromptDialogModel extends FormViewModel {
  SystemPromptDialogModel(this.tablePrefix);
  final _log = getLogger('SystemPromptDialogModel');
  final _settingService = locator<SettingService>();
  final _analyticsFacade = locator<AnalyticsFacade>();
  final String tablePrefix;

  Future<void> initialise() async {
    systemPromptValue = _settingService.get(systemPromptKey).value;
    _log.d('systemPrompt $systemPromptValue');
  }

  Future<void> save() async {
    if (systemPromptValue != null &&
        systemPromptValue!.isNotEmpty &&
        systemPromptValue != _settingService.get(systemPromptKey).value) {
      await _settingService.set(
        tablePrefix,
        systemPromptKey,
        systemPromptValue!,
      );
      unawaited(_analyticsFacade.trackSystemPromptEdited());
    }
  }
}
