import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/app/features/general_auth/domain/entity/users_entity.dart';
import '../../../../core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/common/app/features/general_auth/presentation/bloc/auth_event.dart';
import '../../../../core/common/app/features/general_auth/presentation/bloc/auth_state.dart';

class DashboardUserMenu extends StatelessWidget {
  const DashboardUserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<GeneralUserBloc, GeneralUserState>(
      builder: (context, state) {
        GeneralUserEntity? currentUser;

        if (state is UserAuthenticated) {
          currentUser = state.user;
        } else if (state is AllUsersLoaded) {
          currentUser = state.authenticatedUser;
        } else if (state is GeneralUserLoaded) {
          currentUser = state.user;
        } else if (state is UserByIdLoaded) {
          currentUser = state.user;
        }

        if (currentUser == null) {
          return IconButton(
            icon: Icon(Icons.account_circle, color: scheme.onSurface),
            onPressed: () => context.go('/'),
          );
        }

        final userName = currentUser.name ?? currentUser.email ?? 'User';
        final firstLetter =
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 40),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: scheme.surface.withOpacity(0.30),
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.surface,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: scheme.surface),
              ],
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: scheme.onSurface, size: 20),
                    const SizedBox(width: 8),
                    Text(currentUser!.email ?? 'N/A'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: scheme.onSurface, size: 20),
                    const SizedBox(width: 8),
                    const Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text(
                      'Are you sure you want to log out?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<GeneralUserBloc>().add(
                            UserSignOutEvent(),
                          );
                          context.go('/');
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (value == 'profile') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('User Profile'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Name'),
                          subtitle: Text(currentUser!.name ?? 'Not set'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text(currentUser.email ?? 'Not set'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'settings') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              }
            },
          ),
        );
      },
    );
  }
}