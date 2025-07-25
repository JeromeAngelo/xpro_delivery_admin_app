import 'package:xpro_delivery_admin_app/src/auth/presentation/view/auth_view.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/view/completed_customer_list_screen.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/view/completed_customer_overview.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/view/specific_completed_customer_data.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/tripricket_list/presentation/view/specific_trip_collection.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/tripricket_list/presentation/view/tripticket_list_for_collection.dart';
import 'package:xpro_delivery_admin_app/src/delivery_monitoring/presentation/view/delivery_monitoring_screen.dart';
import 'package:xpro_delivery_admin_app/src/master_data/checklist_screen/presentation/view/checklist_screen_view.dart';
import 'package:xpro_delivery_admin_app/src/master_data/customer_screen/presentation/view/customer_list_screen_view.dart';
import 'package:xpro_delivery_admin_app/src/master_data/customer_screen/presentation/view/specific_customer_screen_view.dart';
import 'package:xpro_delivery_admin_app/src/master_data/delivery_data/view/delivery_data_screen.dart';
import 'package:xpro_delivery_admin_app/src/master_data/invoice_preset_groups_screen/presentation/view/invoice_preset_group_screen.dart';
import 'package:xpro_delivery_admin_app/src/master_data/invoice_screen/presentation/view/invoice_screen_list_view.dart';
import 'package:xpro_delivery_admin_app/src/master_data/invoice_screen/presentation/view/specific_invoice_screen_view.dart';
import 'package:xpro_delivery_admin_app/src/main_screen/presentation/view/main_screen_view.dart';
import 'package:xpro_delivery_admin_app/src/master_data/personnels_list_screen/presentation/view/personnel_list_screen_view.dart';
import 'package:xpro_delivery_admin_app/src/master_data/product_list_screen/presentation/view/product_list_screen_view.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/view/create_tripticket_screen_view.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/view/trip_ticket_overview_screen.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/view/tripticket_screen_view.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/view/tripticket_specific_trip_view.dart';
import 'package:xpro_delivery_admin_app/src/master_data/vehicle_list_screen/presentation/view/vehicle_list_screen_view.dart';
import 'package:xpro_delivery_admin_app/src/return_data/return_list_screen/presentation/view/return_list_view.dart';
import 'package:xpro_delivery_admin_app/src/return_data/undelivered_customer_data/presentation/view/undelivered_customer_list_view.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/view/all_users_view.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/view/create_user_view.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/view/specific_user_view.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/view/update_user_view.dart';

import '../../src/master_data/delivery_data/view/specific_delivery_data_screen.dart';
import '../../src/return_data/undelivered_customer_data/presentation/view/specific_cancelled_invoice_view.dart';
import '../../src/master_data/tripticket_screen/presentation/view/edit_tripticket_screen_view.dart';

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
    // Add this new route for editing trip tickets
    GoRoute(
      path: '/tripticket-edit/:tripId',
      builder: (context, state) {
        final tripId = state.pathParameters['tripId']!;
        // We need to get the trip entity first, but we'll handle this in the edit screen
        return EditTripTicketScreenView(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/customer-list',
      builder: (context, state) => CustomerListScreenView(),
    ),
    GoRoute(
      path: '/delivery-list',
      builder: (context, state) => DeliveryDataScreen(),
    ),
    GoRoute(
      path: '/delivery-details/:deliveryId',
      builder: (context, state) {
        final deliveryId = state.pathParameters['deliveryId']!;
        return SpecificDeliveryDataScreen(deliveryId: deliveryId);
      },
    ),

    GoRoute(
      path: '/customer/:customerId',
      builder: (context, state) {
        // Extract the customerId without any additional colons
        final customerId = state.pathParameters['customerId']!;
        return SpecificCustomerScreenView(customerId: customerId);
      },
    ),
    GoRoute(
      path: '/invoice-list',
      builder: (context, state) => InvoiceScreenListView(),
    ),
    GoRoute(
      path: '/invoice-preset-groups',
      builder: (context, state) => InvoicePresetGroupScreen(),
    ),
    GoRoute(
      path: '/invoice/:invoiceId',
      builder: (context, state) {
        final invoiceId = state.pathParameters['invoiceId']!;
        return SpecificInvoiceScreenView(invoiceId: invoiceId);
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
      path: '/collections-overview',
      builder: (context, state) => const CompletedCustomerOverview(),
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
      path: '/completed-collections/:collectionId',
      builder: (context, state) {
        final customerId = state.pathParameters['collectionId']!;
        return SpecificCompletedCustomerData(collectionId: customerId);
      },
    ),
    GoRoute(
      path: '/returns',
      builder: (context, state) => const ReturnListView(),
    ),

    //GoRoute(path: '/users', builder: (context, state) => const UsersListView()),
    GoRoute(
      path: '/all-users',
      builder: (context, state) => const AllUsersView(),
    ),
    GoRoute(
      path: '/create-users',
      builder: (context, state) => const CreateUserView(),
    ),
    // Add this route to your router configuration
    GoRoute(
      path: '/user/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return SpecificUserView(userId: userId);
      },
    ),

    // Add the new route for updating users
    GoRoute(
      path: '/update-user/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return UpdateUserView(userId: userId);
      },
    ),

    GoRoute(
      path: '/undeliverable-customers',
      builder: (context, state) => const UndeliveredCustomerListView(),
    ),

    GoRoute(
      path: '/undeliverable-customers/:cancelledInvoiceId',
      builder: (context, state) {
        final invoiceId = state.pathParameters['cancelledInvoiceId']!;
        return SpecificCancelledInvoiceView(cancelledInvoiceId: invoiceId);
      },
    ),

    // Add this route to your router configuration
    GoRoute(
      path: '/delivery-monitoring',
      builder: (context, state) => const DeliveryMonitoringScreen(),
    ),

    // Add this route to your router configuration
  ],
);
