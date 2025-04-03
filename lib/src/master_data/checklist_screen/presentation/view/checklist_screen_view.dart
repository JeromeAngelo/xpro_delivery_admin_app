import 'package:desktop_app/core/common/app/features/checklist/domain/entity/checklist_entity.dart';
import 'package:desktop_app/core/common/app/features/checklist/presentation/bloc/checklist_bloc.dart';
import 'package:desktop_app/core/common/app/features/checklist/presentation/bloc/checklist_event.dart';
import 'package:desktop_app/core/common/app/features/checklist/presentation/bloc/checklist_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:desktop_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:desktop_app/src/master_data/checklist_screen/presentation/widgets/checklist_screen_widgets/checklist_data_table.dart';
import 'package:desktop_app/src/master_data/checklist_screen/presentation/widgets/checklist_screen_widgets/checklist_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ChecklistScreenView extends StatefulWidget {
  const ChecklistScreenView({super.key});

  @override
  State<ChecklistScreenView> createState() => _ChecklistScreenViewState();
}

class _ChecklistScreenViewState extends State<ChecklistScreenView> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25; // Same as tripticket_screen_view.dart
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load checklists when the screen initializes
    context.read<ChecklistBloc>().add(const GetAllChecklistsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.tripticketNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/checklist', // Match the route in app_navigation_items.dart
      onNavigate: (route) {
        // Handle navigation using GoRouter
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
      child: BlocBuilder<ChecklistBloc, ChecklistState>(
        builder: (context, state) {
          // Handle different states
          if (state is ChecklistInitial) {
            // Initial state, trigger loading
            context.read<ChecklistBloc>().add(const GetAllChecklistsEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChecklistLoading) {
            return ChecklistDataTable(
              checklists: [],
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

          if (state is ChecklistError) {
            return ChecklistErrorWidget(errorMessage: state.message);
          }

          if (state is AllChecklistsLoaded) {
            List<ChecklistEntity> checklists = state.checklists;

            // Filter checklists based on search query
            if (_searchQuery.isNotEmpty) {
              checklists = checklists.where((checklist) {
                final query = _searchQuery.toLowerCase();
                return (checklist.objectName?.toLowerCase().contains(query) ?? false) ||
                       (checklist.status?.toLowerCase().contains(query) ?? false);
              }).toList();
            }

            // Calculate total pages
            _totalPages = (checklists.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate checklists
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex = startIndex + _itemsPerPage > checklists.length 
                ? checklists.length 
                : startIndex + _itemsPerPage;
            
            final paginatedChecklists = startIndex < checklists.length 
                ? checklists.sublist(startIndex, endIndex) 
                : [];

            return ChecklistDataTable(
              checklists: paginatedChecklists as List<ChecklistEntity>,
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
                });
                // If search query is empty, refresh the checklists list
                if (value.isEmpty) {
                  context.read<ChecklistBloc>().add(const GetAllChecklistsEvent());
                }
              },
            );
          }

          // Default fallback
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
