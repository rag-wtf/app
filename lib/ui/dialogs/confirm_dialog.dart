import 'package:flutter/material.dart';
import 'package:rag/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ConfirmDialog extends StackedView<BaseViewModel> {
  const ConfirmDialog({
    required this.request,
    required this.completer,
    super.key,
  });

  final DialogRequest<void> request;
  final void Function(DialogResponse<void>) completer;

  @override
  Widget builder(
    BuildContext context,
    BaseViewModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.title ?? 'Confirm Dialog',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (request.description != null) ...[
              verticalSpaceMedium,
              Text(
                request.description!,
                style: const TextStyle(
                  fontSize: 14,
                ),
                maxLines: 3,
                softWrap: true,
              ),
            ],
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    completer(DialogResponse());
                  },
                  child: const Text('No'),
                ),
                horizontalSpaceSmall,
                ElevatedButton(
                  onPressed: () async {
                    completer(DialogResponse(confirmed: true));
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  BaseViewModel viewModelBuilder(BuildContext context) {
    return BaseViewModel();
  }
}
