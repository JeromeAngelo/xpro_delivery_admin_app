import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/enums/user_role.dart';

class PersonnelRoleChip extends StatelessWidget {
  final UserRole? role;

  const PersonnelRoleChip({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String roleText;

    switch (role) {
      case UserRole.teamLeader:
        color = Colors.blue;
        roleText = 'Team Leader';
        break;
      case UserRole.helper:
        color = Colors.green;
        roleText = 'Helper';
        break;
      default:
        color = Colors.grey;
        roleText = 'Unknown';
    }

    return Chip(
      label: Text(
        roleText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
