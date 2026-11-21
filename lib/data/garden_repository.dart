import '../models/garden_plant.dart';
import '../models/garden_gallery_entry.dart';
import '../models/garden_task.dart';
import '../models/garden_zone.dart';

class GardenData {
  const GardenData({
    required this.zones,
    required this.plants,
    required this.tasks,
    this.galleryEntries = const [],
  });

  final List<GardenZone> zones;
  final List<GardenPlant> plants;
  final List<GardenTask> tasks;
  final List<GardenGalleryEntry> galleryEntries;
}

/// Persistence contract for all garden data used by the application.
abstract interface class GardenRepository {
  Future<GardenData?> load({required String userId});
  Future<void> save({required String userId, required GardenData data});
}
