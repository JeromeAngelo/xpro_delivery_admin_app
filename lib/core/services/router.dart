import 'package:desktop_app/src/auth/presentation/view/auth_view.dart';
import 'package:desktop_app/src/collection_data/completed_customer_list/presentation/view/completed_customer_list_screen.dart';
import 'package:desktop_app/src/collection_data/completed_customer_list/presentation/view/specific_completed_customer_data.dart';
import 'package:desktop_app/src/collection_data/tripricket_list/presentation/view/specific_trip_collection.dart';
import 'package:desktop_app/src/collection_data/tripricket_list/presentation/view/tripticket_list_for_collection.dart';
import 'package:desktop_app/src/master_data/checklist_screen/presentation/view/checklist_screen_view.dart';
import 'package:desktop_app/src/master_data/customer_screen/presentation/view/customer_list_screen_view.dart';
import 'package:desktop_app/src/master_data/customer_screen/presentation/view/specific_customer_screen_view.dart';
import 'package:desktop_app/src/master_data/invoice_screen/presentation/view/invoice_screen_list_view.dart';
import 'package:desktop_app/src/master_data/invoice_screen/presentation/view/specific_invoice_screen_view.dart';
import 'package:desktop_app/src/main_screen/presentation/view/main_screen_view.dart';
import 'package:desktop_app/src/master_data/personnels_list_screen/presentation/view/personnel_list_screen_view.dart';
import 'package:desktop_app/src/master_data/product_list_screen/presentation/view/product_list_screen_view.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/view/create_tripticket_screen_view.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/view/trip_ticket_overview_screen.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/view/tripticket_screen_view.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/view/tripticket_specific_trip_view.dart';
import 'package:desktop_app/src/master_data/vehicle_list_screen/presentation/view/vehicle_list_screen_view.dart';
import 'package:desktop_app/src/return_data/return_list_screen/presentation/view/return_list_view.dart';
import 'package:desktop_app/src/return_data/undelivered_customer_data/presentation/view/undelivered_customer_list_view.dart';
import 'package:desktop_app/src/users/presentation/view/delivery_users_list_view.dart';
import 'package:desktop_app/src/users/presentation/view/users_list_view.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => AuthView()),
    GoRoute(
      path: '/main-screen',
      builder: (context, state) => MainScreenView(),
    ),
      GoRoute(
      path: '/trip-overview',
      builder: (context, state) => TripTicketOverviewScreen(),
    ),
    GoRoute(
      path: '/tripticket',
      builder: (context, state) => TripTicketScreenView(),
    ),
    // Add this new route for specific trip view
    GoRoute(
      path: '/tripticket/:tripId',
      builder: (context, state) {
        final tripId = state.pathParameters['tripId']!;
        return TripTicketSpecificTripView(tripId: tripId);
      },
    ),
      // Add this new route for creating trip tickets
    GoRoute(
      path: '/tripticket-create',
      builder: (context, state) => CreateTripTicketScreenView(),
    ),
    GoRoute(
      path: '/customer-list',
      builder: (context, state) => CustomerListScreenView(),
    ),
    GoRoute(
      path: '/customer/:customerId',
      builder: (context, state) {
        final customerId = state.pathParameters['customerId']!;
        return SpecificCustomerScreenView(customerId: customerId);
      },
    ),
     GoRoute(
      path: '/invoice-list',
      builder: (context, state) => InvoiceScreenListView(),
    ),
    GoRoute(
      path: '/invoice/:invoiceId',
      builder: (context, state) {
        final invoiceId = state.pathParameters['invoiceId']!;
        return SpecificInvoiceScreenView(invoiceId: invoiceId,);
      },
    ),
    // Add this import

// Inside the GoRouter routes list, add:
GoRoute(
  path: '/product-list',
  builder: (context, state) => const ProductListScreenView(),
),
GoRoute(
  path: '/vehicle-list',
  builder: (context, state) => const VehicleListScreenView(),
),
GoRoute(
  path: '/personnel-list',
  builder: (context, state) => const PersonnelListScreenView(),
),
// Inside the GoRouter routes list, add:

GoRoute(
  path: '/checklist',
  builder: (context, state) => const ChecklistScreenView(),
),
GoRoute(
  path: '/collections',
  builder: (context, state) => const TripTicketListForCollection(),
),
GoRoute(
  path: '/collections/:tripId',
  builder: (context, state) {
    final tripId = state.pathParameters['tripId']!;
    return SpecificTripCollection(tripId: tripId);
  },
),
GoRoute(
  path: '/completed-customers',
  builder: (context, state) => const CompletedCustomerListScreen(),
),
GoRoute(
  path: '/completed-customers/:customerId',
  builder: (context, state) {
    final customerId = state.pathParameters['customerId']!;
    return SpecificCompletedCustomerData(customerId: customerId);
  },
),
GoRoute(
  path: '/returns',
  builder: (context, state) => const ReturnListView(),
),

GoRoute(
  path: '/users',
  builder: (context, state) => const UsersListView(),
),
GoRoute(
  path: '/delivery-users',
  builder: (context, state) => const DeliveryUsersListView(),
),
GoRoute(
  path: '/undeliverable-customers',
  builder: (context, state) => const UndeliveredCustomerListView(),
),

  ],
);
