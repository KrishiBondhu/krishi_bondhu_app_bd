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
          BoxShadow(
            color: action.color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          splashColor: action.color.withValues(alpha: 0.1),
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
                          action.color.withValues(alpha: 0.15),
                          action.color.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: action.color.withValues(alpha: 0.2),
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
                content: Text('ফসল ব্যবস্থাপনা ফিচার খুব শীঘ্রই আসছে!')),
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
                content: Text('আবহাওয়া পূর্বাভাস ফিচার খুব শীঘ্রই আসছে!')),
          );
        },
      ),
      QuickActionItem(
        title: AppStrings.marketPrices,
        icon: Icons.trending_up,
        color: Colors.blue,
        onTap: () {
          Navigator.pushNamed(context, '/market-prices');
        },
      ),
      // ✅ নতুন "Buy & Sell" action যোগ করা হলো
      QuickActionItem(
        title: 'কিনুন ও বিক্রি করুন',
        icon: Icons.shopping_cart,
        color: Colors.deepOrange,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('কিনুন ও বিক্রি ফিচার খুব শীঘ্রই আসছে!'),
              backgroundColor: Colors.deepOrange,
            ),
          );
        },
      ),
      QuickActionItem(
        title: AppStrings.expertAdvice,
        icon: Icons.psychology,
        color: Colors.purple,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('বিশেষজ্ঞ পরামর্শ ফিচার খুব শীঘ্রই আসছে!')),
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
                content: Text('কমিউনিটি ফোরাম ফিচার খুব শীঘ্রই আসছে!')),
          );
        },
      ),
      QuickActionItem(
        title: AppStrings.pestControl,
        icon: Icons.bug_report,
        color: Colors.red,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('পোকামাকড় নিয়ন্ত্রণ ফিচার খুব শীঘ্রই আসছে!')),
          );
        },
      ),
    ];
  }
}
