import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evaluation/src/ui/views/evaluation/evaluation_view.dart';

void main() {
  testWidgets('EvaluationView has a title and a body',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: EvaluationView()));
    expect(find.text('Evaluation'), findsOneWidget);
    expect(find.text('Evaluation View'), findsOneWidget);
  });
}
