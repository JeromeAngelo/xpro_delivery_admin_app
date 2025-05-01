import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';

class TripSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const TripSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search by ID, Trip Number, or User...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onSearchChanged('');
                  context.read<TripBloc>().add(const GetAllTripTicketsEvent());
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) {
        onSearchChanged(value);
        if (value.isEmpty) {
          context.read<TripBloc>().add(const GetAllTripTicketsEvent());
        } else {
          context.read<TripBloc>().add(SearchTripTicketsEvent(
            tripNumberId: value,
          ));
        }
      },
    );
  }
}
