import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_event.dart';

class AuthInterceptor {
  static BuildContext? _context;

  static void initialize(BuildContext context) {
    _context = context;
  }

  static void handleAuthError(dynamic error, {String? operation}) {
    debugPrint('🔥 AuthInterceptor: Handling auth error for operation: $operation');
    debugPrint('🔥 Error details: ${error.toString()}');
    
    if (_context == null) {
      debugPrint('⚠️ AuthInterceptor: Context not initialized');
      return;
    }

    // Check if error is related to authentication
    if (_isAuthError(error)) {
      debugPrint('🚨 Authentication error detected - logging out user');
      
      // Trigger logout
      _context!.read<GeneralUserBloc>().add(const UserSignOutEvent());
      
      // Navigate to login screen
      _context!.go('/');
      
      // Show error message
      ScaffoldMessenger.of(_context!).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please log in again.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  static bool _isAuthError(dynamic error) {
    if (error == null) return false;
    
    final errorString = error.toString().toLowerCase();
    
    // Check for common authentication error patterns
    return errorString.contains('401') ||
           errorString.contains('403') ||
           errorString.contains('unauthorized') ||
           errorString.contains('forbidden') ||
           errorString.contains('authentication') ||
           errorString.contains('auth') ||
           errorString.contains('token') ||
           errorString.contains('expired') ||
           errorString.contains('invalid') ||
           (error is ClientException && error.statusCode == 401) ||
           (error is ClientException && error.statusCode == 403);
  }
}

// Extension to add authentication error handling to PocketBase
extension PocketBaseAuthHandler on PocketBase {
  Future<T> executeWithAuth<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      return await operation();
    } catch (error) {
      debugPrint('🔥 PocketBase operation failed: $operationName');
      AuthInterceptor.handleAuthError(error, operation: operationName);
      rethrow;
    }
  }
}
