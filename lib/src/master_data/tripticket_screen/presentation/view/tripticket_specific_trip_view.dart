import 'dart:async';

import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_bloc.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_state.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_state.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/entity/trip_update_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/presentation/bloc/trip_updates_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/presentation/bloc/trip_updates_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/presentation/bloc/trip_updates_state.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/entity/end_trip_otp_entity.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/presentation/bloc/end_trip_otp_bloc.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/presentation/bloc/end_trip_otp_event.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/presentation/bloc/end_trip_otp_state.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/entity/otp_entity.dart';
import 'package:desktop_app/core/common/app/features/otp/presentation/bloc/otp_bloc.dart';
import 'package:desktop_app/core/common/app/features/otp/presentation/bloc/otp_event.dart';
import 'package:desktop_app/core/common/app/features/otp/presentation/bloc/otp_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:desktop_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/specific_tripticket_widgets/trip_customer_table.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/specific_tripticket_widgets/trip_dashboard_widget.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/specific_tripticket_widgets/trip_end_trip_otp_table.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/specific_tripticket_widgets/trip_header_widget.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/specific_tripticket_widgets/trip_invoice_table.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/specific_tripticket_widgets/trip_map_place_holder.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/specific_tripticket_widgets/trip_options_dialog.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/specific_tripticket_widgets/trip_otp_table.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/specific_tripticket_widgets/trip_personels_table.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/specific_tripticket_widgets/trip_vehicle_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TripTicketSpecificTripView extends StatefulWidget {
  final String tripId;

  const TripTicketSpecificTripView({super.key, required this.tripId});

  @override
  State<TripTicketSpecificTripView> createState() =>
      _TripTicketSpecificTripViewState();
}

