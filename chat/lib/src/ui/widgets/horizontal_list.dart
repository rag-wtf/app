import 'dart:ui';

import 'package:chat/src/ui/widgets/markdown_widget.dart';
import 'package:document/document.dart';
import 'package:flutter/material.dart';
import 'package:scroll_indicator/scroll_indicator.dart';

class HorizontalList extends StatelessWidget {
  HorizontalList(this.embeddings, this.showDialogFunction, {super.key});
  final List<Embedding>? embeddings;
  final _scrollController = ScrollController();
  static const itemMargin = 4.0;
  static const itemPadding = 8.0;
  static const itemWidth = 200.0 + (itemMargin * 2) + (itemPadding * 2);
  final Future<void> Function(Embedding embedding) showDialogFunction;

  @override
  Widget build(BuildContext context) {
    if (embeddings != null && embeddings!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sources:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            color: Colors.transparent,
            height: 95,
            // REF: https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag#copy-and-modify-existing-scrollbehavior
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: embeddings!.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    child: Container(
                      margin: index == 0
                          ? const EdgeInsets.only(right: itemMargin)
                          : const EdgeInsets.symmetric(horizontal: itemMargin),
                      padding:
                          const EdgeInsets.symmetric(horizontal: itemPadding),
                      width: itemWidth,
                      color: Theme.of(context).colorScheme.surface,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          scrollbars: false,
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                        child: SingleChildScrollView(
                          child: MarkdownWidget(
                            embeddings![index].content,
                            selectable: false,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async => showDialogFunction(embeddings![index]),
                  );
                },
              ),
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < itemWidth * embeddings!.length) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ScrollIndicator(
                        scrollController: _scrollController,
                        width: 30,
                        height: 5,
                        indicatorWidth: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                        ),
                        indicatorDecoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
