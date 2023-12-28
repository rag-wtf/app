import 'package:flutter/material.dart';

class CancelButtonWidget extends StatelessWidget {
  const CancelButtonWidget(this.cancel, {super.key});
  final void Function() cancel;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.cancel),
        onPressed: cancel,
      ),
    );
  }
}
