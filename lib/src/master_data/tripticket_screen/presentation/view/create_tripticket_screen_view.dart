import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_buttons.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';

// Customer related imports
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';

// Invoice related imports
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';

// Personnel related imports
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/data/models/personel_models.dart';

// Vehicle related imports
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/data/model/vehicle_model.dart';

// Checklist related imports
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/presentation/bloc/checklist_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/presentation/bloc/checklist_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/presentation/bloc/checklist_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/data/model/checklist_model.dart';
import 'package:go_router/go_router.dart';

// Form widgets
import '../widget/create_trip_ticket_forms/trip_details_form.dart';
import '../widget/create_trip_ticket_forms/trip_vehicle_forms.dart';
import '../widget/create_trip_ticket_forms/trip_personnel_form.dart';
import '../widget/create_trip_ticket_forms/trip_checklist_form.dart';

class CreateTripTicketScreenView extends StatefulWidget {
  const CreateTripTicketScreenView({super.key});

  @override
  State<CreateTripTicketScreenView> createState() =>
      _CreateTripTicketScreenViewState();
}

class _CreateTripTicketScreenViewState
    extends State<CreateTripTicketScreenView> {
  final _formKey = GlobalKey<FormState>();
  final _tripIdController = TextEditingController();
  final _qrCodeController = TextEditingController();

  // Selected items
  List<CustomerModel> _selectedCustomers = [];
  List<InvoiceModel> _selectedInvoices = [];
  List<VehicleModel> _selectedVehicles = [];
  List<PersonelModel> _selectedPersonnel = [];
  List<ChecklistModel> _selectedChecklists = [];

  bool _isLoading = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateTripIdAndQrCode();
    _loadData();
  }

  @override
  void dispose() {
    _tripIdController.dispose();
    _qrCodeController.dispose();
    super.dispose();
  }

 void _generateTripIdAndQrCode() {
    // Generate a unique trip ID based on timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tripId = 'TRIP-$timestamp';
    
    // Set the trip ID
    _tripIdController.text = tripId;
    
    // Use the same value for QR code (or you could create a more complex value)
    _qrCodeController.text = tripId;
    
    debugPrint('Generated Trip ID: $tripId');
    debugPrint('Generated QR Code: ${_qrCodeController.text}');
  }

  // Function to create a trip ticket
  void _createTripTicket() {
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
    if (_selectedCustomers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedVehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one vehicle'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPersonnel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one personnel'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create the trip model
    final tripModel = TripModel(
      tripNumberId: _tripIdController.text,
      customersList: _selectedCustomers,
      vehicleList: _selectedVehicles,
      personelsList: _selectedPersonnel,
      checklistItems: _selectedChecklists,
      invoicesList: _selectedInvoices,
      // Other fields will be set by the remote data source
    );

    // Set loading state
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Dispatch the create event
    context.read<TripBloc>().add(CreateTripTicketEvent(tripModel));
  }

  void _loadData() {
    // Load all required data using BLoCs
    context.read<CustomerBloc>().add(const GetAllCustomersEvent());
    context.read<InvoiceBloc>().add(const GetInvoiceEvent());
    context.read<PersonelBloc>().add(GetPersonelEvent());
    context.read<VehicleBloc>().add(const GetVehiclesEvent());
    context.read<ChecklistBloc>().add(const GetAllChecklistsEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.generalTripItems();

    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is TripTicketCreated) {
          setState(() {
            _isLoading = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Trip ticket ${state.trip.tripNumberId} created successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to trip tickets list
          context.go('/tripticket');
        } else if (state is TripError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: DesktopLayout(
        navigationItems: navigationItems,
        currentRoute: '/tripticket',
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
        //  title: 'Create Trip Ticket',
        child: Form(
          key: _formKey,
          child: FormLayout(
            title: 'Create Trip Ticket',
            isLoading: _isLoading,
            actions: [
              // Cancel Button
              FormCancelButton(
                label: 'Cancel',
                onPressed: () {
                  // Navigate back to trip tickets list
                  context.go('/tripticket');
                },
              ),
              const SizedBox(width: 16),

              // Create & Add Users Button
              FormSubmitButton(
                label: 'Create & Add Users',
                onPressed: () {
                  // Implement create and add users functionality
                },
                color: Theme.of(context).colorScheme.secondary,
              ),

              const SizedBox(width: 16),

              // Create Trip Button
              FormSubmitButton(
                label: 'Create Trip',
                onPressed: _createTripTicket,
                icon: Icons.add,
              ),
            ],
            children: [
              // Trip Details Form
              _buildTripDetailsForm(),

              const SizedBox(height: 24),

              // Vehicle Form
              _buildVehicleForm(),

              const SizedBox(height: 24),

              // Personnel Form
              _buildPersonnelForm(),

              const SizedBox(height: 24),

              // Checklist Form
              _buildChecklistForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetailsForm() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, customerState) {
        return BlocBuilder<InvoiceBloc, InvoiceState>(
          builder: (context, invoiceState) {
            // Determine available customers
            List<CustomerModel> availableCustomers = [];
            if (customerState is AllCustomersLoaded) {
              availableCustomers =
                  customerState.customers as List<CustomerModel>;
            }

            // Determine available invoices
            List<InvoiceModel> availableInvoices = [];
            if (invoiceState is AllInvoicesLoaded) {
              availableInvoices = invoiceState.invoices as List<InvoiceModel>;
            } else if (invoiceState is InvoiceLoaded) {
              availableInvoices = invoiceState.invoices as List<InvoiceModel>;
            }

            return TripDetailsForm(
              tripIdController: _tripIdController,
              availableCustomers: availableCustomers,
              selectedCustomers: _selectedCustomers,
              availableInvoices: availableInvoices,
              selectedInvoices: _selectedInvoices,
              onCustomersChanged: (customers) {
                setState(() {
                  _selectedCustomers = customers;
                });
              },
              onInvoicesChanged: (invoices) {
                setState(() {
                  _selectedInvoices = invoices;
                });
              }, qrCodeController: _qrCodeController,
            );
          },
        );
      },
    );
  }

  Widget _buildVehicleForm() {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        List<VehicleModel> availableVehicles = [];

        if (state is VehiclesLoaded) {
          availableVehicles = state.vehicles as List<VehicleModel>;
        }

        return VehicleForm(
          availableVehicles: availableVehicles,
          selectedVehicles: _selectedVehicles,
          onVehiclesChanged: (vehicles) {
            setState(() {
              _selectedVehicles = vehicles;
            });
          },
        );
      },
    );
  }

  Widget _buildPersonnelForm() {
    return BlocBuilder<PersonelBloc, PersonelState>(
      builder: (context, state) {
        List<PersonelModel> availablePersonnel = [];

        if (state is PersonelLoaded) {
          availablePersonnel = state.personel as List<PersonelModel>;
        }

        return PersonnelForm(
          availablePersonnel: availablePersonnel,
          selectedPersonnel: _selectedPersonnel,
          onPersonnelChanged: (personnel) {
            setState(() {
              _selectedPersonnel = personnel;
            });
          },
        );
      },
    );
  }

  Widget _buildChecklistForm() {
    return BlocBuilder<ChecklistBloc, ChecklistState>(
      builder: (context, state) {
        List<ChecklistModel> availableChecklists = [];

        if (state is AllChecklistsLoaded) {
          availableChecklists = state.checklists as List<ChecklistModel>;
        }

        return ChecklistForm(
          availableChecklists: availableChecklists,
          selectedChecklists: _selectedChecklists,
          onChecklistsChanged: (checklists) {
            setState(() {
              _selectedChecklists = checklists;
            });
          },
        );
      },
    );
  }
}
