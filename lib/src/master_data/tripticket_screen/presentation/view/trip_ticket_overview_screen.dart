import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/cancelled_invoices/domain/entity/cancelled_invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/overview_widget/active_trips_chart_widget.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/overview_widget/cancelled_deliveries_chart_widget.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/overview_widget/cancelled_deliveries_widget_status_distribution.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/overview_widget/quick_access_widget.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/overview_widget/recent_trips_widget.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/overview_widget/trip_status_distribution_widget.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/overview_widget/trip_volume_by_day_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/presentation/bloc/trip_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/presentation/bloc/trip_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';

class TripTicketOverviewScreen extends StatefulWidget {
  const TripTicketOverviewScreen({super.key});

  @override
  State<TripTicketOverviewScreen> createState() =>
      _TripTicketOverviewScreenState();
}

class _TripTicketOverviewScreenState extends State<TripTicketOverviewScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isDateFiltered = false;

  @override
  void initState() {
    super.initState();
    // Default to today on init
    _loadToday();
    // Load all cancelled invoices for the unfulfilled deliveries section
    context.read<CancelledInvoiceBloc>().add(
      const GetAllCancelledInvoicesEvent(),
    );
  }

  void _loadToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    setState(() {
      _selectedStartDate = startOfDay;
      _selectedEndDate = endOfDay;
      _isDateFiltered = true;
    });

    context.read<TripBloc>().add(
      FilterTripsByDateRangeEvent(startDate: startOfDay, endDate: endOfDay),
    );
  }

  void _loadAllTrips() {
    context.read<TripBloc>().add(const GetAllTripTicketsEvent());
    setState(() {
      _isDateFiltered = false;
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
  }

  void _showDateRangePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempStartDate = _selectedStartDate;
        DateTime? tempEndDate = _selectedEndDate;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.date_range, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Filter by Date Range'),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select date range to filter trip tickets:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Start Date Picker
                    Row(
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text(
                            'From:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: tempStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  tempStartDate = date;
                                  // Reset end date if it's before start date
                                  if (tempEndDate != null &&
                                      tempEndDate!.isBefore(date)) {
                                    tempEndDate = null;
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tempStartDate != null
                                        ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(tempStartDate!)
                                        : 'Select start date',
                                    style: TextStyle(
                                      color:
                                          tempStartDate != null
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // End Date Picker
                    Row(
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text(
                            'To:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap:
                                tempStartDate == null
                                    ? null
                                    : () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            tempEndDate ?? tempStartDate!,
                                        firstDate: tempStartDate!,
                                        lastDate: DateTime.now(),
                                      );
                                      if (date != null) {
                                        setDialogState(() {
                                          tempEndDate = date;
                                        });
                                      }
                                    },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      tempStartDate == null
                                          ? Colors.grey.shade200
                                          : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                color:
                                    tempStartDate == null
                                        ? Colors.grey.shade50
                                        : Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tempEndDate != null
                                        ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(tempEndDate!)
                                        : 'Select end date',
                                    style: TextStyle(
                                      color:
                                          tempStartDate == null
                                              ? Colors.grey.shade400
                                              : tempEndDate != null
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color:
                                        tempStartDate == null
                                            ? Colors.grey.shade400
                                            : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (tempStartDate != null && tempEndDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Date range: ${DateFormat('MMM dd').format(tempStartDate!)} - ${DateFormat('MMM dd, yyyy').format(tempEndDate!)}',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                if (_isDateFiltered)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _loadAllTrips();
                    },
                    child: const Text('View All'),
                  ),
                ElevatedButton(
                  onPressed:
                      tempStartDate == null || tempEndDate == null
                          ? null
                          : () {
                            Navigator.of(context).pop();
                            _filterByDateRange(tempStartDate!, tempEndDate!);
                          },
                  child: const Text('Apply Filter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterByDateRange(DateTime startDate, DateTime endDate) {
    // Set end date to end of day to include full day
    final endOfDay = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endOfDay;
      _isDateFiltered = true;
    });

    context.read<TripBloc>().add(
      FilterTripsByDateRangeEvent(startDate: startDate, endDate: endOfDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.generalTripItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/trip-overview',
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
      title: 'Trip Ticket Dashboard',
      child: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          // Handle different states
          if (state is TripInitial) {
            // Initial state, trigger loading
            context.read<TripBloc>().add(const GetAllTripTicketsEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TripLoading) {
            return _buildContent(context, [], true);
          }

          if (state is TripError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<TripBloc>().add(
                        const GetAllTripTicketsEvent(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AllTripTicketsLoaded ||
              state is TripTicketsSearchResults ||
              state is TripsFilteredByDateRange) {
            final trips =
                state is AllTripTicketsLoaded
                    ? state.trips
                    : state is TripTicketsSearchResults
                    ? state.trips
                    : (state as TripsFilteredByDateRange).trips;

            return _buildContent(context, trips, false);
          }

          // Default fallback
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildDateFilterHeader(BuildContext context) {
    String dateRangeLabel = 'All Time';
    if (_selectedStartDate != null && _selectedEndDate != null) {
      dateRangeLabel =
          '${DateFormat('MMM dd, yyyy').format(_selectedStartDate!)} - ${DateFormat('MMM dd, yyyy').format(_selectedEndDate!)}';
    }

    return Row(
      children: [
        InkWell(
          onTap: _showDateRangePickerDialog,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:
                  _isDateFiltered
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _isDateFiltered
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color:
                      _isDateFiltered
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isDateFiltered ? 'Filtered Period' : 'Select Date Range',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            _isDateFiltered
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateRangeLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            _isDateFiltered
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (_isDateFiltered) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.filter_alt,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
        const Spacer(),
        if (_isDateFiltered)
          TextButton.icon(
            onPressed: _loadAllTrips,
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Show All'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List trips, bool isLoading) {
    final typedTrips = trips.cast<TripEntity>();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date filter header
            _buildDateFilterHeader(context),

            const SizedBox(height: 24),

            // ── Statistics graphs ─────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                'Summary Trip for Today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Top row: Active Trips (line/area) + Status Distribution (donut)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ActiveTripsChartWidget(
                      trips: typedTrips,
                      isLoading: isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TripStatusDistributionWidget(
                      trips: typedTrips,
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Second row: Trip Volume by Day (bar chart)
            TripVolumeByDayWidget(trips: typedTrips, isLoading: isLoading),

            const SizedBox(height: 16),

            // Third row: Cancelled Deliveries chart + reason distribution
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: BlocBuilder<
                      CancelledInvoiceBloc,
                      CancelledInvoiceState
                    >(
                      builder: (context, cancelledState) {
                        final cancelledInvoices =
                            cancelledState is AllCancelledInvoicesLoaded
                                ? cancelledState.cancelledInvoices
                                : cancelledState is CancelledInvoicesLoaded
                                ? cancelledState.cancelledInvoices
                                : <CancelledInvoiceEntity>[];
                        final isCancelledLoading =
                            cancelledState is CancelledInvoiceLoading;

                        return CancelledDeliveriesChartWidget(
                          cancelledInvoices: cancelledInvoices,
                          startDate: _selectedStartDate,
                          endDate: _selectedEndDate,
                          isLoading: isCancelledLoading,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: BlocBuilder<
                      CancelledInvoiceBloc,
                      CancelledInvoiceState
                    >(
                      builder: (context, cancelledState) {
                        final cancelledInvoices =
                            cancelledState is AllCancelledInvoicesLoaded
                                ? cancelledState.cancelledInvoices
                                : cancelledState is CancelledInvoicesLoaded
                                ? cancelledState.cancelledInvoices
                                : <CancelledInvoiceEntity>[];
                        final isCancelledLoading =
                            cancelledState is CancelledInvoiceLoading;

                        return CancelledDeliveriesStatusDistributionWidget(
                          cancelledInvoices: cancelledInvoices,
                          startDate: _selectedStartDate,
                          endDate: _selectedEndDate,
                          isLoading: isCancelledLoading,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Access Buttons
            const QuickAccessWidget(),

            const SizedBox(height: 24),

            // Recent Trips
            RecentTripsWidget(trips: typedTrips, isLoading: isLoading),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
