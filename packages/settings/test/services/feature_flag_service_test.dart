import 'package:flutter_test/flutter_test.dart';
import 'package:settings/src/services/feature_flag_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('FeatureFlagServiceTest -', () {
    setUp(() {
      dotenv.testLoad(fileInput: '');
    });
    test('when feature is enabled, isFeatureEnabled should return true',
        () async {
      dotenv.testLoad(fileInput: '''RAG_PIPELINE_LEVEL_SELECTOR=true''');
      final service = FeatureFlagService();
      await service.initialise();
      expect(
          service.isFeatureEnabled(FeatureFlagService.ragPipelineLevelSelector),
          isTrue);
      expect(service.showRagPipelineLevelSelector, isTrue);
    });

    test('when feature is disabled, isFeatureEnabled should return false',
        () async {
      dotenv.testLoad(fileInput: '''RAG_PIPELINE_LEVEL_SELECTOR=false''');
      final service = FeatureFlagService();
      await service.initialise();
      expect(
          service.isFeatureEnabled(FeatureFlagService.ragPipelineLevelSelector),
          isFalse);
      expect(service.showRagPipelineLevelSelector, isFalse);
    });

    test('when feature is not present, isFeatureEnabled should return false',
        () async {
      dotenv.testLoad(fileInput: '''''');
      final service = FeatureFlagService();
      await service.initialise();
      expect(
          service.isFeatureEnabled(FeatureFlagService.ragPipelineLevelSelector),
          isFalse);
      expect(service.showRagPipelineLevelSelector, isFalse);
    });
  });
}
