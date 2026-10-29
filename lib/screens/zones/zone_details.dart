import 'package:flutter/material.dart';

import '../../models/garden_zone.dart';

// Короткий перегляд інформації про зону з переходом до редагування.
class ZoneDetailsSheet extends StatelessWidget {
  const ZoneDetailsSheet({
    super.key,
    required this.zone,
    required this.onEdit,
  });

  final GardenZone zone;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE4DD),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    zone.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF294832),
                    ),
                  ),
                ),
                Chip(
                  label: Text(zone.isActive ? 'Active' : 'Dormant'),
                  backgroundColor: const Color(0xFFE2F0E4),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _infoChip(Icons.terrain_outlined, zone.soilType),
                _infoChip(Icons.straighten, '${zone.areaSqM.toStringAsFixed(0)} sq m'),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Plants Growing Here',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (zone.plants.isEmpty)
              const Text(
                'No plants added yet',
                style: TextStyle(color: Colors.black54),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: zone.plants
                    .map((plant) => Chip(
                          label: Text(plant),
                          backgroundColor: const Color(0xFFE3EEDF),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    child: const Text('Edit Block'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3F704F),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) => Chip(
        avatar: Icon(icon, size: 15),
        label: Text(text),
        visualDensity: VisualDensity.compact,
        backgroundColor: const Color(0xFFF3F4F0),
      );
}
