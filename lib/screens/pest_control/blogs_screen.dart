import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Blogs screen for pest control articles and tips
class BlogsScreen extends StatelessWidget {
  const BlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pest Control Blogs'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBlogCard(
            context: context,
            title: 'Common Crop Pests in Bangladesh',
            category: 'Identification',
            readTime: '5 min read',
            description:
                'Learn to identify the most common pests affecting crops in Bangladesh including aphids, whiteflies, and stem borers.',
            imageIcon: '🐛',
          ),
          _buildBlogCard(
            context: context,
            title: 'Organic Pest Control Methods',
            category: 'Treatment',
            readTime: '8 min read',
            description:
                'Discover natural and organic solutions for pest control including neem oil, companion planting, and biological control.',
            imageIcon: '🌿',
          ),
          _buildBlogCard(
            context: context,
            title: 'Rice Diseases: Prevention & Treatment',
            category: 'Disease Management',
            readTime: '6 min read',
            description:
                'Complete guide to rice diseases like blast, sheath blight, and bacterial leaf blight with prevention tips.',
            imageIcon: '🌾',
          ),
          _buildBlogCard(
            context: context,
            title: 'Integrated Pest Management (IPM)',
            category: 'Strategy',
            readTime: '10 min read',
            description:
                'Learn about IPM approach combining cultural, biological, and chemical methods for sustainable pest control.',
            imageIcon: '📊',
          ),
          _buildBlogCard(
            context: context,
            title: 'Tomato Pest & Disease Guide',
            category: 'Crop-Specific',
            readTime: '7 min read',
            description:
                'Common tomato problems including early blight, hornworms, and whiteflies with treatment recommendations.',
            imageIcon: '🍅',
          ),
          _buildBlogCard(
            context: context,
            title: 'Safe Use of Pesticides',
            category: 'Safety',
            readTime: '5 min read',
            description:
                'Essential safety guidelines for handling, applying, and storing pesticides to protect yourself and the environment.',
            imageIcon: '⚠️',
          ),
          _buildBlogCard(
            context: context,
            title: 'Beneficial Insects for Your Farm',
            category: 'Biological Control',
            readTime: '6 min read',
            description:
                'Learn about helpful insects like ladybugs, lacewings, and parasitic wasps that naturally control pests.',
            imageIcon: '🐞',
          ),
          _buildBlogCard(
            context: context,
            title: 'Early Detection: Signs of Plant Stress',
            category: 'Prevention',
            readTime: '4 min read',
            description:
                'Recognize early warning signs of pest infestation and disease to take quick action before major damage occurs.',
            imageIcon: '🔍',
          ),
          _buildBlogCard(
            context: context,
            title: 'Seasonal Pest Management Calendar',
            category: 'Planning',
            readTime: '9 min read',
            description:
                'Month-by-month guide for pest management activities in Bangladesh including monitoring and treatment schedules.',
            imageIcon: '📅',
          ),
          _buildBlogCard(
            context: context,
            title: 'Soil Health & Pest Resistance',
            category: 'Prevention',
            readTime: '7 min read',
            description:
                'How healthy soil builds stronger plants that resist pests and diseases naturally through proper nutrition.',
            imageIcon: '🌱',
          ),
        ],
      ),
    );
  }

  Widget _buildBlogCard({
    required BuildContext context,
    required String title,
    required String category,
    required String readTime,
    required String description,
    required String imageIcon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showBlogDetail(
            context: context,
            title: title,
            category: category,
            readTime: readTime,
            description: description,
            imageIcon: imageIcon,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    imageIcon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Read Time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          readTime,
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlogDetail({
    required BuildContext context,
    required String title,
    required String category,
    required String readTime,
    required String description,
    required String imageIcon,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Icon
              Center(
                child: Text(
                  imageIcon,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 16),
              // Category & Read Time
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    readTime,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.black,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Full content placeholder
              const Text(
                'This is a sample blog article. In a production app, you would fetch full article content from your backend or CMS.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Saved to reading list')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.bookmark_border),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Sharing options coming soon')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
