import 'package:flutter/material.dart';

// Дані однієї ділянки й її прямокутника на інтерактивній мапі.
class GardenZone {
  GardenZone({
    required this.id,
    required this.name,
    required this.soilType,
    required this.areaSqM,
    required this.color,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    List<String> plants = const [],
    this.isActive = true,
  }) : plants = List<String>.from(plants);

  final String
  id; // Ідентифікатор потрібен, щоб знайти зону під час редагування.
  String name;
  String soilType;
  double areaSqM;
  Color color;
  // Координати й розмір прямокутника на мапі.
  double left;
  double top;
  double width;
  double height;
  List<String> plants;
  bool isActive;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'soilType': soilType,
    'areaSqM': areaSqM,
    'color': color.toARGB32(),
    'left': left,
    'top': top,
    'width': width,
    'height': height,
    'plants': plants,
    'isActive': isActive,
  };

  factory GardenZone.fromJson(Map<String, dynamic> json) => GardenZone(
    id: json['id'] as String,
    name: json['name'] as String,
    soilType: json['soilType'] as String,
    areaSqM: (json['areaSqM'] as num).toDouble(),
    color: Color(json['color'] as int),
    left: (json['left'] as num).toDouble(),
    top: (json['top'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
    plants: List<String>.from(json['plants'] as List? ?? const []),
    isActive: json['isActive'] as bool? ?? true,
  );
}
