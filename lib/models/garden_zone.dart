import 'package:flutter/material.dart';

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

  final String id;
  String name;
  String soilType;
  double areaSqM;
  Color color;
  double left;
  double top;
  double width;
  double height;
  List<String> plants;
  bool isActive;
}