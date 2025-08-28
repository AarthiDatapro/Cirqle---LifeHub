import 'package:flutter/material.dart';

class ChipsSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onTap;
  const ChipsSuggestions({super.key, required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: suggestions.map((s) {
        return ActionChip(
          label: Text(s),
          onPressed: () => onTap(s),
        );
      }).toList(),
    );
  }
}
