import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:xpro_delivery_admin_app/core/enums/user_status_enum.dart';

class UserDetailsDashboard extends StatelessWidget {
  final GeneralUserEntity user;
  final bool isLoading;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserDetailsDashboard({
    super.key,
    required this.user,
    this.isLoading = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Create a list of dashboard items that will be shown for all users
    final List<DashboardInfoItem> commonItems = [
      DashboardInfoItem(
        icon: Icons.person,
        value: user.name ?? 'N/A',
        label: 'Name',
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      DashboardInfoItem(
        icon: Icons.email,
        value: user.email ?? 'N/A',
        label: 'Email',
        iconColor: Colors.blue,
      ),
      DashboardInfoItem(
        icon: Icons.verified_user,
        value: user.role?.name ?? 'N/A',
        label: 'Role',
        iconColor: Colors.green,
      ),
      DashboardInfoItem(
        icon: Icons.circle,
        value: _getStatusText(user.status),
        label: 'Status',
        iconColor: _getStatusColor(user.status),
        backgroundColor: _getStatusColor(user.status).withOpacity(0.1),
      ),
    ];
    
    // Create a list for trip-related items (shown when hasTrip is true)
    final List<DashboardInfoItem> tripItems = [
      DashboardInfoItem(
        icon: Icons.receipt_long,
        value: user.tripNumberId ?? 'None',
        label: 'Current Trip',
        iconColor: Colors.orange,
      ),
      DashboardInfoItem(
        icon: Icons.history,
        value: user.trip_collection.length.toString(),
        label: 'Trip History Count',
        iconColor: Colors.purple,
      ),
    ];
    
    // Create a list for non-trip items (shown when hasTrip is false)
    final List<DashboardInfoItem> nonTripItems = [
      DashboardInfoItem(
        icon: Icons.calendar_today,
        value: _formatDate(user.created),
        label: 'Created At',
        iconColor: Colors.teal,
      ),
      DashboardInfoItem(
        icon: Icons.update,
        value: _formatDate(user.updated),
        label: 'Last Updated',
        iconColor: Colors.amber,
      ),
    ];
    
    // Combine the common items with either trip items or non-trip items based on hasTrip
    final List<DashboardInfoItem> dashboardItems = [
      ...commonItems,
      ...(user.hasTrip == true ? tripItems : nonTripItems),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User basic information dashboard
        DashboardSummary(
          title: 'User Information',
          detailId: user.id,
          isLoading: isLoading,
          onEdit: onEdit,
          onDelete: onDelete,
          items: dashboardItems,
          crossAxisCount: 3,
          childAspectRatio: 3.5,
        ),
        
        const SizedBox(height: 24),
        
      
      ],
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
        return Colors.green;
      case UserStatusEnum.suspended:
        return Colors.red;
     
    }
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }
}