class _TripTicketSpecificTripViewState
    extends State<TripTicketSpecificTripView> {
  // OTP pagination state
  int _otpCurrentPage = 1;
  int _otpTotalPages = 1;
  final int _otpItemsPerPage = 5; // Smaller number for embedded table
  String _otpSearchQuery = '';
  final TextEditingController _otpSearchController = TextEditingController();

  // End Trip OTP pagination state
  int _endTripOtpCurrentPage = 1;
  int _endTripOtpTotalPages = 1;
  final int _endTripOtpItemsPerPage = 5; // Smaller number for embedded table
  String _endTripOtpSearchQuery = '';
  final TextEditingController _endTripOtpSearchController =
      TextEditingController();

  // Invoice pagination state
  int _invoiceCurrentPage = 1;
  int _invoiceTotalPages = 1;
  final int _invoiceItemsPerPage = 5; // Smaller number for embedded table
  String _invoiceSearchQuery = '';
  final TextEditingController _invoiceSearchController =
      TextEditingController();

  Timer? _mapRefreshTimer;
  List<TripUpdateEntity> _tripUpdates = [];
  bool _isMapLoading = true;
  String? _mapErrorMessage;

  @override
  void initState() {
    super.initState();
    // Load trip details
    context.read<TripBloc>().add(GetTripTicketByIdEvent(widget.tripId));
    // Load customers for this trip
    context.read<CustomerBloc>().add(GetCustomerEvent(widget.tripId));
    // Load personnel for this trip
    context.read<PersonelBloc>().add(LoadPersonelsByTripIdEvent(widget.tripId));
    // Load OTPs for this trip
    context.read<OtpBloc>().add(LoadOtpByTripIdEvent(widget.tripId));

    // Load End Trip OTPs for this trip
    context.read<EndTripOtpBloc>().add(
      LoadEndTripOtpByTripIdEvent(widget.tripId),
    );

    debugPrint(
      '🔄 Dispatching GetInvoicesByTripEvent for trip: ${widget.tripId}',
    );
    context.read<InvoiceBloc>().add(GetInvoicesByTripEvent(widget.tripId));

      _loadTripUpdatesForMap();
  
  // Start auto-refresh timer for map data
  _startMapRefreshTimer();
  }

  void _loadTripUpdatesForMap() {
    setState(() {
      _isMapLoading = true;
      _mapErrorMessage = null;
    });

    // Load trip updates
    context.read<TripUpdatesBloc>().add(GetTripUpdatesEvent(widget.tripId));
  }

  void _startMapRefreshTimer() {
    // Cancel any existing timer
    _mapRefreshTimer?.cancel();

    // Create a new timer that refreshes the data every minute
    _mapRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _loadTripUpdatesForMap();
        debugPrint('🔄 Auto-refreshing trip map data');
      }
    });
  }

  @override
  void dispose() {
    _otpSearchController.dispose();
    _endTripOtpSearchController.dispose();
    _invoiceSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.generalTripItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/tripticket',
      onNavigate: (route) {
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
      disableScrolling: true,
      child: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(child: CircularProgressIndicator());
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
                        GetTripTicketByIdEvent(widget.tripId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TripTicketLoaded) {
            final trip = state.trip;

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  floating: true,
                  snap: true,
                  title: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          context.go('/tripticket');
                        },
                      ),
                      Text('Trip Ticket: ${trip.tripNumberId ?? 'N/A'}'),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: () {
                        context.read<TripBloc>().add(
                          GetTripTicketByIdEvent(widget.tripId),
                        );
                        context.read<CustomerBloc>().add(
                          GetCustomerEvent(widget.tripId),
                        );
                        context.read<PersonelBloc>().add(
                          LoadPersonelsByTripIdEvent(widget.tripId),
                        );
                        context.read<OtpBloc>().add(
                          LoadOtpByTripIdEvent(widget.tripId),
                        );
                      },
                    ),
                  ],
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Trip Header
                      TripHeaderWidget(
                        trip: trip,
                        onEditPressed: () {
                          // Navigate to edit trip screen
                        },
                        onOptionsPressed: () {
                          showTripOptionsDialog(context, trip);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Trip Dashboard
                      TripDashboardWidget(trip: trip),

                      const SizedBox(height: 16),

                      // Map Placeholder
                      // With this:
                      _buildTripMapWidget(trip),

                      const SizedBox(height: 16),

                      // Customers Table
                      TripCustomersTable(
                        tripId: widget.tripId,
                        onAttachCustomer: () {
                          // Navigate to attach customer screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Attach customer feature coming soon',
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Invoice Table
                      _buildInvoiceTable(),

                      const SizedBox(height: 16),

                      // Personnel Table
                      TripPersonelsTable(
                        tripId: widget.tripId,
                        onAddPersonel: () {
                          // Navigate to add personnel screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Add personnel feature coming soon',
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Vehicle Table
                      TripVehicleTable(
                        tripId: widget.tripId,
                        onAddVehicle: () {
                          // Navigate to add vehicle screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Add vehicle feature coming soon'),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // OTP Table
                      _buildOtpTable(),

                      const SizedBox(height: 16),

                      // End Trip OTP Table
                      _buildEndTripOtpTable(),

                      // Add some bottom padding
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Select a trip to view details'));
        },
      ),
    );
  }

  Widget _buildInvoiceTable() {
    return BlocConsumer<InvoiceBloc, InvoiceState>(
      listener: (context, state) {
        // Log state changes to help with debugging
        debugPrint('📊 Invoice state changed to: ${state.runtimeType}');

        // If we get an error, show a snackbar
        if (state is InvoiceError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      builder: (context, state) {
        if (state is InvoiceLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is InvoiceError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading invoice data: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint(
                        '🔄 Retrying invoice fetch for trip: ${widget.tripId}',
                      );
                      context.read<InvoiceBloc>().add(
                        GetInvoicesByTripEvent(widget.tripId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Get invoices from any state that might contain them
        List<InvoiceEntity> invoices = [];

        // Handle TripInvoicesLoaded state specifically
        if (state is TripInvoicesLoaded && state.tripId == widget.tripId) {
          debugPrint(
            '📊 Using TripInvoicesLoaded state with ${state.invoices.length} invoices',
          );
          invoices = state.invoices;
        }
        // Handle AllInvoicesLoaded state as a fallback
        else if (state is AllInvoicesLoaded) {
          // Filter invoices for this trip
          invoices =
              state.invoices
                  .where(
                    (invoice) =>
                        invoice.trip == widget.tripId ||
                        invoice.trip?.id == widget.tripId,
                  )
                  .toList();
          debugPrint(
            '📊 Filtered ${invoices.length} invoices for trip ${widget.tripId} from ${state.invoices.length} total invoices',
          );
        }
        // Handle InvoiceLoaded state as another fallback
        else if (state is InvoiceLoaded) {
          // Filter invoices for this trip
          invoices =
              state.invoices
                  .where(
                    (invoice) =>
                        invoice.trip == widget.tripId ||
                        invoice.trip?.id == widget.tripId,
                  )
                  .toList();
          debugPrint(
            '📊 Filtered ${invoices.length} invoices for trip ${widget.tripId} from InvoiceLoaded state',
          );
        }

        // If we don't have invoices yet and we're not loading, request them
        if (invoices.isEmpty && state is! InvoiceLoading) {
          // Use Future.microtask to avoid build-time setState
          Future.microtask(() {
            debugPrint(
              '🔄 No invoices found, requesting for trip: ${widget.tripId}',
            );
            context.read<InvoiceBloc>().add(
              GetInvoicesByTripEvent(widget.tripId),
            );
          });
        }

        // Filter based on search query
        if (_invoiceSearchQuery.isNotEmpty) {
          final query = _invoiceSearchQuery.toLowerCase();
          invoices =
              invoices
                  .where(
                    (invoice) =>
                        (invoice.invoiceNumber?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.customer?.storeName?.toLowerCase().contains(
                              query,
                            ) ??
                            false) ||
                        (invoice.status.toString().toLowerCase().contains(
                          query,
                        )),
                  )
                  .toList();
        }

        // Calculate total pages
        _invoiceTotalPages = (invoices.length / _invoiceItemsPerPage).ceil();
        if (_invoiceTotalPages == 0) _invoiceTotalPages = 1;

        // Paginate invoices
        final startIndex = (_invoiceCurrentPage - 1) * _invoiceItemsPerPage;
        final endIndex =
            startIndex + _invoiceItemsPerPage > invoices.length
                ? invoices.length
                : startIndex + _invoiceItemsPerPage;

        final paginatedInvoices =
            startIndex < invoices.length
                ? invoices.sublist(startIndex, endIndex)
                : [];

        return TripInvoiceTable(
          invoices: paginatedInvoices as List<InvoiceEntity>,
          isLoading: state is InvoiceLoading,
          currentPage: _invoiceCurrentPage,
          totalPages: _invoiceTotalPages,
          onPageChanged: (page) {
            setState(() {
              _invoiceCurrentPage = page;
            });
          },
          searchController: _invoiceSearchController,
          searchQuery: _invoiceSearchQuery,
          onSearchChanged: (value) {
            setState(() {
              _invoiceSearchQuery = value;
            });
          },
          tripId: widget.tripId,
        );
      },
    );
  }

  // Add this method to your class
  Widget _buildTripMapWidget(TripEntity trip) {
    
    return BlocListener<TripUpdatesBloc, TripUpdatesState>(
      listener: (context, state) {
        if (state is TripUpdatesLoading) {
          // We don't set _isMapLoading here to avoid flickering if only updates are refreshing
        } else if (state is TripUpdatesError) {
          setState(() {
            _mapErrorMessage = state.message;
            _isMapLoading = false;
          });
          debugPrint('❌ Error loading trip updates: ${state.message}');
        } else if (state is TripUpdatesLoaded) {
          setState(() {
            _tripUpdates = state.updates;
            _isMapLoading = false;
          });
          debugPrint('✅ Loaded ${_tripUpdates.length} trip updates');
        }
      },
      child: TripMapWidget(
        tripId: widget.tripId,
        trip: trip,
        tripUpdates: _tripUpdates,
        isLoading: _isMapLoading,
        errorMessage: _mapErrorMessage,
        onRefresh: _loadTripUpdatesForMap,
        height: 400, // You can adjust this height as needed
      ),
    );
  }

  Widget _buildOtpTable() {
    return BlocBuilder<OtpBloc, OtpState>(
      builder: (context, state) {
        if (state is OtpLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is OtpError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading OTP data: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<OtpBloc>().add(
                        LoadOtpByTripIdEvent(widget.tripId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is OtpDataLoaded) {
          // Single OTP loaded
          return TripOtpTable(
            otps: [state.otp],
            isLoading: false,
            currentPage: _otpCurrentPage,
            totalPages: 1,
            onPageChanged: (page) {
              setState(() {
                _otpCurrentPage = page;
              });
            },
            searchController: _otpSearchController,
            searchQuery: _otpSearchQuery,
            onSearchChanged: (value) {
              setState(() {
                _otpSearchQuery = value;
              });
            },
            tripId: widget.tripId,
          );
        }

        if (state is AllOtpsLoaded) {
          // Filter OTPs for this trip
          final tripOtps =
              state.otps.where((otp) => otp.trip?.id == widget.tripId).toList();

          // Filter based on search query
          if (_otpSearchQuery.isNotEmpty) {
            final query = _otpSearchQuery.toLowerCase();
            tripOtps.retainWhere(
              (otp) =>
                  (otp.otpCode.toLowerCase().contains(query)) ||
                  (otp.generatedCode?.toLowerCase().contains(query) ?? false),
            );
          }

          // Calculate total pages
          _otpTotalPages = (tripOtps.length / _otpItemsPerPage).ceil();
          if (_otpTotalPages == 0) _otpTotalPages = 1;

          // Paginate OTPs
          final startIndex = (_otpCurrentPage - 1) * _otpItemsPerPage;
          final endIndex =
              startIndex + _otpItemsPerPage > tripOtps.length
                  ? tripOtps.length
                  : startIndex + _otpItemsPerPage;

          final paginatedOtps =
              startIndex < tripOtps.length
                  ? tripOtps.sublist(startIndex, endIndex)
                  : [];

          return TripOtpTable(
            otps: paginatedOtps as List<OtpEntity>,
            isLoading: false,
            currentPage: _otpCurrentPage,
            totalPages: _otpTotalPages,
            onPageChanged: (page) {
              setState(() {
                _otpCurrentPage = page;
              });
            },
            searchController: _otpSearchController,
            searchQuery: _otpSearchQuery,
            onSearchChanged: (value) {
              setState(() {
                _otpSearchQuery = value;
              });
            },
            tripId: widget.tripId,
          );
        }

        // Default case - no OTPs yet
        return TripOtpTable(
          otps: [],
          isLoading: false,
          currentPage: _otpCurrentPage,
          totalPages: _otpTotalPages,
          onPageChanged: (page) {
            setState(() {
              _otpCurrentPage = page;
            });
          },
          searchController: _otpSearchController,
          searchQuery: _otpSearchQuery,
          onSearchChanged: (value) {
            setState(() {
              _otpSearchQuery = value;
            });
          },
          tripId: widget.tripId,
        );
      },
    );
  }

  Widget _buildEndTripOtpTable() {
    return BlocBuilder<EndTripOtpBloc, EndTripOtpState>(
      builder: (context, state) {
        if (state is EndTripOtpLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is EndTripOtpError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading End Trip OTP data: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<EndTripOtpBloc>().add(
                        LoadEndTripOtpByTripIdEvent(widget.tripId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is EndTripOtpDataLoaded) {
          // Single End Trip OTP loaded
          return TripEndTripOtpTable(
            endTripOtps: [state.otp],
            isLoading: false,
            currentPage: _endTripOtpCurrentPage,
            totalPages: 1,
            onPageChanged: (page) {
              setState(() {
                _endTripOtpCurrentPage = page;
              });
            },
            searchController: _endTripOtpSearchController,
            searchQuery: _endTripOtpSearchQuery,
            onSearchChanged: (value) {
              setState(() {
                _endTripOtpSearchQuery = value;
              });
            },
          );
        }

        if (state is AllEndTripOtpsLoaded) {
          // Filter End Trip OTPs for this trip
          final tripEndTripOtps =
              state.otps.where((otp) => otp.trip?.id == widget.tripId).toList();

          // Filter based on search query
          if (_endTripOtpSearchQuery.isNotEmpty) {
            final query = _endTripOtpSearchQuery.toLowerCase();
            tripEndTripOtps.retainWhere(
              (otp) =>
                  (otp.otpCode.toLowerCase().contains(query)) ||
                  (otp.generatedCode?.toLowerCase().contains(query) ?? false),
            );
          }

          // Calculate total pages
          _endTripOtpTotalPages =
              (tripEndTripOtps.length / _endTripOtpItemsPerPage).ceil();
          if (_endTripOtpTotalPages == 0) _endTripOtpTotalPages = 1;

          // Paginate End Trip OTPs
          final startIndex =
              (_endTripOtpCurrentPage - 1) * _endTripOtpItemsPerPage;
          final endIndex =
              startIndex + _endTripOtpItemsPerPage > tripEndTripOtps.length
                  ? tripEndTripOtps.length
                  : startIndex + _endTripOtpItemsPerPage;

          final paginatedEndTripOtps =
              startIndex < tripEndTripOtps.length
                  ? tripEndTripOtps.sublist(startIndex, endIndex)
                  : [];

          return TripEndTripOtpTable(
            endTripOtps: paginatedEndTripOtps as List<EndTripOtpEntity>,
            isLoading: false,
            currentPage: _endTripOtpCurrentPage,
            totalPages: _endTripOtpTotalPages,
            onPageChanged: (page) {
              setState(() {
                _endTripOtpCurrentPage = page;
              });
            },
            searchController: _endTripOtpSearchController,
            searchQuery: _endTripOtpSearchQuery,
            onSearchChanged: (value) {
              setState(() {
                _endTripOtpSearchQuery = value;
              });
            },
          );
        }

        // Default case - no End Trip OTPs yet
        return TripEndTripOtpTable(
          endTripOtps: [],
          isLoading: false,
          currentPage: _endTripOtpCurrentPage,
          totalPages: _endTripOtpTotalPages,
          onPageChanged: (page) {
            setState(() {
              _endTripOtpCurrentPage = page;
            });
          },
          searchController: _endTripOtpSearchController,
          searchQuery: _endTripOtpSearchQuery,
          onSearchChanged: (value) {
            setState(() {
              _endTripOtpSearchQuery = value;
            });
          },
        );
      },
    );
  }
}
