import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'login_screen.dart';

class DesignerDashboard extends StatefulWidget {
  const DesignerDashboard({Key? key}) : super(key: key);

  @override
  State<DesignerDashboard> createState() => _DesignerDashboardState();
}

class _DesignerDashboardState extends State<DesignerDashboard> {
  String? _userName;
  int _pendingCount = 0;
  int _approvedCount = 0;
  int _rejectedCount = 0;
  int _totalDesigns = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      try {
        // Load user name
        final userResponse = await Supabase.instance.client
            .from('users')
            .select('full_name')
            .eq('id', user.id)
            .single();

        // Load design stats
        final designsResponse = await Supabase.instance.client
            .from('tshirts')
            .select('status')
            .eq('designer_id', user.id);

        final designs = List<Map<String, dynamic>>.from(designsResponse);

        setState(() {
          _userName = userResponse['full_name'];
          _totalDesigns = designs.length;
          _pendingCount = designs.where((d) => d['status'] == 'pending').length;
          _approvedCount = designs.where((d) => d['status'] == 'approved').length;
          _rejectedCount = designs.where((d) => d['status'] == 'rejected').length;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading data: $e');
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade500,
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  children: [
                    // Profile and Logout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.design_services,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Designer Dashboard',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _userName ?? 'Designer',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: _signOut,
                          tooltip: 'Sign Out',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            _totalDesigns.toString(),
                            Icons.design_services,
                            Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Approved',
                            _approvedCount.toString(),
                            Icons.check_circle,
                            Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            _pendingCount.toString(),
                            Icons.pending,
                            Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Rejected',
                            _rejectedCount.toString(),
                            Icons.cancel,
                            Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Menu Section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What would you like to do?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Upload New Design Card
                        _buildFeatureCard(
                          icon: Icons.upload_file,
                          title: 'Upload New Design',
                          description: 'Create and submit a new t-shirt design',
                          gradient: const LinearGradient(
                            colors: [Colors.green, Colors.lightGreen],
                          ),
                          badge: 'NEW',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UploadDesignPage(
                                  onUploadSuccess: _loadDashboardData,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // My Designs Card
                        _buildFeatureCard(
                          icon: Icons.inventory,
                          title: 'My Designs',
                          description: 'View all your submitted designs',
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.lightBlue],
                          ),
                          badge: _totalDesigns > 0 ? _totalDesigns.toString() : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MyDesignsPage(
                                  onRefresh: _loadDashboardData,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Pending Approvals Card
                        _buildFeatureCard(
                          icon: Icons.pending_actions,
                          title: 'Pending Approvals',
                          description: 'Designs waiting for admin review',
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                          ),
                          badge: _pendingCount > 0 ? _pendingCount.toString() : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PendingDesignsPage(
                                  onRefresh: _loadDashboardData,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Analytics Card
                        _buildFeatureCard(
                          icon: Icons.analytics,
                          title: 'Analytics',
                          description: 'View performance of your designs',
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📊 Analytics feature coming soon!'),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Quick Tips Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb, color: Colors.blue.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Designer Tips',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTipItem('Upload high-quality images (min 800x800px)'),
                              _buildTipItem('Include 3D models for AR try-on feature'),
                              _buildTipItem('Write clear, descriptive titles'),
                              _buildTipItem('Set competitive pricing'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// UPLOAD DESIGN PAGE
class UploadDesignPage extends StatefulWidget {
  final VoidCallback onUploadSuccess;

  const UploadDesignPage({Key? key, required this.onUploadSuccess}) : super(key: key);

  @override
  State<UploadDesignPage> createState() => _UploadDesignPageState();
}

class _UploadDesignPageState extends State<UploadDesignPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '10');

  File? _imageFile;
  File? _glbFile;
  bool _isUploading = false;

  final List<String> _selectedSizes = ['M', 'L', 'XL'];
  final List<String> _selectedColors = ['Black', 'White'];
  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _availableColors = ['Black', 'White', 'Gray', 'Navy', 'Red', 'Blue'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _pickGLBFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['glb', 'gltf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _glbFile = File(result.files.single.path!));
    }
  }

  Future<String?> _uploadFile(File file, String bucket, String folder) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final fileName = '$folder/$userId\_$timestamp.$extension';

      await Supabase.instance.client.storage
          .from(bucket)
          .upload(fileName, file);

      final url = Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> _submitDesign() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please select an image')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload image
      final imageUrl = await _uploadFile(_imageFile!, 'tshirt-images', 'designs');
      if (imageUrl == null) throw Exception('Image upload failed');

      // Insert t-shirt data
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final tshirtResponse = await Supabase.instance.client
          .from('tshirts')
          .insert({
        'designer_id': userId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'sizes': _selectedSizes,
        'colors': _selectedColors,
        'image_url': imageUrl,
        'stock_quantity': int.parse(_stockController.text),
        'status': 'pending',
      })
          .select()
          .single();

      // Upload 3D model if provided
      if (_glbFile != null) {
        final glbUrl = await _uploadFile(_glbFile!, 'tshirt-models', 'models');
        if (glbUrl != null) {
          await Supabase.instance.client.from('models_3d').insert({
            'tshirt_id': tshirtResponse['id'],
            'designer_id': userId,
            'model_url': glbUrl,
            'model_type': _glbFile!.path.split('.').last,
            'status': 'pending',
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Design uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onUploadSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload New Design'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 80, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to add t-shirt image',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                      Text(
                        'Min 800x800px recommended',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'T-Shirt Title *',
                  hintText: 'e.g., Cool Summer Design',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe your design...',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),

              const SizedBox(height: 16),

              // Price and Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (₱) *',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (double.tryParse(value!) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock *',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sizes
              Text('Available Sizes *', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSizes.map((size) {
                  final isSelected = _selectedSizes.contains(size);
                  return FilterChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSizes.add(size);
                        } else {
                          _selectedSizes.remove(size);
                        }
                      });
                    },
                    selectedColor: Colors.green,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Colors
              Text('Available Colors *', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableColors.map((color) {
                  final isSelected = _selectedColors.contains(color);
                  return FilterChip(
                    label: Text(color),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedColors.add(color);
                        } else {
                          _selectedColors.remove(color);
                        }
                      });
                    },
                    selectedColor: Colors.green,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 3D Model Upload
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.view_in_ar, color: Colors.purple.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '3D Model (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a 3D model (.glb/.gltf) to enable AR try-on feature',
                      style: TextStyle(fontSize: 12, color: Colors.purple.shade700),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pickGLBFile,
                      icon: Icon(_glbFile == null ? Icons.upload_file : Icons.check_circle),
                      label: Text(_glbFile == null ? 'Upload 3D Model' : '✓ Model Selected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple.shade700,
                        side: BorderSide(color: _glbFile != null ? Colors.green : Colors.purple.shade300),
                      ),
                    ),
                    if (_glbFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'File: ${_glbFile!.path.split('/').last}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isUploading ? null : _submitDesign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Submit for Approval',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),

              // Info note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your design will be reviewed by admin before going live',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MY DESIGNS PAGE
class MyDesignsPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const MyDesignsPage({Key? key, required this.onRefresh}) : super(key: key);

  @override
  State<MyDesignsPage> createState() => _MyDesignsPageState();
}

class _MyDesignsPageState extends State<MyDesignsPage> {
  List<Map<String, dynamic>> _myDesigns = [];
  bool _isLoading = false;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadMyDesigns();
  }

  Future<void> _loadMyDesigns() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final response = await Supabase.instance.client
          .from('tshirts')
          .select('*, models_3d(*)')
          .eq('designer_id', userId!)
          .order('created_at', ascending: false);

      setState(() {
        _myDesigns = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
      widget.onRefresh();
    } catch (e) {
      print('Error loading designs: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredDesigns {
    if (_filterStatus == 'all') return _myDesigns;
    return _myDesigns.where((d) => d['status'] == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Designs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Approved', 'approved'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected', 'rejected'),
                ],
              ),
            ),
          ),

          // Designs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDesigns.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No designs found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadMyDesigns,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredDesigns.length,
                itemBuilder: (context, index) {
                  return _buildDesignCard(_filteredDesigns[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _filterStatus == status;
    final count = status == 'all'
        ? _myDesigns.length
        : _myDesigns.where((d) => d['status'] == status).length;

    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesignCard(Map<String, dynamic> design) {
    final status = design['status'] as String;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'APPROVED';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'REJECTED';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'PENDING';
    }

    final has3DModel = design['models_3d'] != null &&
        (design['models_3d'] as List).isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (design['image_url'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                design['image_url'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 60),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        design['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '₱${design['price']}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2E3192),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                if (design['description'] != null)
                  Text(
                    design['description'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 12),

                // Info Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.inventory_2,
                      'Stock: ${design['stock_quantity']}',
                      Colors.blue,
                    ),
                    if (has3DModel)
                      _buildInfoChip(
                        Icons.view_in_ar,
                        '3D Model',
                        Colors.purple,
                      ),
                    _buildInfoChip(
                      Icons.calendar_today,
                      _formatDate(design['created_at']),
                      Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

// PENDING DESIGNS PAGE
class PendingDesignsPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const PendingDesignsPage({Key? key, required this.onRefresh}) : super(key: key);

  @override
  State<PendingDesignsPage> createState() => _PendingDesignsPageState();
}

class _PendingDesignsPageState extends State<PendingDesignsPage> {
  List<Map<String, dynamic>> _pendingDesigns = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingDesigns();
  }

  Future<void> _loadPendingDesigns() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final response = await Supabase.instance.client
          .from('tshirts')
          .select('*, models_3d(*)')
          .eq('designer_id', userId!)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        _pendingDesigns = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
      widget.onRefresh();
    } catch (e) {
      print('Error loading pending designs: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingDesigns.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No pending designs',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'All your designs have been reviewed!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadPendingDesigns,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pendingDesigns.length,
          itemBuilder: (context, index) {
            final design = _pendingDesigns[index];
            final has3DModel = design['models_3d'] != null &&
                (design['models_3d'] as List).isNotEmpty;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.orange.shade200, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  if (design['image_url'] != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            design['image_url'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.pending, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'PENDING',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                design['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '₱${design['price']}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (design['description'] != null)
                          Text(
                            design['description'],
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 12),

                        // Info chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(
                              Icons.inventory_2,
                              'Stock: ${design['stock_quantity']}',
                              Colors.blue,
                            ),
                            if (has3DModel)
                              _buildInfoChip(
                                Icons.view_in_ar,
                                '3D Model',
                                Colors.purple,
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Info message
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange.shade700,
                                  size: 20
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Waiting for admin review',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}