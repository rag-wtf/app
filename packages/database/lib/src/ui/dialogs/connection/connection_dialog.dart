// ignore_for_file: strict_raw_type, inference_failure_on_function_return_type

import 'package:database/src/constants.dart';
import 'package:database/src/services/connection_setting.dart';
import 'package:database/src/ui/common/ui_helpers.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog.form.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog_model.dart';
import 'package:database/src/ui/dialogs/connection/connection_dialog_validators.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:ui/ui.dart';

@FormView(
  fields: [
    FormTextField(
      name: 'name',
      initialValue: defaultName,
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
    final isDense = MediaQuery.sizeOf(context).width < 600;
    final notMemAndIndxDB =
        viewModel.protocol != 'mem' && viewModel.protocol != 'indxdb';
    final checkboxLabel =
        notMemAndIndxDB ? 'Remember password' : 'Connect automatically';
    return AdaptiveDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      maxWidth: dialogMaxWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.title ?? 'Connection',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            verticalSpaceTiny,
            Text(
              request.description!,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
              softWrap: true,
            ),
            Link(
              url: Uri.parse(surrealReferralUrl),
              text: 'Start for free today!',
              onUrlLaunched: viewModel.analyticsFacade.trackUrlOpened,
            ),
            verticalSpaceSmall,
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
            if (viewModel.isBusy)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    InputFieldDropdown<ConnectionSetting>(
                      isDense: isDense,
                      hintText: 'Name',
                      controller: nameController,
                      errorText: viewModel.nameValidationMessage,
                      isLoading: viewModel.isBusy,
                      items: viewModel.connectionNames,
                      getItemValue: (ConnectionSetting name) => name.key,
                      getItemDisplayText: (ConnectionSetting name) =>
                          name.value,
                      onSelected: (ConnectionSetting selectedName) async {
                        final connectionKey = selectedName.key ==
                                ConnectionDialogModel.newConnectionKey
                            ? selectedName.key
                            : selectedName.key
                                .substring(0, selectedName.key.indexOf('_'));
                        await viewModel.onConnectionSelected(connectionKey);
                      },
                    ),
                    verticalSpaceTiny,
                    InputField(
                      isDense: isDense,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 115,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(left: 12),
                              border: InputBorder.none,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
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
                                usernameController.clear();
                                passwordController.clear();
                              }
                            },
                          ),
                        ),
                      ),
                      readOnly: viewModel.protocol == 'mem',
                      hintText: getAddressPortHintText(viewModel.protocol),
                      controller: addressPortController,
                      errorText: viewModel.addressPortValidationMessage,
                      showClearTextButton: showClearTextButton,
                    ),
                    verticalSpaceTiny,
                    InputField(
                      isDense: isDense,
                      labelText: 'Namespace',
                      controller: namespaceController,
                      errorText: viewModel.namespaceValidationMessage,
                      showClearTextButton: showClearTextButton,
                    ),
                    verticalSpaceTiny,
                    InputField(
                      isDense: isDense,
                      labelText: 'Database',
                      controller: databaseController,
                      errorText: viewModel.databaseValidationMessage,
                      showClearTextButton: showClearTextButton,
                    ),
                    if (notMemAndIndxDB) ...[
                      verticalSpaceTiny,
                      InputField(
                        isDense: isDense,
                        labelText: 'Username',
                        controller: usernameController,
                        errorText: viewModel.usernameValidationMessage,
                        showClearTextButton: showClearTextButton,
                      ),
                      verticalSpaceTiny,
                      PasswordField(
                        isDense: isDense,
                        labelText: 'Password',
                        controller: passwordController,
                        errorText: viewModel.passwordValidationMessage,
                      ),
                    ],
                    verticalSpaceTiny,
                    CheckboxOrSwitchListTile(
                      title: Text(
                        checkboxLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: viewModel.autoConnect,
                      onChanged: (value) {
                        viewModel.autoConnect = value;
                      },
                    ),
                    CheckboxOrSwitchListTile(
                      title: Text(
                        'Enabled anonymous reporting of crash and event data',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: viewModel.analyticsEnabled,
                      onChanged: (value) {
                        viewModel.analyticsEnabled = value;
                      },
                    ),
                  ],
                ),
              ),
            verticalSpaceSmall,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showDeleteButton) ...[
                  ElevatedButton(
                    onPressed: viewModel.delete,
                    child: const Text('Delete'),
                  ),
                  horizontalSpaceSmall,
                ],
                ElevatedButton(
                  onPressed: viewModel.hasAnyValidationMessage
                      ? null
                      : () async {
                          if (viewModel.validate()) {
                            return completer(
                              DialogResponse<bool>(
                                confirmed: await viewModel.connectAndSave(),
                                data: viewModel.analyticsEnabled,
                              ),
                            );
                          }
                        },
                  child: const Text('Login'),
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
