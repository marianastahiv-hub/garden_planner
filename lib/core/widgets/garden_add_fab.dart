import 'package:flutter/material.dart';

/// Спільна кнопка «+», щоб вигляд і поведінка додавання були однаковими.
class GardenAddFab extends StatelessWidget {
  const GardenAddFab({
    super.key,
    required this.heroTag,
    required this.onPressed,
    this.tooltip = 'Add',
  });

  final String heroTag;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      tooltip: tooltip,
      backgroundColor: const Color(0xFF3F704F),
      foregroundColor: Colors.white,
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}
