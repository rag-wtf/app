import 'package:flutter/material.dart';

class SettingsExpansionPanel {
  const SettingsExpansionPanel({
    required this.headerText,
    required this.body,
    required this.isExpanded,
  });
  final String headerText;
  final Widget body;
  final bool isExpanded;

  ExpansionPanel build(BuildContext context) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(headerText.toUpperCase()),
        );
      },
      body: body,
      isExpanded: isExpanded,
      canTapOnHeader: true,
    );
  }
}
