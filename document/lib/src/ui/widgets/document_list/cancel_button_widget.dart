import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CancelButtonWidget extends StatelessWidget {
  const CancelButtonWidget(this.cancelToken, {super.key});
  final CancelToken cancelToken;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.cancel),
        onPressed: cancelToken.cancel,
      ),
    );
  }
}
