import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/presentation/bloc/delivery_team_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/presentation/bloc/personel_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/presentation/bloc/delivery_update_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/presentation/bloc/return_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_coordinates_update/presentation/bloc/trip_coordinates_update_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/presentation/bloc/trip_updates_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/presentation/bloc/undeliverable_customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/presentation/bloc/checklist_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/presentation/bloc/end_trip_checklist_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/presentation/bloc/end_trip_otp_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/presentation/bloc/otp_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/presentation/bloc/bloc/user_roles_bloc.dart';
import 'package:xpro_delivery_admin_app/core/services/injection_container.dart';
import 'package:xpro_delivery_admin_app/core/services/router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set minimum window size for desktop platforms
  // This will apply to web as well when in windowed mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize dependencies
  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<GeneralUserBloc>()),
        BlocProvider(create: (_) => sl<DeliveryTeamBloc>()),
        BlocProvider(create: (_) => sl<UserRolesBloc>()),

        BlocProvider(create: (_) => sl<TripBloc>()),
        BlocProvider(create: (_) => sl<CustomerBloc>()),
        BlocProvider(create: (_) => sl<InvoiceBloc>()),
        BlocProvider(create: (_) => sl<ProductsBloc>()),
        BlocProvider(create: (_) => sl<TripUpdatesBloc>()),
        BlocProvider(create: (_) => sl<UndeliverableCustomerBloc>()),
        BlocProvider(create: (_) => sl<ReturnBloc>()),
        BlocProvider(create: (_) => sl<DeliveryUpdateBloc>()),
        BlocProvider(create: (_) => sl<CompletedCustomerBloc>()),
        BlocProvider(create: (_) => sl<TransactionBloc>()),
        BlocProvider(create: (_) => sl<ChecklistBloc>()),
        BlocProvider(create: (_) => sl<EndTripChecklistBloc>()),
        BlocProvider(create: (_) => sl<OtpBloc>()),
        BlocProvider(create: (_) => sl<EndTripOtpBloc>()),
        BlocProvider(create: (_) => sl<VehicleBloc>()),
        BlocProvider(create: (_) => sl<PersonelBloc>()),
        BlocProvider(create: (_) => sl<TripCoordinatesUpdateBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'X-Pro Delivery Admin App',
        theme: FlexThemeData.light(
          scheme: FlexScheme.blueWhale,
          // Add responsive typography
          typography: Typography.material2018(platform: TargetPlatform.windows),
        ),
        // darkTheme: FlexThemeData.dark(
        //   scheme: FlexScheme.amber,
        //   // Add responsive typography
        //   typography: Typography.material2018(platform: TargetPlatform.windows),
        // ),
        themeMode: ThemeMode.system,
        routerConfig: router,
        builder: (context, child) {
          // Apply minimum constraints to the entire app
          return MediaQuery(
            // Set minimum width and height
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0), // Prevent text scaling
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 600, minHeight: 400),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
