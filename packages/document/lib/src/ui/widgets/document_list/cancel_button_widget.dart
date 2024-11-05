import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CancelButtonWidget extends StatelessWidget {
  const CancelButtonWidget(this.cancelToken, {super.key});
  final CancelToken cancelToken;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.stop_circle),
      onPressed: cancelToken.cancel,
    );
  }
}
