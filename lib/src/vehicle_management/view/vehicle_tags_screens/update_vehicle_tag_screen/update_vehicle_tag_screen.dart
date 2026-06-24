import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/domain/entity/vehicle_tag_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_buttons.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_tags_enums.dart';
import 'package:xpro_delivery_admin_app/core/services/core_utils.dart';
import 'package:xpro_delivery_admin_app/src/vehicle_management/widgets/vehicle_tag_widgets/update_vehicle_tag_widgets/update_vehicle_tag_form.dart';

class UpdateVehicleTagScreen extends StatefulWidget {
  final String tagId;

  const UpdateVehicleTagScreen({super.key, required this.tagId});

  @override
  State<UpdateVehicleTagScreen> createState() => _UpdateVehicleTagScreenState();
}

class _UpdateVehicleTagScreenState extends State<UpdateVehicleTagScreen> {
  final _formKey = GlobalKey<FormState>();

  final _labelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stickerNumberController = TextEditingController();

  DateTime? _expiration;
  List<VehicleTagType> _selectedTypes = [];

  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _hasNavigated = false;
  bool _ready = false;

  late final String _initialTagId = widget.tagId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    _stickerNumberController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    setState(() {
      _isInitializing = true;
    });
    context.read<VehicleTagBloc>().add(LoadVehicleTagByIdEvent(widget.tagId));
  }

  void _populateFromTag(VehicleTagEntity tag) {
    _labelController.text = tag.label ?? '';
    _descriptionController.text = tag.description ?? '';
    _stickerNumberController.text = tag.stickerNumber ?? '';
    _expiration = tag.expiration;
    _selectedTypes = List<VehicleTagType>.from(tag.types ?? []);
  }

  void _tryMarkReady() {
    if (_ready) return;
    setState(() {
      _isInitializing = false;
      _ready = true;
    });
  }

  void _submit() {
    if (_isLoading || !_ready) return;

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

    debugPrint(
      '🚀 [UPDATE VEHICLE TAG] Dispatching UpdateVehicleTagEvent for id=${widget.tagId}',
    );
    context.read<VehicleTagBloc>().add(
      UpdateVehicleTagEvent(
        tagId: widget.tagId,
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
        if (_isInitializing) {
          if (state is VehicleTagLoaded &&
              state.vehicleTag.id == widget.tagId) {
            _populateFromTag(state.vehicleTag);
            _tryMarkReady();
          } else if (state is VehicleTagError) {
            setState(() {
              _isInitializing = false;
              _errorMessage = state.message;
            });
          }
          return;
        }

        if (!_isLoading) return;

        if (state is VehicleTagUpdated) {
          debugPrint(
            '✅ [UPDATE VEHICLE TAG] Vehicle tag updated: ${state.vehicleTag.id}',
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
                  'Vehicle tag updated successfully',
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
            '❌ [UPDATE VEHICLE TAG] Vehicle tag error: ${state.message}',
          );
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
          CoreUtils.showSnackBar(
            context,
            'Failed to update vehicle tag: ${state.message}',
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
            title: 'Update Vehicle Tag',
            isLoading: _isLoading || _isInitializing,
            actions: [
              FormCancelButton(
                label: 'Cancel',
                onPressed: () {
                  if (!_isLoading) context.go('/vehicle-tags');
                },
              ),
              const SizedBox(width: 16),
              FormSubmitButton(
                label:
                    _isLoading
                        ? 'Saving...'
                        : (_isInitializing
                            ? 'Loading...'
                            : 'Update Vehicle Tag'),
                onPressed: (_isLoading || !_ready) ? null : _submit,
                icon: _isLoading ? Icons.hourglass_empty : Icons.save_outlined,
              ),
            ],
            children: [
              UpdateVehicleTagForm(
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
                errorMessage: _errorMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
