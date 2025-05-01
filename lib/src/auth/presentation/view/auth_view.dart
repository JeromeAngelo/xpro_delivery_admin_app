import 'package:xpro_delivery_admin_app/src/auth/presentation/widgets/login_forms.dart';
import 'package:flutter/material.dart';

import 'package:xpro_delivery_admin_app/src/auth/presentation/widgets/auth_status_handler.dart';
import 'package:xpro_delivery_admin_app/src/auth/presentation/widgets/loading_indicator.dart';
import 'package:xpro_delivery_admin_app/src/auth/presentation/widgets/login_header.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 900;
    
    return AuthStatusHandler(
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            
            // Content
            isSmallScreen 
                ? _buildMobileLayout(context)
                : _buildDesktopLayout(context),
                
            // Loading indicator overlay
            const LoadingIndicator(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Logo and branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary,
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const LoginHeader(),
                    const SizedBox(height: 40),
                    Text(
                      'Streamline your delivery operations with our comprehensive management system',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, 
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Trusted by delivery teams nationwide',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Right side - Login form
        Expanded(
          flex: 4,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please sign in to your account',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const LoginForm(),
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          '© ${DateTime.now().year} X-Pro Delivery Admin',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top section - Logo and branding
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const LoginHeader(),
          ),
          
          // Bottom section - Login form
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please sign in to your account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                const LoginForm(),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    '© ${DateTime.now().year} X-Pro Delivery Admin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
