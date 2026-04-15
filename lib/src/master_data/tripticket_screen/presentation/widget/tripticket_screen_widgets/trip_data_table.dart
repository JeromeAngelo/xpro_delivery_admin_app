import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/tripticket_screen_widgets/trip_delete_dialog.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/tripticket_screen_widgets/trip_search_bar.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/tripticket_screen_widgets/trip_status_chip.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/tripticket_screen_widgets/trip_date_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/presentation/bloc/trip_event.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/common/widgets/filter_widgets/filter_option.dart';

class TripDataTable extends StatefulWidget {
  final List<TripEntity> trips;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  /// Optional: notify parent when filter changes (e.g. reset page)
  final Function(String?)? onFiltered;

  /// Optional: notify parent when date filter changes
  final Function(DateTime? startDate, DateTime? endDate)? onDateFilterChanged;

  /// Optional: initial date filter values
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const TripDataTable({
    super.key,
    required this.trips,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    this.onFiltered,
    this.onDateFilterChanged,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<TripDataTable> createState() => _TripDataTableState();
}

class _TripDataTableState extends State<TripDataTable> {
  List<int> _selectedRows = [];

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _activeStatusFilter; // Track active status filter

  @override
  void initState() {
    super.initState();
    _filterStartDate = widget.initialStartDate;
    _filterEndDate = widget.initialEndDate;
  }

  @override
  void didUpdateWidget(TripDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Sync date filter state when parent updates
    if (oldWidget.initialStartDate != widget.initialStartDate ||
        oldWidget.initialEndDate != widget.initialEndDate) {
      setState(() {
        _filterStartDate = widget.initialStartDate;
        _filterEndDate = widget.initialEndDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    // ✅ Don't filter locally - parent handles all filtering and pagination
    final visibleTrips = widget.trips;

    return DataTableLayout(
      title: 'Trip Tickets',
      searchBar: TripSearchBar(
        controller: widget.searchController,
        searchQuery: widget.searchQuery,
        onSearchChanged: widget.onSearchChanged,
      ),
      onCreatePressed: () => context.go('/tripticket-create'),
      createButtonText: 'Create Trip Ticket',
      columns: [
        DataColumn(label: Text('Trip Number', style: headerStyle)),
        DataColumn(label: Text('Route Name', style: headerStyle)),
        DataColumn(label: Text('Start Date', style: headerStyle)),
        DataColumn(label: Text('End Date', style: headerStyle)),
        DataColumn(label: Text('User', style: headerStyle)),
        DataColumn(label: Text('Status', style: headerStyle)),
        DataColumn(label: Text('Actions', style: headerStyle)),
      ],
      rows:
          widget.isLoading ? _buildLoadingRows() : _buildDataRows(visibleTrips),
      currentPage: widget.currentPage,
      totalPages: widget.totalPages,
      onPageChanged: widget.onPageChanged,
      isLoading: widget.isLoading,
      enableSelection: true,

      // ✅ Filter categories (Status + Date in filter menu)
      filterCategories: _tripFilterCategories(),
      onFilterApplied: _handleFilterApplied,
      onFiltered: () {},

      // ✅ Handle custom filter category selections
      onCustomFilterCategorySelected: (categoryId) {
        if (categoryId == 'date') {
          _openDateFilterDialog();
        }
      },

      onRowsSelected: _handleRowsSelected,
      dataLength: '${visibleTrips.length}',
      onDeleted: () {},
    );
  }

  void _openDateFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TripDateFilterDialog(
          initialStartDate: _filterStartDate,
          initialEndDate: _filterEndDate,
          onApply: (startDate, endDate) {
            setState(() {
              _filterStartDate = startDate;
              _filterEndDate = endDate;
            });
            widget.onDateFilterChanged?.call(startDate, endDate);
          },
        );
      },
    );
  }

  // ----------------------------
  // ✅ FILTERING - COMMUNICATE CHANGES TO PARENT
  // ----------------------------

  void _handleFilterApplied(Map<String, List<dynamic>> filters) {
    final statusValues = filters['status'];

    final String? newStatus =
        (statusValues != null && statusValues.isNotEmpty)
            ? statusValues.first.toString()
            : null;

    // ✅ Track active status filter for UI feedback
    setState(() {
      _activeStatusFilter = newStatus;
    });

    // ✅ Notify parent about status filter change (reset page to 1)
    widget.onFiltered?.call(newStatus);
  }

  List<FilterCategory> _tripFilterCategories() {
    return [
      FilterCategory(
        id: 'status',
        title: 'Status',
        icon: Icons.flag_outlined,
        allowMultiple: false,
        options: [
          FilterOption(
            icon: Icons.timer_outlined,
            id: 'in_progress',
            label: 'In progress',
            value: 'In progress',
          ),
          FilterOption(
            icon: Icons.pending_outlined,
            id: 'pending',
            label: 'Pending',
            value: 'Pending',
          ),
          FilterOption(
            icon: Icons.check_circle_outline,
            id: 'completed',
            label: 'Completed',
            value: 'Completed',
          ),
        ],
      ),
      // ✅ Date filter category
      FilterCategory(
        id: 'date',
        title: 'Date',
        icon: Icons.calendar_month,
        allowMultiple: false,
        options: [], // Empty options - handled separately by date picker
      ),
    ];
  }

  // ----------------------------
  // ROW BUILDERS
  // ----------------------------

  List<DataRow> _buildLoadingRows() {
    return List.generate(
      10,
      (index) => DataRow(
        cells: [
          DataCell(_buildShimmerCell(100)),
          DataCell(_buildShimmerCell(120)),
          DataCell(_buildShimmerCell(120)),
          DataCell(_buildShimmerCell(120)),
          DataCell(_buildShimmerCell(100)),
          DataCell(_buildStatusShimmer()),
          DataCell(
            Row(
              children: [
                _buildShimmerIcon(),
                const SizedBox(width: 8),
                _buildShimmerIcon(),
                const SizedBox(width: 8),
                _buildShimmerIcon(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _buildDataRows(List<TripEntity> trips) {
    return trips.map((trip) {
      return DataRow(
        cells: [
          DataCell(
            Text(trip.tripNumberId ?? 'N/A'),
            onTap: () => _navigateToTripDetails(context, trip),
          ),
          DataCell(
            Text(trip.name ?? 'N/A'),
            onTap: () => _navigateToTripDetails(context, trip),
          ),
          DataCell(
            Text(_formatDateTime(trip.timeAccepted)),
            onTap: () => _navigateToTripDetails(context, trip),
          ),
          DataCell(
            Text(_formatDateTime(trip.timeEndTrip)),
            onTap: () => _navigateToTripDetails(context, trip),
          ),
          DataCell(
            Text(
              trip.user?.name ??
                  (trip.user?.id != null ? 'User: ${trip.user!.id}' : 'N/A'),
            ),
            onTap: () => _navigateToTripDetails(context, trip),
          ),
          DataCell(
            TripStatusChip(trip: trip),
            onTap: () => _navigateToTripDetails(context, trip),
          ),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'View Details',
                  onPressed: () => _navigateToTripDetails(context, trip),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Edit',
                  onPressed: () {
                    if (trip.id != null) {
                      context.go('/tripticket-edit/${trip.id}');
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: () {
                    if (trip is TripModel) {
                      showTripDeleteDialog(context, trip);
                    } else if (trip.id != null) {
                      context.read<TripBloc>().add(
                        DeleteTripTicketEvent(trip.id!),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  // ----------------------------
  // Utilities / existing code
  // ----------------------------

  void _navigateToTripDetails(BuildContext context, TripEntity trip) {
    if (trip.id != null) {
      context.read<TripBloc>().add(GetTripTicketByIdEvent(trip.id!));
      context.go('/tripticket/${trip.id}');
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';

    final hour24 = dateTime.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final amPm = hour24 >= 12 ? 'PM' : 'AM';

    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;

    return '$month/$day/$year '
        '${hour12.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }

  void _handleRowsSelected(List<int> selectedIndices) {
    setState(() {
      _selectedRows = selectedIndices;
    });

    // ✅ Get selected trips from the displayed trips
    final selectedTrips =
        selectedIndices
            .map(
              (index) =>
                  index < widget.trips.length ? widget.trips[index] : null,
            )
            .whereType<TripEntity>()
            .toList();

    debugPrint('Selected ${selectedTrips.length} trips');
  }

  // shimmer helpers (unchanged)
  Widget _buildShimmerCell(double width) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildStatusShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 80,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildShimmerIcon() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
