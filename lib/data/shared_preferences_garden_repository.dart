import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/garden_plant.dart';
import '../models/garden_gallery_entry.dart';
import '../models/garden_task.dart';
import '../models/garden_zone.dart';
import 'garden_repository.dart';

/// Stores the app's JSON snapshot using the platform's key-value storage.
class SharedPreferencesGardenRepository implements GardenRepository {
  SharedPreferencesGardenRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<GardenData?> load({required String userId}) async {
    final raw = await _preferences.getString(_storageKey(userId));
    if (raw == null || raw.isEmpty) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return GardenData(
      zones: (json['zones'] as List? ?? const [])
          .map(
            (item) =>
                GardenZone.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      plants: (json['plants'] as List? ?? const [])
          .map(
            (item) =>
                GardenPlant.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      tasks: (json['tasks'] as List? ?? const [])
          .map(
            (item) =>
                GardenTask.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      galleryEntries: (json['galleryEntries'] as List? ?? const [])
          .map(
            (item) => GardenGalleryEntry.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> save({required String userId, required GardenData data}) async {
    await _preferences.setString(
      _storageKey(userId),
      jsonEncode({
        'zones': data.zones.map((value) => value.toJson()).toList(),
        'plants': data.plants.map((value) => value.toJson()).toList(),
        'tasks': data.tasks.map((value) => value.toJson()).toList(),
        'galleryEntries': data.galleryEntries
            .map((value) => value.toJson())
            .toList(),
      }),
    );
  }

  String _storageKey(String userId) => 'garden_planner.data.v1.$userId';
}
