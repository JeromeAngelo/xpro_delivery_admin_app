import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/presentation/bloc/bloc/user_roles_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/presentation/bloc/bloc/user_roles_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/presentation/bloc/bloc/user_roles_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/domain/entity/user_role_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';

class UserRoleDropdown extends StatefulWidget {
  final Function(UserRoleEntity?) onRoleSelected;
  final UserRoleEntity? initialValue;

  const UserRoleDropdown({
    super.key,
    required this.onRoleSelected,
    this.initialValue,
  });

  @override
  State<UserRoleDropdown> createState() => _UserRoleDropdownState();
}

class _UserRoleDropdownState extends State<UserRoleDropdown> {
  UserRoleEntity? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialValue;
    // Load user roles when the widget initializes
    context.read<UserRolesBloc>().add(GetAllUserRolesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRolesBloc, UserRolesState>(
      builder: (context, state) {
        // Show loading indicator while fetching roles
        if (state is UserRolesLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Show error message if roles couldn't be loaded
        if (state is UserRolesErrors) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Role',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Failed to load user roles',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.message,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          context.read<UserRolesBloc>().add(GetAllUserRolesEvent());
                        },
                        tooltip: 'Retry',
                        color: Colors.red.shade700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Show dropdown when roles are loaded
        if (state is AllUsersLoaded) {
          final roles = state.userRoles;
          
          // Create dropdown items from roles
          final dropdownItems = roles.map((role) => DropdownItem<UserRoleEntity>(
                value: role,
                label: role.name ?? 'Unnamed Role',
                uniqueId: role.id ?? 'unknown',
                searchTerms: [role.name ?? '', ...role.permissions],
              )).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 24.0),
                child: Text(
                  'User Role & Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              
              // Role dropdown
              AppDropdownField<UserRoleEntity>(
                label: 'User Role',
                value: _selectedRole,
                items: dropdownItems,
                onChanged: (role) {
                  setState(() {
                    _selectedRole = role;
                  });
                  widget.onRoleSelected(role);
                },
                required: true,
                hintText: 'Select user role',
                helperText: 'The role determines what permissions the user will have',
              ),
            ],
          );
        }

        // Default fallback
        return const SizedBox.shrink();
      },
    );
  }
}
