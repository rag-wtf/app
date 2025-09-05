import 'package:evaluation/src/ui/views/evaluation/evaluation_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class EvaluationView extends StackedView<EvaluationViewModel> {
  const EvaluationView({super.key});

  @override
  Widget builder(
    BuildContext context,
    EvaluationViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation'),
      ),
      body: const Center(
        child: Text('Evaluation View'),
      ),
    );
  }

  @override
  EvaluationViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      EvaluationViewModel();
}
