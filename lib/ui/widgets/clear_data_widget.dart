import 'package:flutter/material.dart';
import 'package:rag/ui/views/home/home_viewmodel.dart';

class ClearDataWidget extends StatefulWidget {
  const ClearDataWidget(
    this.viewModel,
    this.leftWidgetTabController, {
    super.key,
  });
  final HomeViewModel viewModel;
  final TabController leftWidgetTabController;
  @override
  State<ClearDataWidget> createState() => _ClearDataWidgetState();
}

class _ClearDataWidgetState extends State<ClearDataWidget> {
  final _expansionTileController = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      controller: _expansionTileController,
      title: Text(
        'Clear Data',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      childrenPadding: const EdgeInsets.all(24),
      children: [
        const Center(child: Text('Permanently delete all data?')),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: widget.viewModel.isKeepSettings,
              onChanged: (value) => widget.viewModel.isKeepSettings = value!,
            ),
            const Text('Keep Settings'),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            if (await widget.viewModel.showClearDataDialog()) {
              await widget.viewModel.deleteAllData();
              widget.leftWidgetTabController.animateTo(0);
            }
            _expansionTileController.collapse();
          },
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Delete'),
        ),
      ],
    );
  }
}
