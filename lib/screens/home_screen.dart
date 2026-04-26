import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'customer_dashboard.dart';
import 'designer_dashboard.dart';
import 'admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userEmail;
  String? _userName;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndNavigate();
  }

  Future<void> _loadUserDataAndNavigate() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      // No user, go to login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    try {
      // Get user data from database
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      final role = response['role'] as String;

      if (!mounted) return;

      // Navigate to appropriate dashboard based on role
      Widget destination;
      switch (role) {
        case 'admin':
          destination = const AdminDashboard();
          break;
        case 'designer':
          destination = const DesignerDashboard();
          break;
        case 'customer':
        default:
          destination = const CustomerDashboard();
          break;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    } catch (e) {
      print('Error loading user data: $e');

      // If error, try to use metadata
      final role = user.userMetadata?['role'] ?? 'customer';

      if (mounted) {
        Widget destination;
        switch (role) {
          case 'admin':
            destination = const AdminDashboard();
            break;
          case 'designer':
            destination = const DesignerDashboard();
            break;
          case 'customer':
          default:
            destination = const CustomerDashboard();
            break;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => destination),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This screen is just a router, show loading while determining destination
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checkroom_rounded,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ClosetX',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading your dashboard...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}