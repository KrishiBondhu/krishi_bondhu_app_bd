import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:krishi_bondhu_app_bd/screens/market/market_price_screen.dart';
// === 1. IMPORT YOUR NEW SCREEN ===
import 'package:krishi_bondhu_app_bd/screens/market/buy_sell_screen.dart';

/// Grid of quick action buttons for dashboard
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = _getQuickActions(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 100)),
              curve: Curves.easeOutBack,
              child: _buildActionCard(action),
            );
          },
        );
      },
    );
  }

  /// Build individual action card
  Widget _buildActionCard(QuickActionItem action) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: action.color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: action.onTap,
          splashColor: action.color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          action.color.withOpacity(0.15),
                          action.color.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: action.color.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      action.icon,
                      size: 24,
                      color: action.color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    action.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get list of quick actions
  List<QuickActionItem> _getQuickActions(BuildContext context) {
    return [
      QuickActionItem(
        title: AppStrings.cropManagement,
        icon: Icons.agriculture,
        color: AppColors.primaryGreen,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Crop Management feature coming soon!')),
          );
        },
      ),
      QuickActionItem(
        title: AppStrings.weatherForecast,
        icon: Icons.wb_sunny,
        color: Colors.orange,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Weather Forecast feature coming soon!')),
          );
        },
      ),
      QuickActionItem(
        title: AppStrings.marketPrices,
        icon: Icons.trending_up,
        color: Colors.blue,
        onTap: () {
          // --- ⚠️ ভুলটি এখানে ঠিক করা হয়েছে ---
          // এখন এটি সরাসরি MarketPriceScreen-এ যাবে
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MarketPriceScreen()),
          );
        },
      ),
      // ✅ নতুন "Buy & Sell" action যোগ করা হলো
      QuickActionItem(
        title: 'Buy & Sell',
        icon: Icons.shopping_cart,
        color: Colors.deepOrange,
        onTap: () {
          // === 2. THIS IS THE CHANGE ===
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuySellScreen()),
          );
          // ==============================
        },
      ),
      QuickActionItem(
        title: AppStrings.expertAdvice,
        icon: Icons.psychology,
        color: Colors.purple,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expert Advice feature coming soon!')),
          );
        },
      ),
      QuickActionItem(
        title: AppStrings.communityForum,
        icon: Icons.groups,
        color: Colors.teal,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Community Forum feature coming soon!')),
          );
        },
      ),
      QuickActionItem(
        title: AppStrings.pestControl,
        icon: Icons.bug_report,
        color: Colors.red,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pest Control feature coming soon!')),
          );
        },
      ),
    ];
  }
}
// ...existing code...

/// Quick Action Item Model
class QuickActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}