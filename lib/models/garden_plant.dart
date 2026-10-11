class GardenPlant {
  GardenPlant({
    required this.id,
    required this.name,
    required this.zone,
    required this.description,
    required this.plantingDate,
    required this.wateringSchedule,
    this.imageAsset,
  });

  final String id;
  String name;
  String zone;
  String description;
  String plantingDate;
  String wateringSchedule;
  String? imageAsset;
}
