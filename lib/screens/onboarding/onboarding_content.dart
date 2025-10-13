import 'package:flutter/material.dart';

/// Model class for onboarding content
class OnboardingContent {
  final String image;
  final String title;
  final String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

/// Widget to display onboarding content
class OnboardingContentWidget extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingContentWidget({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder (using icon for now)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              _getIconForImage(content.image),
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 50),

          // Title
          Text(
            content.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            content.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get icon based on image name
  IconData _getIconForImage(String imageName) {
    switch (imageName) {
      case 'onboarding1.png':
        return Icons.agriculture;
      case 'onboarding2.png':
        return Icons.wb_sunny;
      case 'onboarding3.png':
        return Icons.groups;
      default:
        return Icons.agriculture;
    }
  }
}
