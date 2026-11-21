class GardenGalleryEntry {
  const GardenGalleryEntry({
    required this.id,
    required this.plantName,
    required this.date,
    required this.note,
    this.imageAsset,
  });

  final String id;
  final String plantName;
  final DateTime date;
  final String note;
  final String? imageAsset;

  Map<String, Object?> toJson() => {
    'id': id,
    'plantName': plantName,
    'date': date.toIso8601String(),
    'note': note,
    'imageAsset': imageAsset,
  };

  factory GardenGalleryEntry.fromJson(Map<String, dynamic> json) =>
      GardenGalleryEntry(
        id: json['id'] as String,
        plantName: json['plantName'] as String,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String,
        imageAsset: json['imageAsset'] as String?,
      );
}
