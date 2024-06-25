// ignore_for_file: strict_raw_type, inference_failure_on_function_return_type

import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/ui/common/app_colors.dart';
import 'package:database/src/ui/common/ui_helpers.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog.form.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog_model.dart';
import 'package:database/src/ui/widgets/common/input_field.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@FormView(
  fields: [
    FormTextField(name: 'name'),
    FormTextField(name: 'addressPort'),
    FormTextField(name: 'namespace'),
    FormTextField(name: 'database'),
    FormTextField(name: 'username'),
    FormTextField(name: 'password'),
  ],
)
class ConnectionDialog extends StackedView<ConnectionDialogModel>
    with $ConnectionDialog {
  const ConnectionDialog({
    required this.request,
    required this.completer,
    super.key,
  });
  final DialogRequest request;
  final Function(DialogResponse) completer;

  @override
  Widget builder(
    BuildContext context,
    ConnectionDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.title ?? 'Hello Stacked Dialog!!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (request.description != null) ...[
              verticalSpaceTiny,
              Text(
                request.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: kcMediumGrey,
                ),
                maxLines: 3,
                softWrap: true,
              ),
            ],
            verticalSpaceTiny,
            if (viewModel.hasErrorForKey(ConnectionDialogModel.connectErrorKey))
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50], // Light red background color
                    border: Border.all(color: Colors.red), // Red border color
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel
                              .error(ConnectionDialogModel.connectErrorKey)
                              .toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            InputField(
              hintText: 'New connection',
              controller: nameController,
              // REF: https://gist.github.com/slightfoot/f0b753606c97d8a2c06659803c12d858
              suffixIcon: PopupMenuButton<String>(
                icon: const Icon(Icons.arrow_drop_down),
                onSelected: (String value) {
                  nameController.text = value;
                },
                itemBuilder: (BuildContext context) {
                  return viewModel.connectionNames
                      .map<PopupMenuItem<String>>((ConnectionSetting name) {
                    return PopupMenuItem(
                      value: name.key,
                      child: Text(name.value),
                    );
                  }).toList();
                },
              ),
            ),
            verticalSpaceTiny,
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: viewModel.protocol,
                    items: const [
                      DropdownMenuItem(
                        value: 'http',
                        child: Text('http'),
                      ),
                      DropdownMenuItem(
                        value: 'https',
                        child: Text('https'),
                      ),
                      DropdownMenuItem(
                        value: 'ws',
                        child: Text('ws'),
                      ),
                      DropdownMenuItem(
                        value: 'wss',
                        child: Text('wss'),
                      ),
                    ],
                    onChanged: (value) {
                      viewModel.protocol = value!;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputField(
                    hintText: 'address:port',
                    controller: addressPortController,
                  ),
                ),
              ],
            ),
            verticalSpaceTiny,
            InputField(
              labelText: 'Namespace',
              controller: namespaceController,
            ),
            verticalSpaceTiny,
            InputField(
              labelText: 'Database',
              controller: databaseController,
            ),
            verticalSpaceTiny,
            InputField(
              labelText: 'Username',
              controller: usernameController,
            ),
            verticalSpaceTiny,
            InputField(
              labelText: 'Password',
              controller: passwordController,
              textInputType: TextInputType.none,
            ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => completer(DialogResponse()),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () async => completer(
                    DialogResponse(confirmed: await viewModel.connectAndSave()),
                  ),
                  child: const Text('Connect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  ConnectionDialogModel viewModelBuilder(BuildContext context) =>
      ConnectionDialogModel();

  @override
  Future<void> onViewModelReady(ConnectionDialogModel viewModel) async {
    await viewModel.initialise();
    syncFormWithViewModel(viewModel);
  }
}
