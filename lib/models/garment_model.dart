import 'package:flutter/material.dart';

class GarmentModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final Color color;
  final bool is3D;

  const GarmentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.color,
    this.is3D = true,
  });
}
