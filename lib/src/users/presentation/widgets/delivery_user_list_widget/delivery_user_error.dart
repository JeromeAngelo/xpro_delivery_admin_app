import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryUserErrorWidget extends StatelessWidget {
  final String errorMessage;

  const DeliveryUserErrorWidget({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error: $errorMessage',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<GeneralUserBloc>().add(
                const GetAllUsersEvent(),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
