import 'package:flutter/material.dart';
import '../models/garment_model.dart';
import '../models/garment_tracking_data.dart';

class LocalGarmentSdk {
  static const List<GarmentModel> garments = [
    GarmentModel(
      id: 'tshirt-basic',
      name: 'Classic Tee',
      category: 'T-Shirt',
      description: 'A lightweight tee with a modern fit, built for AR preview.',
      color: Color(0xFF4A90E2),
    ),
    GarmentModel(
      id: 'hoodie-slate',
      name: 'Slate Hoodie',
      category: 'Hoodie',
      description: 'A cozy hoodie designed for quick try-on and live overlay.',
      color: Color(0xFF3B3B98),
    ),
    GarmentModel(
      id: 'sneaker-step',
      name: 'Step Sneaker',
      category: 'Shoes',
      description: 'Basic shoe overlay for lifestyle try-on previews.',
      color: Color(0xFF0A8754),
      is3D: false,
    ),
  ];

  static List<GarmentModel> getAvailableGarments() => garments;

  static GarmentModel? findById(String id) {
    return garments.firstWhere(
      (item) => item.id == id,
      orElse: () => garments.first,
    );
  }

  static GarmentTrackingData createTrackingData(
    String garmentId, {
    double anchorX = 0.5,
    double anchorY = 0.3,
    double scale = 1.0,
  }) {
    return GarmentTrackingData(
      garmentId: garmentId,
      capturedAt: DateTime.now(),
      anchorX: anchorX,
      anchorY: anchorY,
      scale: scale,
    );
  }
}
