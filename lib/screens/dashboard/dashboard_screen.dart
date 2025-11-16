import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/weather_service.dart';
import '../../models/weather_model.dart';
import 'widgets/weather_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'package:krishi_bondhu_app_bd/screens/settings/settings_screen.dart'; // <-- IMPORT ADDED

/// Main dashboard screen for farmers
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _weatherService = WeatherService();

  Weather? _currentWeather;
  bool _isLoading = true;
  String _userName = 'Farmer';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Load dashboard data
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user data
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _userName = user.name.split(' ').first;
      }

      // Load weather data
      _currentWeather = await _weatherService.getCurrentWeather();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ড্যাশবোর্ড ডেটা লোড করতে ব্যর্থ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('লগআউট'),
        content: const Text('আপনি কি নিশ্চিত লগআউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('বাতিল'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('লগআউট'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          AppStrings.dashboard,
          style: AppTextStyles.heading3,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('নোটিফিকেশন ফিচার খুব শীঘ্রই আসছে!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('অনুসন্ধান ফিচার খুব শীঘ্রই আসছে!')),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: AppColors.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome header
                    _buildWelcomeHeader(),

                    const SizedBox(height: 32),

                    // Weather card
                    if (_currentWeather != null)
                      WeatherCard(weather: _currentWeather!),

                    const SizedBox(height: 32),

                    // Quick actions
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.dashboard,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppStrings.quickActions,
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const QuickActionsGrid(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  /// Build welcome header
  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen,
            AppColors.darkGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile picture placeholder
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.lightGreen,
              child: Icon(
                Icons.person,
                size: 28,
                color: AppColors.darkGreen,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Welcome message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.welcomeMessage,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🌱 উৎপাদনশীল একটি দিন কাটুক!',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Date and time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMM dd').format(DateTime.now()),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(DateTime.now()),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build navigation drawer
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _userName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'কৃষক',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('ড্যাশবোর্ড'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('প্রোফাইল'),
            onTap: () {
              Navigator.pop(context);
              // Changed this to point to Settings, as it's more direct
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.agriculture),
            title: const Text('আমার ফসল'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('আমার ফসল ফিচার খুব শীঘ্রই আসছে!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('বিশ্লেষণ'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('বিশ্লেষণ ফিচার খুব শীঘ্রই আসছে!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('সেটিংস'),
            onTap: () {
              // === THIS IS THE CHANGE ===
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              // ==========================
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('সাহায্য এবং সহায়তা'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('সাহায্য ফিচার খুব শীঘ্রই আসছে!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('লগআউট', style: TextStyle(color: Colors.red)),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }
}
