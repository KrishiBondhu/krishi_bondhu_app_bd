import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../models/activity_model.dart';

/// List of recent farm activities
class ActivityList extends StatelessWidget {
  final List<FarmActivity> activities;

  const ActivityList({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  AppStrings.recentActivity,
                  style: AppTextStyles.heading3,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('View All Activities feature coming soon!')),
                    );
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Activity list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityItem(activity);
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Build individual activity item
  Widget _buildActivityItem(FarmActivity activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Activity icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              size: 20,
              color: activity.color,
            ),
          ),

          const SizedBox(width: 16),

          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (activity.fieldName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.fieldName!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Time
          Text(
            activity.timeAgo,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
