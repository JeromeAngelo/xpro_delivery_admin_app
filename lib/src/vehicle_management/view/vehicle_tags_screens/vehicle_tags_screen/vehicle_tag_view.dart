import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/domain/entity/vehicle_tag_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/vehicle_management/widgets/vehicle_widgets/vehicle_list_widgets/vehicle_tag_data_table.dart';

class VehicleTagView extends StatefulWidget {
  const VehicleTagView({super.key});

  @override
  State<VehicleTagView> createState() => _VehicleTagViewState();
}

class _VehicleTagViewState extends State<VehicleTagView> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<VehicleTagBloc>().add(const GetVehicleTagsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems =
        AppNavigationItems.vehicleManagementNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/vehicle-tags',
      onNavigate: (route) {
        context.go(route);
      },
      onThemeToggle: () {},
      onNotificationTap: () {},
      onProfileTap: () {},
      child: BlocBuilder<VehicleTagBloc, VehicleTagState>(
        builder: (context, state) {
          if (state is VehicleTagInitial) {
            context.read<VehicleTagBloc>().add(const GetVehicleTagsEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VehicleTagLoading) {
            return VehicleTagDataTable(
              tags: const [],
              isLoading: true,
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            );
          }

          if (state is VehicleTagError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VehicleTagBloc>().add(
                        const GetVehicleTagsEvent(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is VehicleTagsLoaded || state is VehicleTagEmpty) {
            List<VehicleTagEntity> tags = [];
            if (state is VehicleTagsLoaded) {
              tags = state.vehicleTags;
            }

            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              tags =
                  tags.where((tag) {
                    return (tag.label?.toLowerCase().contains(query) ??
                            false) ||
                        (tag.description?.toLowerCase().contains(query) ??
                            false) ||
                        (tag.stickerNumber?.toLowerCase().contains(query) ??
                            false);
                  }).toList();
            }

            _totalPages = (tags.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > tags.length
                    ? tags.length
                    : startIndex + _itemsPerPage;

            final paginatedTags =
                startIndex < tags.length
                    ? tags.sublist(startIndex, endIndex)
                    : <VehicleTagEntity>[];

            return VehicleTagDataTable(
              tags: paginatedTags,
              isLoading: false,
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                });
              },
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
