import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_textfield.dart';

class UserInfoFormFields extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;
  final GlobalKey<FormState> formKey;
  final Function(File?)? onProfilePicSelected;
  final String? initialProfilePic;

  const UserInfoFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmController,
    required this.formKey,
    this.onProfilePicSelected,
    this.initialProfilePic,
  });

  @override
  State<UserInfoFormFields> createState() => _UserInfoFormFieldsState();
}

class _UserInfoFormFieldsState extends State<UserInfoFormFields> {
  File? _selectedImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'User Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Profile Picture (Optional)
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _getProfileImage(),
                        child: _getProfileImagePlaceholder(),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Profile Picture (Optional)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_selectedImage != null)
                  TextButton(
                    onPressed: _clearSelectedImage,
                    child: const Text('Remove'),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Name field
          AppTextField(
            label: 'Full Name',
            hintText: 'Enter user\'s full name',
            controller: widget.nameController,
            required: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),

          // Email field
          AppTextField(
            label: 'Email Address',
            hintText: 'Enter user\'s email address',
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            required: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email address is required';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),

          // Password field
          AppTextField(
            label: 'Password',
            hintText: 'Enter password',
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            required: true,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
            helperText: 'Password must be at least 8 characters long',
          ),

          // Confirm Password field
          AppTextField(
            label: 'Confirm Password',
            hintText: 'Confirm password',
            controller: widget.passwordConfirmController,
            obscureText: _obscureConfirmPassword,
            required: true,
            suffix: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != widget.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Method to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    // Show a dialog to choose between camera and gallery
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library),
                        SizedBox(width: 10),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    _processSelectedImage(image);
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(width: 10),
                        Text('Camera'),
                      ],
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    _processSelectedImage(image);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _processSelectedImage(XFile? image) {
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      
      // Notify parent widget about the selected image
      if (widget.onProfilePicSelected != null) {
        widget.onProfilePicSelected!(_selectedImage);
      }
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
    
    // Notify parent widget that image was cleared
    if (widget.onProfilePicSelected != null) {
      widget.onProfilePicSelected!(null);
    }
  }

  // Helper method to get the profile image
  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (widget.initialProfilePic != null && widget.initialProfilePic!.isNotEmpty) {
      return NetworkImage(widget.initialProfilePic!);
    }
    return null;
  }

  // Helper method to get the placeholder when no image is selected
  Widget? _getProfileImagePlaceholder() {
    if (_selectedImage == null && (widget.initialProfilePic == null || widget.initialProfilePic!.isEmpty)) {
      return const Icon(
        Icons.person,
        size: 50,
        color: Colors.grey,
      );
    }
    return null;
  }
}
