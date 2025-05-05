import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_state.dart';

class DefaultDrawer extends StatefulWidget {
  const DefaultDrawer({super.key});

  @override
  State<DefaultDrawer> createState() => _DefaultDrawerState();
}

class _DefaultDrawerState extends State<DefaultDrawer> {
  bool _isResourcesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      //   backgroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 10,
      child: Column(
        children: [
          _buildDrawerHeader(context),
          _buildDrawerBody(context),
          const Spacer(),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo.png', height: 80, width: 80),
          const SizedBox(height: 10),
          Text(
            'X-Pro Delivery Admin',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerBody(BuildContext context) {
    return Column(
      children: [
        // Main Dashboard
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Main Dashboard'),
          onTap: () {
            context.go('/main-screen');
          },
        ),
        const Divider(),

        // Resources Expandable Section
        ListTile(
          leading: const Icon(Icons.inventory),
          title: const Text('Resources'),
          trailing: Icon(
            _isResourcesExpanded ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            setState(() {
              _isResourcesExpanded = !_isResourcesExpanded;
            });
          },
        ),

        // Expandable Resources Items
        if (_isResourcesExpanded) ...[
          _buildSubListTile(
            context,
            icon: Icons.people,
            title: 'Users',
            route: '/users',
          ),
          _buildSubListTile(
            context,
            icon: Icons.receipt_long,
            title: 'Trip Tickets',
            route: '/trip-tickets',
          ),
          _buildSubListTile(
            context,
            icon: Icons.store,
            title: 'Customers',
            route: '/customers',
          ),
          _buildSubListTile(
            context,
            icon: Icons.assignment_return,
            title: 'Returns',
            route: '/returns',
          ),
        ],

        const Divider(),

        // Reports
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Reports'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/reports');
          },
        ),

        // Settings
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }

  Widget _buildSubListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
      leading: Icon(icon, size: 20),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<GeneralUserBloc, GeneralUserState>(
        builder: (context, state) {
          return ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            context.read<GeneralUserBloc>().add(const UserSignOutEvent());
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
