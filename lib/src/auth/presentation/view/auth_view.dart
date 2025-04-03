import 'package:desktop_app/src/auth/presentation/widgets/login_forms.dart';
import 'package:flutter/material.dart';

import 'package:desktop_app/src/auth/presentation/widgets/auth_status_handler.dart';
import 'package:desktop_app/src/auth/presentation/widgets/loading_indicator.dart';
import 'package:desktop_app/src/auth/presentation/widgets/login_header.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated
   // context.read<AuthBloc>().add(SignInEvent(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return AuthStatusHandler(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          LoginHeader(),
                          LoginForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
