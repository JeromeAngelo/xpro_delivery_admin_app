import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/entity/auth_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/auth_roles_enum.dart';
import 'package:flutter/material.dart';

class UserRoleChip extends StatelessWidget {
  final AuthEntity user;

  const UserRoleChip({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final role = user.role;
    
    // Default values
    Color color = Colors.grey;
    String label = 'Unknown';
    
    if (role != null) {
      switch (role) {
        case AdminRole.superAdmin:
          color = Colors.red;
          label = 'Admin';
          break;
        case AdminRole.manager:
          color = Colors.orange;
          label = 'Manager';
          break;
        case AdminRole.dispatcher:
          color = Colors.blue;
          label = 'Dispatcher';
          break;
        case AdminRole.viewer:
          color = Colors.green;
          label = 'Viewer';
          break;
      }
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
