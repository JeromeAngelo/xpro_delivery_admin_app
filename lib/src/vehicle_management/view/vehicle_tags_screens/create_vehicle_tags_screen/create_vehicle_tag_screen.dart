import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_buttons.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_tags_enums.dart';
import 'package:xpro_delivery_admin_app/core/services/core_utils.dart';
import 'package:xpro_delivery_admin_app/src/vehicle_management/widgets/vehicle_tag_widgets/create_vehicle_tag_widgets/vehicle_tag_data_form.dart';

class CreateVehicleTagScreen extends StatefulWidget {
  const CreateVehicleTagScreen({super.key});

  @override
  State<CreateVehicleTagScreen> createState() => _CreateVehicleTagScreenState();
}

class _CreateVehicleTagScreenState extends State<CreateVehicleTagScreen> {
  final _formKey = GlobalKey<FormState>();

  final _labelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stickerNumberController = TextEditingController();

  DateTime? _expiration;
  List<VehicleTagType> _selectedTypes = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasNavigated = false;

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    _stickerNumberController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      CoreUtils.showSnackBar(context, 'Please fill all required fields');
      return;
    }

    if (_selectedTypes.isEmpty) {
      CoreUtils.showSnackBar(context, 'Please select at least one tag type');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasNavigated = false;
    });

    debugPrint('🚀 [CREATE VEHICLE TAG] Dispatching CreateVehicleTagEvent');
    context.read<VehicleTagBloc>().add(
      CreateVehicleTagEvent(
        label: _labelController.text.trim(),
        tagType: _selectedTypes.map((t) => t.name).toList(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems =
        AppNavigationItems.vehicleManagementNavigationItems();

    return BlocListener<VehicleTagBloc, VehicleTagState>(
      listener: (context, state) {
        if (!_isLoading) return;

        if (state is VehicleTagCreated) {
          debugPrint(
            '✅ [CREATE VEHICLE TAG] Vehicle tag created: ${state.vehicleTag.id}',
          );
          if (mounted && !_hasNavigated) {
            setState(() {
              _isLoading = false;
              _errorMessage = null;
              _hasNavigated = true;
            });

            final messenger = ScaffoldMessenger.of(context);
            final textColor = Theme.of(context).colorScheme.surface;
            final bgColor = Theme.of(context).colorScheme.primary;
            final router = GoRouter.of(context);

            messenger.removeCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Vehicle tag created successfully',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: bgColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );

            Future.delayed(const Duration(milliseconds: 700), () {
              if (!mounted) return;
              router.go('/vehicle-tags');
            });
          }
        } else if (state is VehicleTagError) {
          debugPrint(
            '❌ [CREATE VEHICLE TAG] Vehicle tag error: ${state.message}',
          );
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
          CoreUtils.showSnackBar(
            context,
            'Failed to create vehicle tag: ${state.message}',
          );
        }
      },
      child: DesktopLayout(
        navigationItems: navigationItems,
        currentRoute: '/vehicle-tags',
        onNavigate: (route) {
          if (!_isLoading) context.go(route);
        },
        onThemeToggle: () {},
        onNotificationTap: () {},
        onProfileTap: () {},
        disableScrolling: true,
        child: Form(
          key: _formKey,
          child: FormLayout(
            title: 'Create Vehicle Tag',
            isLoading: _isLoading,
            actions: [
              FormCancelButton(
                label: 'Cancel',
                onPressed: () {
                  if (!_isLoading) context.go('/vehicle-tags');
                },
              ),
              const SizedBox(width: 16),
              FormSubmitButton(
                label: _isLoading ? 'Saving...' : 'Create Vehicle Tag',
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading ? Icons.hourglass_empty : Icons.add,
              ),
            ],
            children: [
              VehicleTagDataForm(
                labelController: _labelController,
                descriptionController: _descriptionController,
                stickerNumberController: _stickerNumberController,
                expiration: _expiration,
                onExpirationChanged: (date) {
                  setState(() {
                    _expiration = date;
                  });
                },
                selectedTypes: _selectedTypes,
                onSelectedTypesChanged: (types) {
                  setState(() {
                    _selectedTypes = types;
                  });
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
