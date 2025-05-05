import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/entity/auth_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/presentation/bloc/auth_event.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/user_list_widgets/user_role_chip.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/user_list_widgets/user_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class UserDataTable extends StatelessWidget {
  final List<AuthEntity> users;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const UserDataTable({
    super.key,
    required this.users,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DataTableLayout(
      title: 'Users',
      searchBar: UserSearchBar(
        controller: searchController,
        searchQuery: searchQuery,
        onSearchChanged: onSearchChanged,
      ),
      onCreatePressed: () {
        // Navigate to create user screen
        context.go('/users/create');
      },
      createButtonText: 'Create User',
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Role')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Last Login')),
        DataColumn(label: Text('Actions')),
      ],
      rows: users.map((user) {
        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: user.profilePic != null && user.profilePic!.isNotEmpty
                        ? NetworkImage(user.profilePic!)
                        : null,
                    child: user.profilePic == null || user.profilePic!.isEmpty
                        ? Text(
                            user.name?.isNotEmpty == true
                                ? user.name![0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(user.name ?? 'N/A'),
                  ),
                ],
              ),
            ),
            DataCell(Text(user.email ?? 'N/A')),
            DataCell(UserRoleChip(user: user)),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isActive ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: user.isActive ? Colors.green[800] : Colors.red[800],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            DataCell(Text(
              user.lastLogin != null
                  ? DateFormat('MMM dd, yyyy hh:mm a').format(user.lastLogin!)
                  : 'Never',
            )),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'View Details',
                  onPressed: () {
                    // View user details
                    if (user.id != null) {
                      context.read<AuthBloc>().add(GetUserByIdEvent(user.id!));
                      context.go('/users/${user.id}');
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Edit',
                  onPressed: () {
                    // Edit user
                    if (user.id != null) {
                      context.go('/users/edit/${user.id}');
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    color: user.isActive ? Colors.red : Colors.green,
                  ),
                  tooltip: user.isActive ? 'Deactivate' : 'Activate',
                  onPressed: () {
                    // Toggle user status
                    _showStatusToggleConfirmationDialog(context, user);
                  },
                ),
              ],
            )),
          ],
        );
      }).toList(),
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      isLoading: isLoading, onFiltered: () {  }, dataLength: '${users.length}', onDeleted: () {  },
    );
  }

  void _showStatusToggleConfirmationDialog(BuildContext context, AuthEntity user) {
    final bool isActivating = !user.isActive;
    
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isActivating ? 'Activate User' : 'Deactivate User'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  isActivating
                      ? 'Are you sure you want to activate ${user.name}?'
                      : 'Are you sure you want to deactivate ${user.name}?',
                ),
                const SizedBox(height: 10),
                Text(
                  isActivating
                      ? 'This will allow the user to log in and access the system.'
                      : 'This will prevent the user from logging in and accessing the system.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                isActivating ? 'Activate' : 'Deactivate',
                style: TextStyle(
                  color: isActivating ? Colors.green : Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Here you would add the logic to toggle the user status
                // For example:
                // context.read<AuthBloc>().add(ToggleUserStatusEvent(user.id!));
              },
            ),
          ],
        );
      },
    );
  }
}
