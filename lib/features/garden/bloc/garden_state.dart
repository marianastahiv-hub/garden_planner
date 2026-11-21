import '../../../models/garden_plant.dart';
import '../../../models/garden_gallery_entry.dart';
import '../../../models/garden_task.dart';
import '../../../models/garden_zone.dart';

enum GardenStatus { initial, loading, loaded, failure }

class GardenState {
  const GardenState({
    this.status = GardenStatus.initial,
    this.userId,
    this.zones = const [],
    this.plants = const [],
    this.tasks = const [],
    this.galleryEntries = const [],
    this.errorMessage,
  });

  final GardenStatus status;
  final String? userId;
  final List<GardenZone> zones;
  final List<GardenPlant> plants;
  final List<GardenTask> tasks;
  final List<GardenGalleryEntry> galleryEntries;
  final String? errorMessage;

  GardenState copyWith({
    GardenStatus? status,
    String? userId,
    List<GardenZone>? zones,
    List<GardenPlant>? plants,
    List<GardenTask>? tasks,
    List<GardenGalleryEntry>? galleryEntries,
    String? errorMessage,
    bool clearError = false,
  }) => GardenState(
    status: status ?? this.status,
    userId: userId ?? this.userId,
    zones: zones ?? this.zones,
    plants: plants ?? this.plants,
    tasks: tasks ?? this.tasks,
    galleryEntries: galleryEntries ?? this.galleryEntries,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
