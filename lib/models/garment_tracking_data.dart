class GarmentTrackingData {
  final String garmentId;
  final DateTime capturedAt;
  final double anchorX;
  final double anchorY;
  final double scale;

  const GarmentTrackingData({
    required this.garmentId,
    required this.capturedAt,
    required this.anchorX,
    required this.anchorY,
    required this.scale,
  });
}
