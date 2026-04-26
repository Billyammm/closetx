import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('users')
            .select('full_name')
            .eq('id', user.id)
            .single();

        setState(() {
          _userName = response['full_name'];
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading user: $e');
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
              const Color(0xFF2E3192),
              const Color(0xFF2E3192).withOpacity(0.8),
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
                                Icons.person,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome back!',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _userName ?? 'Guest',
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
                    // App Title
                    const Text(
                      'ClosetX',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your AR T-Shirt Store',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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

                        // AR Try-On Card
                        _buildFeatureCard(
                          icon: Icons.view_in_ar,
                          title: 'AR Try-On',
                          description: 'Try t-shirts virtually with AR technology',
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ARTryOnPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Browse T-Shirts Card
                        _buildFeatureCard(
                          icon: Icons.shopping_bag,
                          title: 'Browse T-Shirts',
                          description: 'Explore our collection of unique designs',
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.lightBlue],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BrowseTshirtsPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Wishlist Card
                        _buildFeatureCard(
                          icon: Icons.favorite,
                          title: 'My Wishlist',
                          description: 'View your favorite t-shirt designs',
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.pink],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WishlistPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // My Orders Card
                        _buildFeatureCard(
                          icon: Icons.receipt_long,
                          title: 'My Orders',
                          description: 'Track your order history',
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📦 Orders feature coming soon!'),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Quick Stats (Optional)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.shopping_cart,
                                label: 'Cart',
                                value: '0',
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                              ),
                              _buildStatItem(
                                icon: Icons.favorite,
                                label: 'Wishlist',
                                value: '0',
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                              ),
                              _buildStatItem(
                                icon: Icons.local_shipping,
                                label: 'Orders',
                                value: '0',
                              ),
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
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
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2E3192)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3192),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// AR TRY-ON PAGE
class ARTryOnPage extends StatefulWidget {
  const ARTryOnPage({Key? key}) : super(key: key);

  @override
  State<ARTryOnPage> createState() => _ARTryOnPageState();
}

class _ARTryOnPageState extends State<ARTryOnPage> {
  List<Map<String, dynamic>> _arTshirts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadARTshirts();
  }

  Future<void> _loadARTshirts() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('tshirts')
          .select('*, users!inner(full_name), models_3d!inner(*)')
          .eq('status', 'approved')
          .eq('models_3d.status', 'approved')
          .order('created_at', ascending: false);

      setState(() {
        _arTshirts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading AR t-shirts: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Try-On'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _arTshirts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_in_ar, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No AR-enabled t-shirts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon for 3D try-on!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _arTshirts.length,
        itemBuilder: (context, index) {
          final tshirt = _arTshirts[index];
          final designer = tshirt['users'] as Map<String, dynamic>;

          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 AR Try-On feature coming soon!'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Colors.purple, width: 2),
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
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.view_in_ar,
                                    size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'AR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
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

// BROWSE T-SHIRTS PAGE
class BrowseTshirtsPage extends StatefulWidget {
  const BrowseTshirtsPage({Key? key}) : super(key: key);

  @override
  State<BrowseTshirtsPage> createState() => _BrowseTshirtsPageState();
}

class _BrowseTshirtsPageState extends State<BrowseTshirtsPage> {
  List<Map<String, dynamic>> _allTshirts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllTshirts();
  }

  Future<void> _loadAllTshirts() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('tshirts')
          .select('*, users!inner(full_name), models_3d(*)')
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      setState(() {
        _allTshirts = List<Map<String, dynamic>>.from(response);
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
        title: const Text('Browse T-Shirts'),
        backgroundColor: const Color(0xFF2E3192),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allTshirts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No t-shirts available yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon for new designs!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadAllTshirts,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _allTshirts.length,
          itemBuilder: (context, index) {
            final tshirt = _allTshirts[index];
            final designer = tshirt['users'] as Map<String, dynamic>;
            final has3DModel = tshirt['models_3d'] != null &&
                (tshirt['models_3d'] as List).isNotEmpty;

            return GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🛒 Product details coming soon!'),
                  ),
                );
              },
              child: Card(
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
                              child: const Icon(Icons.image,
                                  size: 60),
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
                                  borderRadius:
                                  BorderRadius.circular(12),
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
                              color: Color(0xFF2E3192),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// WISHLIST PAGE
class WishlistPage extends StatelessWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Your wishlist is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some t-shirts you love!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}