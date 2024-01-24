import 'dart:ui';

import 'package:document/document.dart';
import 'package:flutter/material.dart';

class HorizontalList extends StatelessWidget {
  const HorizontalList(this.embeddings, {super.key});
  final List<Embedding>? embeddings;

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
            height: 85,
            // REF: https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag#copy-and-modify-existing-scrollbehavior
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: embeddings!.length,
                itemBuilder: (BuildContext content, int index) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(8),
                    width: 200,
                    child: Text(
                      embeddings![index].content,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      softWrap: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
