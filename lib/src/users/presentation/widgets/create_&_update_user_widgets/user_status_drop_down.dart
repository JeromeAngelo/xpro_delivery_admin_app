import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';
import 'package:xpro_delivery_admin_app/core/enums/user_status_enum.dart';

class UserStatusDropdown extends StatefulWidget {
  final Function(UserStatusEnum) onStatusSelected;
  final UserStatusEnum initialValue;

  const UserStatusDropdown({
    super.key,
    required this.onStatusSelected,
    this.initialValue = UserStatusEnum.active,
  });

  @override
  State<UserStatusDropdown> createState() => _UserStatusDropdownState();
}

class _UserStatusDropdownState extends State<UserStatusDropdown> {
  late UserStatusEnum _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // Create dropdown items from UserStatusEnum
    final dropdownItems = UserStatusEnum.values.map((status) {
      final label = status == UserStatusEnum.active ? 'Active' : 'Suspended';
      final icon = status == UserStatusEnum.active
          ? Icon(Icons.check_circle, color: Colors.green.shade600)
          : Icon(Icons.block, color: Colors.red.shade600);

      return DropdownItem<UserStatusEnum>(
        value: status,
        label: label,
        icon: icon,
        uniqueId: status.toString(),
      );
    }).toList();

    return AppDropdownField<UserStatusEnum>(
      label: 'User Status',
      value: _selectedStatus,
      items: dropdownItems,
      onChanged: (status) {
        if (status != null) {
          setState(() {
            _selectedStatus = status;
          });
          widget.onStatusSelected(status);
        }
      },
      required: true,
      hintText: 'Select user status',
      helperText: 'Suspended users cannot log in to the system',
    );
  }
}
