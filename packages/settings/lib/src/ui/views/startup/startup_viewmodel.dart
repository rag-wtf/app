import 'package:settings/src/app/app.dialogs.dart';
import 'package:settings/src/app/app.locator.dart';
import 'package:settings/src/app/app.router.dart';
import 'package:stacked/stacked.dart';

import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  // Place anything here that needs to happen before we get into the application
  Future<void> runStartupLogic() async {
    // This is where you can make decisions on where your app should navigate
    // when you have custom startup logic
    await _navigationService.replaceWithSettingsView(
      showSystemPromptDialogFunction: showSystemPromptDialog,
      showPromptTemplateDialogFunction: showPromptTemplateDialog,
    );
  }

  Future<void> showPromptTemplateDialog() async {
    await _dialogService.showCustomDialog(
      variant: DialogType.promptTemplate,
      title: 'Edit Prompt Template',
      description: 'Prompt template for the LLM.',
    );
  }

  Future<void> showSystemPromptDialog() async {
    await _dialogService.showCustomDialog(
      variant: DialogType.systemPrompt,
      title: 'Edit System Prompt',
      description: 'Custom instructions for the chatbot.',
    );
  }
}
