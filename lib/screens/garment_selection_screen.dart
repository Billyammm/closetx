import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ar_tryon_screen.dart';

class GarmentSelectionScreen extends StatefulWidget {
  const GarmentSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GarmentSelectionScreen> createState() => _GarmentSelectionScreenState();
}

class _GarmentSelectionScreenState extends State<GarmentSelectionScreen> {
  List<Map<String, dynamic>> _garments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGarments();
  }

  Future<void> _loadGarments() async {
    try {
      // Fetch approved t-shirts with 3D models from Supabase
      final response = await Supabase.instance.client
          .from('tshirts')
          .select('*, users!inner(full_name), models_3d(*)')
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      setState(() {
        _garments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Garment'),
        backgroundColor: const Color(0xFF2E3192),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _garments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checkroom, size: 100, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No garments available',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _garments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final garment = _garments[index];
                    final title = garment['title'] as String;
                    final description = garment['description'] as String? ??
                        'AR-enabled garment';

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A90E2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    title.toLowerCase().contains('shoe')
                                        ? Icons.directions_walk
                                        : Icons.checkroom,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Try On Live'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E3192),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ARTryOnScreen(garmentData: garment),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
