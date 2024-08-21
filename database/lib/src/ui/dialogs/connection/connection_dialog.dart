// ignore_for_file: strict_raw_type, inference_failure_on_function_return_type

import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/ui/common/ui_helpers.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog.form.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog_model.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog_validators.dart';
import 'package:database/src/ui/widgets/common/input_field.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@FormView(
  fields: [
    FormTextField(
      name: 'name',
      validator: ConnectionDialogValidators.validateConnectionName,
    ),
    FormTextField(name: 'addressPort'),
    FormTextField(
      name: 'namespace',
      validator: ConnectionDialogValidators.validateNamespace,
    ),
    FormTextField(
      name: 'database',
      validator: ConnectionDialogValidators.validateDatabase,
    ),
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
    final showClearTextButton = viewModel.connectionKeySelected !=
        ConnectionDialogModel.newConnectionKey;
    final showDeleteButton = showClearTextButton;
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
              request.title ?? 'Hello Stacked Dialog!!',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            if (request.description != null) ...[
              verticalSpaceTiny,
              Text(
                request.description!,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                maxLines: 3,
                softWrap: true,
              ),
            ],
            verticalSpaceTiny,
            if (viewModel
                .hasErrorForKey(ConnectionDialogModel.connectErrorKey)) ...[
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  border:
                      Border.all(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel
                            .error(ConnectionDialogModel.connectErrorKey)
                            .toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpaceTiny,
            ],
            Expanded(
              child: ListView(
                children: [
                  InputField(
                    hintText: 'New connection',
                    controller: nameController,
                    errorText: viewModel.nameValidationMessage,
                    // REF: https://gist.github.com/slightfoot/f0b753606c97d8a2c06659803c12d858
                    suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (String connectionNameKey) async {
                        final connectionKey = connectionNameKey ==
                                ConnectionDialogModel.newConnectionKey
                            ? connectionNameKey
                            : connectionNameKey.substring(
                                0,
                                connectionNameKey.indexOf('_'),
                              );
                        await viewModel.onConnectionSelected(connectionKey);
                      },
                      itemBuilder: (BuildContext context) {
                        return viewModel.connectionNames
                            .map<PopupMenuItem<String>>(
                                (ConnectionSetting name) {
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
                        width: 130,
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
                              child: Text('HTTP'),
                            ),
                            DropdownMenuItem(
                              value: 'https',
                              child: Text('HTTPS'),
                            ),
                            DropdownMenuItem(
                              value: 'ws',
                              child: Text('WS'),
                            ),
                            DropdownMenuItem(
                              value: 'wss',
                              child: Text('WSS'),
                            ),
                            DropdownMenuItem(
                              value: 'mem',
                              child: Text('Memory'),
                            ),
                            DropdownMenuItem(
                              value: 'indxdb',
                              child: Text('IndexedDB'),
                            ),
                          ],
                          onChanged: (value) {
                            viewModel.protocol = value!;
                            if (viewModel.protocol == 'mem' ||
                                viewModel.protocol == 'indxdb') {
                              addressPortController.clear();
                            }
                          },
                        ),
                      ),
                      horizontalSpaceTiny,
                      Expanded(
                        child: InputField(
                          enabled: viewModel.protocol != 'mem',
                          hintText: getAddressPortHintText(viewModel.protocol),
                          controller: addressPortController,
                          errorText: viewModel.addressPortValidationMessage,
                          showClearTextButton: showClearTextButton,
                        ),
                      ),
                    ],
                  ),
                  verticalSpaceTiny,
                  InputField(
                    labelText: 'Namespace',
                    controller: namespaceController,
                    errorText: viewModel.namespaceValidationMessage,
                    showClearTextButton: showClearTextButton,
                  ),
                  verticalSpaceTiny,
                  InputField(
                    labelText: 'Database',
                    controller: databaseController,
                    errorText: viewModel.databaseValidationMessage,
                    showClearTextButton: showClearTextButton,
                  ),
                  if (viewModel.protocol != 'mem' &&
                      viewModel.protocol != 'indxdb') ...[
                    verticalSpaceTiny,
                    InputField(
                      labelText: 'Username',
                      controller: usernameController,
                      errorText: viewModel.usernameValidationMessage,
                      showClearTextButton: showClearTextButton,
                    ),
                    verticalSpaceTiny,
                    InputField(
                      labelText: 'Password',
                      controller: passwordController,
                      errorText: viewModel.passwordValidationMessage,
                      textInputType: TextInputType.none,
                    ),
                  ],
                  verticalSpaceTiny,
                  SwitchListTile(
                    title: Text(
                      'Auto-Connect',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: viewModel.autoConnect,
                    onChanged: (value) {
                      viewModel.autoConnect = value;
                    },
                  ),
                ],
              ),
            ),
            verticalSpaceTiny,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => completer(DialogResponse()),
                  child: const Text('Close'),
                ),
                Row(
                  children: [
                    if (showDeleteButton)
                      ElevatedButton(
                        onPressed: viewModel.delete,
                        child: const Text('Delete'),
                      ),
                    horizontalSpaceTiny,
                    ElevatedButton(
                      onPressed: () async => completer(
                        DialogResponse(
                          confirmed: await viewModel.connectAndSave(),
                        ),
                      ),
                      child: const Text('Connect'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getAddressPortHintText(String protocol) {
    var hintText = 'address:port';
    if (protocol == 'mem') {
      hintText = 'Not applicable';
    } else if (protocol == 'indxdb') {
      hintText = 'database_name';
    }
    return hintText;
  }

  @override
  ConnectionDialogModel viewModelBuilder(BuildContext context) =>
      ConnectionDialogModel();

  @override
  Future<void> onViewModelReady(ConnectionDialogModel viewModel) async {
    await viewModel.initialise();
    syncFormWithViewModel(viewModel);
  }

  @override
  void onDispose(ConnectionDialogModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }
}
