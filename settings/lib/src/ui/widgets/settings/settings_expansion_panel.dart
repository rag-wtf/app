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
          title: Text(
            headerText,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      },
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: body,
      ),
      backgroundColor: Colors.transparent,
      isExpanded: isExpanded,
      canTapOnHeader: true,
    );
  }
}
