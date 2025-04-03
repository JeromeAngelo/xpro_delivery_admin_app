import 'package:desktop_app/core/common/widgets/app_structure/desktop_appbar.dart';
import 'package:desktop_app/core/common/widgets/app_structure/navigation_item.dart';
import 'package:flutter/material.dart';

class DesktopLayout extends StatelessWidget {
  final List<NavigationItem> navigationItems;
  final String currentRoute;
  final Function(String) onNavigate;
  final VoidCallback onThemeToggle;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final Widget child;
  final String? title;
  final bool disableScrolling;

  const DesktopLayout({
    super.key,
    required this.navigationItems,
    required this.currentRoute,
    required this.onNavigate,
    required this.onThemeToggle,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.child,
    this.title,
    this.disableScrolling = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DesktopAppBar(
        onThemeToggle: onThemeToggle,
        onNotificationTap: onNotificationTap,
        onProfileTap: onProfileTap,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content area with side navigation and content
          Expanded(
            child: Row(
              children: [
                // Side Navigation
                SideNavigation(
                  items: navigationItems,
                  onNavigate: onNavigate,
                  currentRoute: currentRoute,
                ),

                // Main Content
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
                    child: _buildContent(context),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text(
                'Xpro Admin app 2025',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // If scrolling is disabled or the child is already a scrollable widget,
    // just return the child with minimal wrapping
    if (disableScrolling) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional title
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

          // Main content - using Expanded to fill available space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: child,
            ),
          ),
        ],
      );
    }

    // Otherwise, wrap the content in a SingleChildScrollView
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional title
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: child,
          ),

          // Bottom padding
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
