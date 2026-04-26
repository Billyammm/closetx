import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? _userName;
  int _pendingCount = 0;
  int _approvedCount = 0;
  int _totalDesigns = 0;
  int _totalUsers = 0;
  int _totalDesigners = 0;
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
            .select('status');

        final designs = List<Map<String, dynamic>>.from(designsResponse);

        // Load user stats
        final usersResponse = await Supabase.instance.client
            .from('users')
            .select('role');

        final users = List<Map<String, dynamic>>.from(usersResponse);

        setState(() {
          _userName = userResponse['full_name'];
          _totalDesigns = designs.length;
          _pendingCount = designs.where((d) => d['status'] == 'pending').length;
          _approvedCount = designs.where((d) => d['status'] == 'approved').length;
          _totalUsers = users.length;
          _totalDesigners = users.where((u) => u['role'] == 'designer').length;
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
              Colors.purple.shade800,
              Colors.purple.shade600,
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
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Admin Dashboard',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _userName ?? 'Administrator',
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

                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          'Pending',
                          _pendingCount.toString(),
                          Icons.pending_actions,
                          Colors.white,
                        ),
                        _buildStatCard(
                          'Approved',
                          _approvedCount.toString(),
                          Icons.check_circle,
                          Colors.white,
                        ),
                        _buildStatCard(
                          'Total Designs',
                          _totalDesigns.toString(),
                          Icons.inventory,
                          Colors.white,
                        ),
                        _buildStatCard(
                          'Designers',
                          _totalDesigners.toString(),
                          Icons.people,
                          Colors.white,
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
                          'Administration',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Pending Approvals Card (Priority)
                        _buildFeatureCard(
                          icon: Icons.pending_actions,
                          title: 'Pending Approvals',
                          description: 'Review and approve designer submissions',
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                          ),
                          badge: _pendingCount > 0 ? _pendingCount.toString() : null,
                          priority: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminPendingApprovalsPage(
                                  onRefresh: _loadDashboardData,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // All Designs Card
                        _buildFeatureCard(
                          icon: Icons.inventory,
                          title: 'All Designs',
                          description: 'View and manage all t-shirt designs',
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.lightBlue],
                          ),
                          badge: _totalDesigns > 0 ? _totalDesigns.toString() : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminAllDesignsPage(
                                  onRefresh: _loadDashboardData,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Browse as Customer Card
                        _buildFeatureCard(
                          icon: Icons.shopping_bag,
                          title: 'Browse T-Shirts',
                          description: 'View store as customer perspective',
                          gradient: const LinearGradient(
                            colors: [Colors.green, Colors.lightGreen],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminBrowseTshirtsPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Manage Users Card
                        _buildFeatureCard(
                          icon: Icons.people,
                          title: 'Manage Users',
                          description: 'View all users and manage accounts',
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                          ),
                          badge: _totalUsers > 0 ? _totalUsers.toString() : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminManageUsersPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Analytics Card
                        _buildFeatureCard(
                          icon: Icons.analytics,
                          title: 'Analytics',
                          description: 'View platform statistics and reports',
                          gradient: const LinearGradient(
                            colors: [Colors.teal, Colors.cyan],
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📊 Analytics feature coming soon!'),
                              ),
                            );
                          },
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
        mainAxisAlignment: MainAxisAlignment.center,
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
            textAlign: TextAlign.center,
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
    bool priority = false,
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
              color: Colors.black.withOpacity(priority ? 0.2 : 0.1),
              blurRadius: priority ? 15 : 10,
              offset: Offset(0, priority ? 6 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(priority ? 24 : 20),
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
                  size: priority ? 36 : 32,
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: priority ? 20 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
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
}

// ADMIN PENDING APPROVALS PAGE
class AdminPendingApprovalsPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const AdminPendingApprovalsPage({Key? key, required this.onRefresh}) : super(key: key);

  @override
  State<AdminPendingApprovalsPage> createState() => _AdminPendingApprovalsPageState();
}

class _AdminPendingApprovalsPageState extends State<AdminPendingApprovalsPage> {
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
      final response = await Supabase.instance.client
          .from('tshirts')
          .select('*, users!inner(full_name, email), models_3d(*)')
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

  Future<void> _updateDesignStatus(String designId, String status) async {
    try {
      await Supabase.instance.client
          .from('tshirts')
          .update({'status': status})
          .eq('id', designId);

      // Also update 3D model status if exists
      await Supabase.instance.client
          .from('models_3d')
          .update({'status': status})
          .eq('tshirt_id', designId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Design ${status == 'approved' ? 'approved' : 'rejected'}!'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ),
        );
      }

      _loadPendingDesigns();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_pendingDesigns.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_pendingDesigns.length}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
              'No pending approvals',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'All designs have been reviewed',
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
            return _buildApprovalCard(design);
          },
        ),
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> design) {
    final designer = design['users'] as Map<String, dynamic>;
    final has3DModel = design['models_3d'] != null &&
        (design['models_3d'] as List).isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
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
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
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
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        design['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '₱${design['price']}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Designer info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              designer['full_name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              designer['email'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                if (design['description'] != null && design['description'].isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      design['description'],
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),

                const SizedBox(height: 12),

                // Details
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
                        '3D Model Included',
                        Colors.purple,
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Sizes
                Text('Sizes:', style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: (design['sizes'] as List).map((size) {
                    return Chip(
                      label: Text(size.toString(), style: const TextStyle(fontSize: 12)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.blue[50],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // Colors
                Text('Colors:', style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: (design['colors'] as List).map((color) {
                    return Chip(
                      label: Text(color.toString(), style: const TextStyle(fontSize: 12)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.orange[50],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateDesignStatus(design['id'], 'approved'),
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateDesignStatus(design['id'], 'rejected'),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ADMIN ALL DESIGNS PAGE
class AdminAllDesignsPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const AdminAllDesignsPage({Key? key, required this.onRefresh}) : super(key: key);

  @override
  State<AdminAllDesignsPage> createState() => _AdminAllDesignsPageState();
}

class _AdminAllDesignsPageState extends State<AdminAllDesignsPage> {
  List<Map<String, dynamic>> _allDesigns = [];
  bool _isLoading = false;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadAllDesigns();
  }

  Future<void> _loadAllDesigns() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('tshirts')
          .select('*, users!inner(full_name), models_3d(*)')
          .order('created_at', ascending: false);

      setState(() {
        _allDesigns = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
      widget.onRefresh();
    } catch (e) {
      print('Error loading designs: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredDesigns {
    if (_filterStatus == 'all') return _allDesigns;
    return _allDesigns.where((d) => d['status'] == _filterStatus).toList();
  }

  Future<void> _deleteDesign(String designId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Design'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client
            .from('tshirts')
            .delete()
            .eq('id', designId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Design deleted successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }

        _loadAllDesigns();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Designs'),
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
                ? const Center(child: Text('No designs found'))
                : RefreshIndicator(
              onRefresh: _loadAllDesigns,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredDesigns.length,
                itemBuilder: (context, index) {
                  final design = _filteredDesigns[index];
                  final designer = design['users'] as Map<String, dynamic>;
                  final status = design['status'] as String;

                  Color statusColor;
                  IconData statusIcon;

                  switch (status) {
                    case 'approved':
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle;
                      break;
                    case 'rejected':
                      statusColor = Colors.red;
                      statusIcon = Icons.cancel;
                      break;
                    default:
                      statusColor = Colors.orange;
                      statusIcon = Icons.pending;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: design['image_url'] != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          design['image_url'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image),
                      ),
                      title: Text(
                        design['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('by ${designer['full_name']}'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteDesign(design['id']);
                          }
                        },
                      ),
                    ),
                  );
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
        ? _allDesigns.length
        : _allDesigns.where((d) => d['status'] == status).length;

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
}

// ADMIN BROWSE T-SHIRTS PAGE (Customer View)
class AdminBrowseTshirtsPage extends StatefulWidget {
  const AdminBrowseTshirtsPage({Key? key}) : super(key: key);

  @override
  State<AdminBrowseTshirtsPage> createState() => _AdminBrowseTshirtsPageState();
}

class _AdminBrowseTshirtsPageState extends State<AdminBrowseTshirtsPage> {
  List<Map<String, dynamic>> _approvedTshirts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApprovedTshirts();
  }

  Future<void> _loadApprovedTshirts() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('tshirts')
          .select('*, users!inner(full_name), models_3d(*)')
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      setState(() {
        _approvedTshirts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading t-shirts: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse T-Shirts (Customer View)'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _approvedTshirts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No approved t-shirts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Approve some designs to see them here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadApprovedTshirts,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _approvedTshirts.length,
          itemBuilder: (context, index) {
            final tshirt = _approvedTshirts[index];
            final designer = tshirt['users'] as Map<String, dynamic>;
            final has3DModel = tshirt['models_3d'] != null &&
                (tshirt['models_3d'] as List).isNotEmpty;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: tshirt['image_url'] != null
                              ? Image.network(
                            tshirt['image_url'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 60),
                          ),
                        ),
                        if (has3DModel)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.view_in_ar,
                                      size: 10, color: Colors.white),
                                  SizedBox(width: 2),
                                  Text(
                                    'AR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tshirt['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${designer['full_name']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₱${tshirt['price']}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
}

// ADMIN MANAGE USERS PAGE
class AdminManageUsersPage extends StatefulWidget {
  const AdminManageUsersPage({Key? key}) : super(key: key);

  @override
  State<AdminManageUsersPage> createState() => _AdminManageUsersPageState();
}

class _AdminManageUsersPageState extends State<AdminManageUsersPage> {
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = false;
  String _filterRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _allUsers = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_filterRole == 'all') return _allUsers;
    return _allUsers.where((u) => u['role'] == _filterRole).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.purple,
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
                  _buildFilterChip('Customers', 'customer'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Designers', 'designer'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Admins', 'admin'),
                ],
              ),
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? const Center(child: Text('No users found'))
                : RefreshIndicator(
              onRefresh: _loadAllUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  return _buildUserCard(_filteredUsers[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String role) {
    final isSelected = _filterRole == role;
    final count = role == 'all'
        ? _allUsers.length
        : _allUsers.where((u) => u['role'] == role).length;

    return GestureDetector(
      onTap: () => setState(() => _filterRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.purple : Colors.grey[300]!),
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
                  color: isSelected ? Colors.white : Colors.purple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.purple : Colors.white,
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

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = user['role'] as String;
    Color roleColor;
    IconData roleIcon;

    switch (role) {
      case 'admin':
        roleColor = Colors.purple;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'designer':
        roleColor = Colors.blue;
        roleIcon = Icons.design_services;
        break;
      default:
        roleColor = Colors.green;
        roleIcon = Icons.shopping_bag;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.2),
          child: Icon(roleIcon, color: roleColor),
        ),
        title: Text(
          user['full_name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email']),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role.toUpperCase(),
                style: TextStyle(
                  color: roleColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          _formatDate(user['created_at']),
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
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