import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/provider/theme_provider.dart';
class DefaultDrawer extends StatefulWidget {
  const DefaultDrawer({super.key});

  @override
  State<DefaultDrawer> createState() => _DefaultDrawerState();
}

class _DefaultDrawerState extends State<DefaultDrawer> {
  bool _isThemeExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Drawer(
      elevation: 10,
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: _buildDrawerBody(context),
              ),
            ),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.4),
        border: Border(
          bottom: BorderSide(
            color: scheme.outline.withOpacity(0.12),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/company-logo.png',
            height: 72,
            width: 72,
          ),
          const SizedBox(height: 10),
          Text(
            'X-Pro Delivery Admin',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        _buildDrawerTile(
          context,
          icon: Icons.dashboard,
          title: 'Main Dashboard',
          onTap: () {
            context.go('/main-screen');
          },
        ),
        Divider(color: scheme.outline.withOpacity(0.12), height: 1),

        _buildDrawerTile(
          context,
          icon: Icons.bar_chart,
          title: 'Reports',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/reports');
          },
        ),

        _buildDrawerTile(
          context,
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/settings');
          },
        ),

        Theme(
          data: theme.copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            leading: Icon(
              Icons.color_lens,
              color: scheme.onSurface,
            ),
            title: Text(
              'Theme',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            iconColor: scheme.onSurface,
            collapsedIconColor: scheme.onSurface,
            initiallyExpanded: _isThemeExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isThemeExpanded = expanded;
              });
            },
            children: [_buildThemeOptions(context)],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: scheme.onSurface),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: Row(
            children: [
              Icon(
                Icons.light_mode,
                size: 20,
                color: themeProvider.themeMode == ThemeMode.light
                    ? scheme.primary
                    : scheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 12),
              const Text('Light'),
            ],
          ),
          value: ThemeMode.light,
          groupValue: themeProvider.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
          activeColor: scheme.primary,
          dense: true,
        ),
        RadioListTile<ThemeMode>(
          title: Row(
            children: [
              Icon(
                Icons.brightness_auto,
                size: 20,
                color: themeProvider.themeMode == ThemeMode.system
                    ? scheme.primary
                    : scheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 12),
              const Text('System'),
            ],
          ),
          value: ThemeMode.system,
          groupValue: themeProvider.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
          activeColor: scheme.primary,
          dense: true,
        ),
        RadioListTile<ThemeMode>(
          title: Row(
            children: [
              Icon(
                Icons.dark_mode,
                size: 20,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? scheme.primary
                    : scheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 12),
              const Text('Dark'),
            ],
          ),
          value: ThemeMode.dark,
          groupValue: themeProvider.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
          activeColor: scheme.primary,
          dense: true,
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<GeneralUserBloc, GeneralUserState>(
        builder: (context, state) {
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: scheme.error.withOpacity(0.08),
            leading: Icon(Icons.logout, color: scheme.error),
            title: Text(
              'Logout',
              style: TextStyle(
                color: scheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<GeneralUserBloc>().add(
                          const UserSignOutEvent(),
                        );
                        context.go('/');
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(color: scheme.error),
                      ),
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