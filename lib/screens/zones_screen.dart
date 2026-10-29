import 'package:flutter/material.dart';

import '../core/widgets/garden_add_fab.dart';
import '../data/garden_store.dart';
import '../models/garden_zone.dart';
import 'zones/add_zone.dart';
import 'zones/edit_zone.dart';
import 'zones/zone_details.dart';

const _green = Color(0xFF3F704F);
const _ink = Color(0xFF1E3326);

// Найінтерактивніший екран: мапа, перетягування й зміна розміру зон.
class ZonesScreen extends StatefulWidget {
  const ZonesScreen({super.key});

  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> {
  bool _isMapView = true;
  List<GardenZone> get _zones => GardenStore.instance.zones;

  // Після перетягування шукаємо вільне місце для зон, що перетнулися.
  void _separateOverlappingZones(
    GardenZone movedZone,
    double scale,
    double mapWidth,
    double mapHeight,
  ) {
    final logicalWidth = mapWidth / scale;
    final logicalHeight = mapHeight / scale;

  for (final zone in _zones) {
    if (identical(zone, movedZone)) continue;

    if (_zonesOverlap(zone, movedZone)) {
      final position = _findFreePosition(
        zone,
        logicalWidth,
        mapHeight: logicalHeight,
        ignore: zone,
      );

      if (position != null) {
        zone.left = position.dx;
        zone.top = position.dy;
      }
    }
  }

  setState(() {});
}

bool _zonesOverlap(GardenZone a, GardenZone b) {
  final rectA = Rect.fromLTWH(a.left, a.top, a.width, a.height);
  final rectB = Rect.fromLTWH(b.left, b.top, b.width, b.height);
  return rectA.overlaps(rectB);
}

Offset? _findFreePosition(
  GardenZone zone,
  double mapWidth, {
  required double mapHeight,
  required GardenZone ignore,
}) {
  const step = 24.0;
  final maxLeft = (mapWidth - zone.width).clamp(0.0, mapWidth);

  // Шукаємо найближче вільне місце праворуч, унизу, ліворуч і вгорі.
  for (int radius = 1; radius <= 40; radius++) {
    final candidates = <Offset>[
      Offset(zone.left + step * radius, zone.top),
      Offset(zone.left, zone.top + step * radius),
      Offset(zone.left - step * radius, zone.top),
      Offset(zone.left, zone.top - step * radius),
    ];

    for (final candidate in candidates) {
      final left = candidate.dx.clamp(0.0, maxLeft);
      final maxTop = (mapHeight - zone.height).clamp(0.0, mapHeight);
      final top = candidate.dy.clamp(0.0, maxTop);
      final rect = Rect.fromLTWH(left, top, zone.width, zone.height);

      final overlapsAnother = _zones.any((other) {
        if (identical(other, ignore)) return false;
        return rect.overlaps(
          Rect.fromLTWH(other.left, other.top, other.width, other.height),
        );
      });

      if (!overlapsAnother) return Offset(left, top);
    }
  }

  return null;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        title: const Text(
          'Garden Zones',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 24,
            color: _ink,
          ),
        ),
      ),
      body: _isMapView ? _buildMapView() : _buildListView(),
      floatingActionButton: SizedBox(
  width: MediaQuery.sizeOf(context).width - 32,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      FloatingActionButton(
        heroTag: 'toggle_zone_view',
        backgroundColor: const Color(0xFFE89A6C),
        foregroundColor: Colors.white,
        onPressed: () => setState(() => _isMapView = !_isMapView),
        child: Icon(
          _isMapView ? Icons.format_list_bulleted : Icons.map_outlined,
        ),
      ),
      GardenAddFab(
        heroTag: 'add_zone',
        tooltip: 'Add zone',
        onPressed: _addZone,
      ),
    ],
  ),
),
floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMapView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 360).clamp(0.72, 1.0);
        final mapWidth = constraints.maxWidth;
        final mapHeight = constraints.maxHeight;

        return Container(
          color: const Color(0xFFE4E7DF),
          child: SingleChildScrollView(
            child: SizedBox(
              width: mapWidth,
              height: mapHeight,
              child: CustomPaint(
                painter: _DotGridPainter(),
                child: Stack(
                  children: _zones
                      .map((zone) => _buildZoneTile(
                            zone,
                            scale,
                            mapWidth,
                            mapHeight,
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildZoneTile(
    GardenZone zone,
    double scale,
    double mapWidth,
    double mapHeight,
  ) {
    final left = (zone.left * scale).clamp(
      4.0,
      (mapWidth - zone.width * scale - 4).clamp(4.0, mapWidth),
    );

    return Positioned(
      left: left,
      top: zone.top * scale,
      width: zone.width * scale,
      height: zone.height * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _showZoneDetails(zone),
              onPanUpdate: (details) {
                setState(() {
                  final maxLeft =
                      (mapWidth / scale - zone.width).clamp(0.0, 1200.0);
                  final maxTop =
                      (mapHeight / scale - zone.height).clamp(0.0, 1200.0);
                  zone.left =
                      (zone.left + details.delta.dx / scale).clamp(0.0, maxLeft);
                  zone.top =
                      (zone.top + details.delta.dy / scale).clamp(0.0, maxTop);
                });
              },
              onPanEnd: (_) => _separateOverlappingZones(
                zone,
                scale,
                mapWidth,
                mapHeight,
              ),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: zone.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black26),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          zone.soilType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: _ink,
                        child: Text(
                          '${zone.plants.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -7,
            bottom: -7,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final maxWidth =
                      (mapWidth / scale - zone.left).clamp(80.0, 340.0);
                  final maxHeight =
                      (mapHeight / scale - zone.top).clamp(65.0, 500.0);
                  zone.width =
                      (zone.width + details.delta.dx / scale).clamp(80.0, maxWidth);
                  zone.height =
                      (zone.height + details.delta.dy / scale).clamp(65.0, maxHeight);
                });
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: _green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.open_in_full,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _zones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final zone = _zones[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showZoneDetails(zone),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE3E7E2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        zone.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: zone.isActive ? _green : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      zone.isActive ? 'Active' : 'Dormant',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  children: [
                    const Icon(Icons.terrain_outlined, size: 15),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        zone.soilType,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const Icon(Icons.straighten, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${zone.areaSqM.toStringAsFixed(0)} sq m',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addZone() async {
    final zone = await showModalBottomSheet<GardenZone>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF9F9F7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddZoneSheet(),
    );

    if (zone != null && mounted) {
      setState(() => GardenStore.instance.addZone(zone));
    }
  }

  Future<void> _showZoneDetails(GardenZone zone) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => ZoneDetailsSheet(
        zone: zone,
        onEdit: () async {
          Navigator.pop(sheetContext);
          await _editZone(zone);
        },
      ),
    );
  }

  Future<void> _editZone(GardenZone zone) async {
    final updated = await showModalBottomSheet<GardenZone>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF9F9F7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditZoneSheet(zone: zone),
    );

    if (updated != null && mounted) {
      setState(() {
        GardenStore.instance.replaceZone(updated);
      });
    }
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.10)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 20) {
      for (double y = 0; y < size.height; y += 20) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
