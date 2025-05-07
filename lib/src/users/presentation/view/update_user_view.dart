import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/data/models/auth_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/data/model/user_role_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/domain/entity/user_role_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/core/enums/user_status_enum.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/create_&_update_user_widgets/user_forms_button.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/create_&_update_user_widgets/user_info_fields.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/create_&_update_user_widgets/user_role_drop_down.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/create_&_update_user_widgets/user_status_drop_down.dart';

import 'dart:io';

class UpdateUserView extends StatefulWidget {
  final String userId;

  const UpdateUserView({super.key, required this.userId});

  @override
  State<UpdateUserView> createState() => _UpdateUserViewState();
}

class _UpdateUserViewState extends State<UpdateUserView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _oldPasswordController = TextEditingController(); // Add controller for old password

  // Selected values
  UserRoleEntity? _selectedRole;
  UserStatusEnum _selectedStatus = UserStatusEnum.active;
  File? _selectedProfilePic;
  String? _initialProfilePic;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isDataLoaded = false;
  GeneralUserModel? _originalUser;
  bool _isChangingPassword = false; // Track if user is changing password

  @override
  void initState() {
    super.initState();
    // Load user data when the screen initializes
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Fetch user data by ID
    context.read<GeneralUserBloc>().add(GetUserByIdEvent(widget.userId));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _oldPasswordController.dispose(); // Dispose old password controller
    super.dispose();
  }

  void _populateFormFields(GeneralUserModel user) {
    if (_isDataLoaded) return; // Prevent multiple population

    setState(() {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _selectedRole = user.roleId as UserRoleModel;
      _selectedStatus = user.status ?? UserStatusEnum.active;
      _initialProfilePic = user.profilePic;
      _originalUser = user;
      _isDataLoaded = true;

      // Add a debug print to verify the ID is loaded
      debugPrint('Loaded user with ID: ${_originalUser?.id}');
    });
  }

  // Function to update a user
  void _updateUser() {
    if (!_formKey.currentState!.validate()) {
      // Form validation failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate required selections
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a user role'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user is trying to change password
    final isChangingPassword = _passwordController.text.isNotEmpty;
    
    // If changing password, validate old password is provided
    if (isChangingPassword && _oldPasswordController.text.isEmpty) {
      // Show dialog to enter old password
      _showOldPasswordDialog();
      return;
    }

    // Create the updated user model
    final updatedUser = GeneralUserModel(
      id: widget.userId, // Use the ID from the widget parameter
      name: _nameController.text,
      email: _emailController.text,
      roleModel: _selectedRole as UserRoleModel,
      roleId: _selectedRole?.id,
      status: _selectedStatus,
      // Only include password fields if changing password
      password: isChangingPassword ? _passwordController.text : null,
      passwordConfirm: isChangingPassword ? _passwordConfirmController.text : null,
      oldPassword: isChangingPassword ? _oldPasswordController.text : null, // Include old password
    );

    // Add a debug print to verify the ID is present
    debugPrint('Updating user with ID: ${updatedUser.id}');

    // Set loading state
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Dispatch the update event
    context.read<GeneralUserBloc>().add(UpdateUserEvent(updatedUser));
  }

  // Show dialog to enter old password
  void _showOldPasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Current Password Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'To change the password, please enter the current password for security verification.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear password fields and close dialog
                _passwordController.clear();
                _passwordConfirmController.clear();
                _oldPasswordController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Continue with update after dialog is closed
                _updateUser();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.usersNavigationItems();

    return BlocListener<GeneralUserBloc, GeneralUserState>(
      listener: (context, state) {
        if (state is GeneralUserLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is UserByIdLoaded) {
          setState(() {
            _isLoading = false;
          });

          // Populate form fields with user data
          _populateFormFields(state.user as GeneralUserModel);
        } else if (state is UserUpdated) {
          setState(() {
            _isLoading = false;
          });

          // First show the success message
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final snackBar = SnackBar(
            content: Text('User ${state.user.name} updated successfully'),
            backgroundColor: Colors.green,
          );

          // Then navigate after a short delay to ensure the SnackBar is shown
          Future.delayed(Duration.zero, () {
            scaffoldMessenger.showSnackBar(snackBar);

            // Navigate back to user details or list
            Future.delayed(const Duration(milliseconds: 500), () {
              context.go('/all-users');
            });
          });
        } else if (state is GeneralUserError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });

          // Check if error is related to old password
          if (state.message.contains('oldPassword') || 
              state.message.contains('Cannot be blank')) {
            // Show specific error for old password
            _showOldPasswordDialog();
          } else {
            // Show general error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: DesktopLayout(
        navigationItems: navigationItems,
        currentRoute: '/all-users',
        onNavigate: (route) {
          // Handle navigation
          context.go(route);
        },
        onThemeToggle: () {
          // Handle theme toggle
        },
        onNotificationTap: () {
          // Handle notification tap
        },
        onProfileTap: () {
          // Handle profile tap
        },
        child: FormLayout(
          title: 'Update User',
          isLoading: _isLoading,
          actions: [
            UserFormButtons(
              onCancel: () {
                // Navigate back to user details
                context.go('/all-users/${widget.userId}');
              },
              onSave: _updateUser,
              // No need for "Save and Create Another" in update view
              onSaveAndCreateAnother: () {},
              isLoading: _isLoading,
            ),
          ],
          children: [
            // User Information Form Fields
            UserInfoFormFields(
              nameController: _nameController,
              emailController: _emailController,
              passwordController: _passwordController,
              formKey: _formKey,
              passwordConfirmController: _passwordConfirmController,
              initialProfilePic: _initialProfilePic,
              onProfilePicSelected: (file) {
                setState(() {
                  _selectedProfilePic = file;
                });
              },
              onPasswordChanged: (value) {
                // Track if user is changing password
                setState(() {
                  _isChangingPassword = value.isNotEmpty;
                });
              },
            ),

            const SizedBox(height: 24),

            // User Role Dropdown
            UserRoleDropdown(
              onRoleSelected: (role) {
                setState(() {
                  _selectedRole = role;
                });
              },
              initialValue: _selectedRole,
            ),

            const SizedBox(height: 24),

            // User Status Dropdown
            UserStatusDropdown(
              onStatusSelected: (status) {
                setState(() {
                  _selectedStatus = status;
                });
              },
              initialValue: _selectedStatus,
            ),

            // Display error message if any
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Container(
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
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Add a note about password fields
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Leave password fields empty if you don\'t want to change the password. If you enter a new password, you will be prompted for the current password.',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
