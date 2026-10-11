class ZoneModel {
  final String id;
  final String name;
  final String soilType;
  final String areaSize;
  final int plantCount;
  final List<String> plants;
  final String status;

  ZoneModel({
    required this.id,
    required this.name,
    required this.soilType,
    required this.areaSize,
    required this.plantCount,
    required this.plants,
    this.status = 'Active',
  });
}

class PlantModel {
  final String id;
  final String name;
  final String zoneName;
  final String imageUrl;
  final String plantingDate;
  final String wateringSchedule;

  PlantModel({
    required this.id,
    required this.name,
    required this.zoneName,
    required this.imageUrl,
    required this.plantingDate,
    required this.wateringSchedule,
  });
}

class TaskModel {
  final String id;
  final String title;
  final String zoneOrPlant;
  final String dueDate;
  final String priority;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.zoneOrPlant,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });
}