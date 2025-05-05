import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_state.dart';

class AuthStatusHandler extends StatelessWidget {
  final Widget child;

  const AuthStatusHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GeneralUserBloc, GeneralUserState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          // Navigate to dashboard on successful authentication
          context.go('/main-screen');
        } else if (state is GeneralUserError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: child,
    );
  }
}
