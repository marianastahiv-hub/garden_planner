import 'package:flutter/material.dart';

/// Показує вибір готового зображення з assets, оголошених у pubspec.yaml.
class ProjectAssetPicker {
  ProjectAssetPicker._();

  static const assets = <String>[
    'images/garden_1.jpg',
    'images/basil_growth.jpg',
    'images/basil_healthy.jpg',
    'images/tomato_growth.jpg',
  ];

  static Future<String?> show(
    BuildContext context, {
    String? selectedAsset,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Choose a project image',
                style: TextStyle(fontSize: 18),
              ),
            ),
            ...assets.map(
              (asset) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    asset,
                    width: 56,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(asset.split('/').last),
                trailing: asset == selectedAsset
                    ? const Icon(Icons.check, color: Color(0xFF3F704F))
                    : null,
                onTap: () => Navigator.pop(context, asset),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
