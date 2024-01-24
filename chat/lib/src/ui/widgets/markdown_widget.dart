import 'package:chat/src/ui/widgets/code_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MarkdownWidget extends StatelessWidget {
  const MarkdownWidget(
    this.data, {
    super.key,
    this.selectable = true,
    this.textStyle,
  });
  final String data;
  final bool selectable;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config =
        isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
    const codeWrapper = CodeWrapperWidget.new;
    return MarkdownBlock(
      selectable: selectable,
      data: data,
      config: config.copy(
        configs: [
          if (isDark)
            PreConfig.darkConfig.copy(
              wrapper: codeWrapper,
              textStyle: textStyle,
            )
          else
            const PreConfig().copy(
              wrapper: codeWrapper,
              textStyle: textStyle,
            ),
        ],
      ),
    );
  }
}
