import 'package:flutter/material.dart';

import '../models/garden_plant.dart';
import '../models/garden_task.dart';
import '../models/garden_zone.dart';

class GardenStore extends ChangeNotifier {
  GardenStore._() {
    final today = _dateOnly(DateTime.now());
    zones.addAll([
      _zone('1', 'Greenhouse', 'Sandy Loam', 240, const Color(0xFFA8C3A0), 16, 16, 145, 120,
          plants: ['Sweet Basil', 'Mint', 'Rosemary', 'Dill', 'Chives']),
      _zone('2', 'Raised Beds', 'Rich Compost', 120, const Color(0xFFE3D99A), 174, 16, 145, 120,
          plants: ['Parsley', 'Thyme']),
      _zone('3', 'Front Yard', 'Mixed Soil', 80, const Color(0xFFD2D5CC), 16, 152, 145, 100,
          plants: ['Rosemary']),
      _zone('4', 'Orchard', 'Clay Silt', 800, const Color(0xFFBDD8C1), 174, 152, 145, 170,
          plants: ['Thyme'], isActive: false),
      _zone('5', 'Indoor Loft', 'Potting Mix', 35, const Color(0xFFBFD0D5), 16, 262, 95, 100,
          plants: ['Mint']),
      _zone('6', 'Herb Garden', 'Sandy Loam', 60, const Color(0xFFE8D9A8), 122, 262, 95, 100,
          plants: ['Sweet Basil', 'Dill']),
      _zone('7', 'Compost', 'Organic', 25, const Color(0xFFCFC6AD), 228, 262, 95, 100),
    ]);
    plants.addAll([
      GardenPlant(id: '1', name: 'Sweet Basil', zone: 'Greenhouse', description: 'A fragrant herb growing well in a sunny spot.', plantingDate: 'September 17, 2026', wateringSchedule: 'Every 2 days (Morning)'),
      GardenPlant(id: '2', name: 'Heritage Tomato', zone: 'Raised Beds', imageAsset: 'images/tomato_growth.jpg', description: 'Looking healthy — new leaves sprouting on each side.', plantingDate: 'April 12, 2026', wateringSchedule: 'Every 2 days (Morning)'),
      GardenPlant(id: '3', name: 'French Lavender', zone: 'Front Yard', description: 'A flowering plant that enjoys plenty of sun.', plantingDate: 'May 20, 2026', wateringSchedule: 'Every 4 days'),
      GardenPlant(id: '4', name: 'Fiddle Leaf Fig', zone: 'Indoor Loft', description: 'A leafy indoor plant. Keep it near indirect light.', plantingDate: 'June 3, 2026', wateringSchedule: 'Once a week'),
    ]);
    tasks.addAll([
      GardenTask(id: 'sample-pruning', title: 'Pruning — Roses', zone: 'Front Yard Plot', plant: 'Rose Bushes', dueDate: today, isCompleted: true),
      GardenTask(id: 'sample-watering', title: 'Watering — Greenhouse', zone: 'Herb Sector', plant: 'Sweet Basil', dueDate: today),
      GardenTask(id: 'sample-fertilize', title: 'Fertilization — Orchard', zone: 'Citrus Grove', plant: 'Citrus Trees', dueDate: today.add(const Duration(days: 2)), priority: TaskPriority.high),
    ]);
  }

  static final GardenStore instance = GardenStore._();
  final List<GardenZone> zones = [];
  final List<GardenPlant> plants = [];
  final List<GardenTask> tasks = [];

  void changed() => notifyListeners();
  void addZone(GardenZone value) { zones.add(value); notifyListeners(); }
  void replaceZone(GardenZone value) { final i = zones.indexWhere((item) => item.id == value.id); if (i >= 0) zones[i] = value; notifyListeners(); }
  void addPlant(GardenPlant value) { plants.add(value); notifyListeners(); }
  void addTask(GardenTask value) { tasks.add(value); notifyListeners(); }
  void replaceTask(GardenTask value) { final i = tasks.indexWhere((item) => item.id == value.id); if (i >= 0) tasks[i] = value; notifyListeners(); }
  void removeTask(String id) { tasks.removeWhere((item) => item.id == id); notifyListeners(); }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static GardenZone _zone(String id, String name, String soil, double area, Color color,
      double left, double top, double width, double height,
      {List<String> plants = const [], bool isActive = true}) => GardenZone(
        id: id, name: name, soilType: soil, areaSqM: area, color: color,
        left: left, top: top, width: width, height: height,
        plants: plants, isActive: isActive,
      );
}
