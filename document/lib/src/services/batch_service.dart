import 'dart:math';

import 'package:document/src/app/app.logger.dart';

class BatchService {
  final _log = getLogger('BatchService');

  Future<List<TResult>> execute<TInput, TResult>(
    List<TInput> values,
    int batchSize,
    Future<List<TResult>> Function(
      List<TInput> values,
    ) batchFunction,
  ) async {
    final numBatches = (values.length / batchSize).ceil();
    final items = List<TResult>.empty(growable: true);

    for (var i = 0; i < numBatches; i++) {
      // Get the start and end indices of the current batch
      final start = i * batchSize;
      final end = min(start + batchSize, values.length);

      _log.d('start $start, end $end');

      // Get the current batch of items
      final batch = values.sublist(start, end);
      items.addAll(await batchFunction(batch));
    }

    return items;
  }
}
