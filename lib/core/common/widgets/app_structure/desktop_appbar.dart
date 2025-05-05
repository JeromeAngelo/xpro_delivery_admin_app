// ignore_for_file: unused_local_variable


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_state.dart';

class DesktopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onThemeToggle;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const DesktopAppBar({
    super.key,
    required this.onThemeToggle,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeneralUserBloc, GeneralUserState>(
      builder: (context, state) {
        // Default username if not authenticated or loading
        String userName = 'User';
        String? userEmail;
        String? userAvatar;
        bool isAuthenticated = false;

        // Check the state and update user information
        if (state is UserAuthenticated) {
          userName = state.user.name ?? 'User';
          userEmail = state.user.email;
          userAvatar = state.user.profilePic;
          isAuthenticated = true;
        } else if (state is GeneralUserLoaded) {
          userName = state.user.name ?? 'User';
          userEmail = state.user.email;
          userAvatar = state.user.profilePic;
          isAuthenticated = true;
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // App Logo
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  // If you don't have a logo yet, use a placeholder
                  errorBuilder:
                      (context, error, stackTrace) => const Text(
                        'X-Pro Delivery',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                ),
              ),

              // Search Bar
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
              ),

              // Theme Toggle
              IconButton(
                icon: Icon(
                  Icons.desktop_windows,
                  color: Theme.of(context).colorScheme.surface,
                ),
                onPressed: onThemeToggle,
                tooltip: 'Toggle theme',
              ),

              // Notifications
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.surface,
                ),
                onPressed: onNotificationTap,
                tooltip: 'Notifications',
              ),

              // User Profile

              // User Profile
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _buildProfileAvatar(userName, userAvatar),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ],
                      ),
                      if (isAuthenticated)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          offset: const Offset(0, 40),
                          onSelected: (value) {
                            if (value == 'profile') {
                              onProfileTap();
                            } else if (value == 'logout') {
                              context.read<GeneralUserBloc>().add(
                                 UserSignOutEvent(),
                              );
                              context.go('/');
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'profile',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person, size: 16),
                                      SizedBox(width: 8),
                                      Text('Profile'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'settings',
                                  child: Row(
                                    children: [
                                      Icon(Icons.settings, size: 16),
                                      SizedBox(width: 8),
                                      Text('Settings'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout, size: 16),
                                      SizedBox(width: 8),
                                      Text('Logout'),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Add this method to the class:
  Widget _buildProfileAvatar(String userName, String? avatarUrl) {
    return Builder(
      builder: (context) {
        if (avatarUrl == null || avatarUrl.isEmpty) {
          // No avatar URL, show initials
          return CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        // Try to validate the URL
        bool isValidUrl = false;
        try {
          final uri = Uri.parse(avatarUrl);
          isValidUrl =
              uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
        } catch (e) {
          debugPrint('Invalid avatar URL: $e');
        }

        if (!isValidUrl) {
          // Invalid URL, show initials
          return CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        // Valid URL, try to load image with error handling
        return ClipOval(
          child: Image.network(
            avatarUrl,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading avatar: $error');
              // On error, show initials
              return CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              // Show a loading indicator while the image is loading
              return CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
