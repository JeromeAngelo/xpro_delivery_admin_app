import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class AuthStatusHandler extends StatelessWidget {
  final Widget child;

  const AuthStatusHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Navigate to dashboard on successful authentication
          context.go('/main-screen');
        } else if (state is AuthError) {
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
