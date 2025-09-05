import 'package:flutter_test/flutter_test.dart';
import 'package:evaluation/src/ui/views/evaluation/evaluation_viewmodel.dart';

void main() {
  group('EvaluationViewModel Tests -', () {
    test('Initialise', () {
      final model = EvaluationViewModel();
      expect(model, isNotNull);
    });
  });
}
