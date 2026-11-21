import '../../../models/garden_plant.dart';
import '../../../models/garden_gallery_entry.dart';
import '../../../models/garden_task.dart';
import '../../../models/garden_zone.dart';

sealed class GardenEvent {
  const GardenEvent();
}

final class GardenLoadRequested extends GardenEvent {
  const GardenLoadRequested(this.userId);
  final String userId;
}

final class GardenZoneAdded extends GardenEvent {
  const GardenZoneAdded(this.zone);
  final GardenZone zone;
}

final class GardenZoneUpdated extends GardenEvent {
  const GardenZoneUpdated(this.zone);
  final GardenZone zone;
}

final class GardenZoneRemoved extends GardenEvent {
  const GardenZoneRemoved(this.id);
  final String id;
}

final class GardenPlantAdded extends GardenEvent {
  const GardenPlantAdded(this.plant);
  final GardenPlant plant;
}

final class GardenPlantUpdated extends GardenEvent {
  const GardenPlantUpdated(this.plant);
  final GardenPlant plant;
}

final class GardenPlantRemoved extends GardenEvent {
  const GardenPlantRemoved(this.id);
  final String id;
}

final class GardenGalleryEntryAdded extends GardenEvent {
  const GardenGalleryEntryAdded(this.entry);
  final GardenGalleryEntry entry;
}

final class GardenGalleryEntryUpdated extends GardenEvent {
  const GardenGalleryEntryUpdated(this.entry);
  final GardenGalleryEntry entry;
}

final class GardenGalleryEntryRemoved extends GardenEvent {
  const GardenGalleryEntryRemoved(this.id);
  final String id;
}

final class GardenTaskAdded extends GardenEvent {
  const GardenTaskAdded(this.task);
  final GardenTask task;
}

final class GardenTaskUpdated extends GardenEvent {
  const GardenTaskUpdated(this.task);
  final GardenTask task;
}

final class GardenTaskRemoved extends GardenEvent {
  const GardenTaskRemoved(this.id);
  final String id;
}
