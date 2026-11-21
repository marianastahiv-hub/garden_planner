import 'package:flutter/material.dart';

import '../models/garden_plant.dart';
import '../models/garden_gallery_entry.dart';
import '../models/garden_task.dart';
import '../models/garden_zone.dart';
import 'garden_repository.dart';

/// Demo content used only when the device has no saved garden snapshot yet.
class GardenSeedData {
  const GardenSeedData._();

  static GardenData create() {
    final today = DateTime.now();
    return GardenData(
      zones: [
        _zone(
          '1',
          'Greenhouse',
          'Sandy Loam',
          240,
          const Color(0xFFA8C3A0),
          16,
          16,
          145,
          120,
          plants: ['Sweet Basil', 'Mint', 'Rosemary', 'Dill', 'Chives'],
        ),
        _zone(
          '2',
          'Raised Beds',
          'Rich Compost',
          120,
          const Color(0xFFE3D99A),
          174,
          16,
          145,
          120,
          plants: ['Parsley', 'Thyme'],
        ),
        _zone(
          '3',
          'Front Yard',
          'Mixed Soil',
          80,
          const Color(0xFFD2D5CC),
          16,
          152,
          145,
          100,
          plants: ['Rosemary'],
        ),
        _zone(
          '4',
          'Orchard',
          'Clay Silt',
          800,
          const Color(0xFFBDD8C1),
          174,
          152,
          145,
          100,
          plants: ['Thyme'],
          isActive: false,
        ),
        _zone(
          '5',
          'Indoor Loft',
          'Potting Mix',
          35,
          const Color(0xFFBFD0D5),
          16,
          262,
          95,
          100,
          plants: ['Mint'],
        ),
        _zone(
          '6',
          'Herb Garden',
          'Sandy Loam',
          60,
          const Color(0xFFE8D9A8),
          122,
          262,
          95,
          100,
          plants: ['Sweet Basil', 'Dill'],
        ),
        _zone(
          '7',
          'Compost',
          'Organic',
          25,
          const Color(0xFFCFC6AD),
          228,
          262,
          95,
          100,
        ),
      ],
      plants: [
        GardenPlant(
          id: '1',
          name: 'Sweet Basil',
          zone: 'Greenhouse',
          description: 'A fragrant herb growing well in a sunny spot.',
          plantingDate: 'September 17, 2026',
          wateringSchedule: 'Every 2 days (Morning)',
        ),
        GardenPlant(
          id: '2',
          name: 'Heritage Tomato',
          zone: 'Raised Beds',
          imageAsset: 'images/tomato_growth.jpg',
          description: 'Looking healthy — new leaves sprouting on each side.',
          plantingDate: 'April 12, 2026',
          wateringSchedule: 'Every 2 days (Morning)',
        ),
        GardenPlant(
          id: '3',
          name: 'French Lavender',
          zone: 'Front Yard',
          description: 'A flowering plant that enjoys plenty of sun.',
          plantingDate: 'May 20, 2026',
          wateringSchedule: 'Every 4 days',
        ),
        GardenPlant(
          id: '4',
          name: 'Fiddle Leaf Fig',
          zone: 'Indoor Loft',
          description: 'A leafy indoor plant. Keep it near indirect light.',
          plantingDate: 'June 3, 2026',
          wateringSchedule: 'Once a week',
        ),
      ],
      tasks: [
        GardenTask(
          id: 'sample-pruning',
          title: 'Pruning — Roses',
          zone: 'Front Yard Plot',
          plant: 'Rose Bushes',
          dueDate: DateTime(today.year, today.month, today.day),
          isCompleted: true,
        ),
        GardenTask(
          id: 'sample-watering',
          title: 'Watering — Greenhouse',
          zone: 'Herb Sector',
          plant: 'Sweet Basil',
          dueDate: DateTime(today.year, today.month, today.day),
        ),
        GardenTask(
          id: 'sample-fertilize',
          title: 'Fertilization — Orchard',
          zone: 'Citrus Grove',
          plant: 'Citrus Trees',
          dueDate: DateTime(
            today.year,
            today.month,
            today.day,
          ).add(const Duration(days: 2)),
          priority: TaskPriority.high,
        ),
      ],
      galleryEntries: [
        GardenGalleryEntry(
          id: 'sample-basil-latest',
          plantName: 'Sweet Basil',
          date: DateTime(today.year, today.month, today.day),
          imageAsset: 'images/basil_healthy.jpg',
          note: 'New leaves are sprouting.',
        ),
        GardenGalleryEntry(
          id: 'sample-basil-earlier',
          plantName: 'Sweet Basil',
          date: DateTime(
            today.year,
            today.month,
            today.day,
          ).subtract(const Duration(days: 14)),
          imageAsset: 'images/basil_growth.jpg',
          note: 'The leaves are growing well.',
        ),
        GardenGalleryEntry(
          id: 'sample-tomato-latest',
          plantName: 'Heritage Tomato',
          date: DateTime(
            today.year,
            today.month,
            today.day,
          ).subtract(const Duration(days: 2)),
          imageAsset: 'images/tomato_growth.jpg',
          note: 'The tomatoes are starting to ripen.',
        ),
        GardenGalleryEntry(
          id: 'sample-lavender',
          plantName: 'French Lavender',
          date: DateTime(
            today.year,
            today.month,
            today.day,
          ).subtract(const Duration(days: 7)),
          imageAsset: 'images/garden_1.jpg',
          note: 'Flower buds are beginning to open.',
        ),
      ],
    );
  }

  static GardenZone _zone(
    String id,
    String name,
    String soil,
    double area,
    Color color,
    double left,
    double top,
    double width,
    double height, {
    List<String> plants = const [],
    bool isActive = true,
  }) => GardenZone(
    id: id,
    name: name,
    soilType: soil,
    areaSqM: area,
    color: color,
    left: left,
    top: top,
    width: width,
    height: height,
    plants: plants,
    isActive: isActive,
  );
}
