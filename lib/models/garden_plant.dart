// Модель рослини, яку використовують каталог і дашборд.
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

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'zone': zone,
    'description': description,
    'plantingDate': plantingDate,
    'wateringSchedule': wateringSchedule,
    'imageAsset': imageAsset,
  };

  factory GardenPlant.fromJson(Map<String, dynamic> json) => GardenPlant(
    id: json['id'] as String,
    name: json['name'] as String,
    zone: json['zone'] as String,
    description: json['description'] as String,
    plantingDate: json['plantingDate'] as String,
    wateringSchedule: json['wateringSchedule'] as String,
    imageAsset: json['imageAsset'] as String?,
  );
}
