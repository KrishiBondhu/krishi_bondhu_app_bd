import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

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
          // ... (rest of the card styling is unchanged) ...
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: action.onTap, // This line correctly uses the onTap from below
          splashColor: action.color.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              // ... (rest of the card layout is unchanged) ...
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    // ...
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
                    // ...
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

      // --- THIS IS YOUR CHANGE ---
      QuickActionItem(
        title: AppStrings.weatherForecast,
        icon: Icons.wb_sunny,
        color: Colors.orange,
        // Replace the SnackBar with your navigation
        onTap: () {
          Navigator.pushNamed(context, '/weather');
        },
      ),
      // --- END OF YOUR CHANGE ---

      QuickActionItem(
        title: AppStrings.marketPrices,
        icon: Icons.trending_up,
        color: Colors.blue,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Market Prices feature coming soon!')),
          );
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
