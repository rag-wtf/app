import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stacked/stacked.dart';

class FeatureFlagService with ListenableServiceMixin {
  FeatureFlagService() {
    listenToReactiveValues([_showRagPipelineLevelSelector]);
  }

  static const String ragPipelineLevelSelector = 'RAG_PIPELINE_LEVEL_SELECTOR';

  final ReactiveValue<bool> _showRagPipelineLevelSelector =
      ReactiveValue(false);
  bool get showRagPipelineLevelSelector => _showRagPipelineLevelSelector.value;

  Future<void> initialise() async {
    await dotenv.load(fileName: ".env");
    _showRagPipelineLevelSelector.value =
        isFeatureEnabled(ragPipelineLevelSelector);
  }

  bool isFeatureEnabled(String featureName) {
    return dotenv.env[featureName]?.toLowerCase() == 'true';
  }
}
