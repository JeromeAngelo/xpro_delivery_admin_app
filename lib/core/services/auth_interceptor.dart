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
    debugPrint(
      '🔥 AuthInterceptor: Handling auth error for operation: $operation',
    );
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

    // 1) PocketBase client exceptions are the only reliable signal.
    if (error is ClientException) {
      final status = error.statusCode;
      if (status == 401 || status == 403) {
        return true;
      }
      // Don't blanket-match on substring for ClientException — only 401/403 count.
      return false;
    }

    // 2) ServerException thrown by our own data sources: only treat
    //    the status codes we explicitly mark as auth failures.
    if (error.runtimeType.toString() == 'ServerException') {
      try {
        // Avoid hard-import to keep this file lightweight; read .statusCode via dynamic.
        final status = (error as dynamic).statusCode?.toString() ?? '';
        return status == '401' || status == '403';
      } catch (_) {
        return false;
      }
    }

    // 3) Anything else: do NOT log the user out based on a substring match.
    //    The previous implementation matched "auth", "token", "invalid", "expired"
    //    anywhere in the message, which incorrectly logged users out whenever
    //    PocketBase returned an error such as "Failed to load relation: auth ..."
    //    or a field name containing "token" (e.g. tokenKey). Be strict here.
    return false;
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
