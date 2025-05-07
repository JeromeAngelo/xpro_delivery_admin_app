import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/user_status_enum.dart';

class AllUserStatusChip extends StatelessWidget {
  const AllUserStatusChip({super.key, required this.user});

  final GeneralUserEntity user;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _getStatusText(user.status),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _getStatusColor(user.status),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  String _getStatusText(UserStatusEnum? status) {
    if (status == null) return 'Unknown';

    switch (status) {
      case UserStatusEnum.active:
        return 'Active';
      case UserStatusEnum.suspended:
        return 'Suspended';
    }
  }

  Color _getStatusColor(UserStatusEnum? status) {
    if (status == null) return Colors.grey;

    switch (status) {
      case UserStatusEnum.active:
        return Colors.blue;
      case UserStatusEnum.suspended:
        return Colors.red;
    }
  }
}
