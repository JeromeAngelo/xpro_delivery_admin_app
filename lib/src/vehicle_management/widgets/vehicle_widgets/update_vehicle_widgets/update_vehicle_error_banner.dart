import 'package:flutter/material.dart';

/// A compact, red error banner shown beneath the form when the
/// update flow reports a failure.
///
/// Used by [UpdateVehicleForm] (which lives in this same folder)
/// and surfaced by the parent `UpdateVehicleView` whenever the
/// `DeliveryVehicleBloc` or `VehicleProfileBloc` emits an error
/// state.
class UpdateVehicleErrorBanner extends StatelessWidget {
  /// The error text to display.
  final String message;

  const UpdateVehicleErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red.shade900)),
          ),
        ],
      ),
    );
  }
}
