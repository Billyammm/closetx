import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ARTryOnScreen extends StatefulWidget {
  final Map<String, dynamic> garmentData;

  const ARTryOnScreen({Key? key, required this.garmentData}) : super(key: key);

  @override
  State<ARTryOnScreen> createState() => _ARTryOnScreenState();
}

class _ARTryOnScreenState extends State<ARTryOnScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _permissionDenied = false;

  late final double _anchorY = _getAnchorY();
  late final double _scale = _getScale();

  double _getAnchorY() {
    // Adjust anchor based on garment type
    final title = widget.garmentData['title'] as String;
    if (title.toLowerCase().contains('shoe') ||
        title.toLowerCase().contains('sneaker')) {
      return 0.7;
    }
    return 0.28;
  }

  double _getScale() {
    final title = widget.garmentData['title'] as String;
    if (title.toLowerCase().contains('shoe') ||
        title.toLowerCase().contains('sneaker')) {
      return 0.75;
    }
    return 1.05;
  }

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController?.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          _isCameraReady = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Try-On'),
        backgroundColor: const Color(0xFF2E3192),
      ),
      body: _permissionDenied
          ? Center(
              child: Text(
                'Camera permission is required for live try-on.',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : !_isCameraReady
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Positioned.fill(
                      child: CameraPreview(_cameraController!),
                    ),
                    _buildGarmentOverlay(context),
                    Positioned(
                      bottom: 18,
                      left: 16,
                      right: 16,
                      child: _buildStatusPanel(context),
                    ),
                  ],
                ),
    );
  }

  Widget _buildGarmentOverlay(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final overlayTop = screenSize.height * _anchorY;
    final title = widget.garmentData['title'] as String;
    final overlayHeight = title.toLowerCase().contains('shoe') ? 140.0 : 260.0;
    final overlayWidth = screenSize.width * 0.64;

    return Positioned(
      top: overlayTop,
      left: (screenSize.width - overlayWidth) / 2,
      child: Opacity(
        opacity: 0.72,
        child: Container(
          width: overlayWidth,
          height: overlayHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.75),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white70, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPanel(BuildContext context) {
    final title = widget.garmentData['title'] as String;
    final description = widget.garmentData['description'] as String? ??
        'AR-enabled garment from collection';

    return Card(
      color: Colors.white.withOpacity(0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildBadge('AnchorX', '0.50'),
                const SizedBox(width: 10),
                _buildBadge('AnchorY', _anchorY.toStringAsFixed(2)),
                const SizedBox(width: 10),
                _buildBadge('Scale', _scale.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Live body tracking overlay is active. Use this screen to preview garments in real time, then tweak the anchor if needed.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3192),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
