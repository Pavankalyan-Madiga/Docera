import 'package:flutter/material.dart';

import '../../models/tool_model.dart';
import 'tool_card.dart';

class ToolSection extends StatelessWidget {
  const ToolSection({
    super.key,
    required this.title,
    required this.tools,
  });

  final String title;
  final List<ToolModel> tools;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF101631),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tools.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) {
            return ToolCard(
              tool: tools[index],
            );
          },
        ),
      ],
    );
  }
}