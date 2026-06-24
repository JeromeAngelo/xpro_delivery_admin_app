import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/domain/entity/vehicle_tag_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';

/// Read-only dashboard that surfaces the list of [VehicleTagEntity]
/// belonging to a single [DeliveryVehicleEntity] fetched via
/// [LoadDeliveryVehicleByIdEvent] and renders them using the same
/// `DataTableLayout` style as the assigned-trips table.
class VehicleTagsTable extends StatefulWidget {
  /// The `deliveryVehicleData` record id used by
  /// [LoadDeliveryVehicleByIdEvent].
  final String deliveryVehicleDataId;

  /// Pagination – mirrors the assigned-trips table contract.
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  /// Search bar state – mirrors the assigned-trips table contract.
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const VehicleTagsTable({
    super.key,
    required this.deliveryVehicleDataId,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  State<VehicleTagsTable> createState() => _VehicleTagsTableState();
}

class _VehicleTagsTableState extends State<VehicleTagsTable> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchVehicle();
    });
  }

  void _fetchVehicle() {
    if (widget.deliveryVehicleDataId.isEmpty) return;
    try {
      context.read<DeliveryVehicleBloc>().add(
        LoadDeliveryVehicleByIdEvent(widget.deliveryVehicleDataId),
      );
    } catch (_) {
      // Bloc not available in this subtree – ignore.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryVehicleBloc, DeliveryVehicleState>(
      builder: (context, state) {
        DeliveryVehicleEntity? vehicle;
        bool loading = false;
        String? errorMessage;

        if (state is DeliveryVehicleLoading) {
          loading = true;
          debugPrint('🔄 [VEHICLE TAGS TABLE] Loading vehicle...');
        } else if (state is DeliveryVehicleLoaded &&
            state.vehicle.id == widget.deliveryVehicleDataId) {
          vehicle = state.vehicle;
          debugPrint('✅ [VEHICLE TAGS TABLE] Vehicle loaded: ${vehicle.id}');
        } else if (state is DeliveryVehicleError) {
          errorMessage = _humanizeError(state.message);
          debugPrint(
            '❌ [VEHICLE TAGS TABLE] Error loading vehicle: ${state.message}',
          );
        }

        final tags = _filterTags(vehicle?.vehicleTags, widget.searchQuery);

        return DataTableLayout(
          title: 'Vehicle Tags',
          searchBar: TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              hintText: 'Search by tag label or description...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  widget.searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.searchController.clear();
                          widget.onSearchChanged('');
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: widget.onSearchChanged,
          ),

          // No create button on this dashboard.
          onCreatePressed: null,
          createButtonText: '',

          columns: const [
            DataColumn(label: Text('Label')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Types')),
          ],

          rows:
              tags.isEmpty
                  ? const []
                  : [
                    for (final tag in tags)
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              tag.label ?? 'Unnamed',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              tag.description?.isNotEmpty == true
                                  ? tag.description!
                                  : '—',
                            ),
                          ),
                          DataCell(_buildTypeChips(tag.types)),
                        ],
                      ),
                  ],

          currentPage: widget.currentPage,
          totalPages: widget.totalPages,
          onPageChanged: widget.onPageChanged,

          isLoading: loading,
          errorMessage: errorMessage,
          onRetry: errorMessage != null ? () => _fetchVehicle() : null,

          onFiltered: null,
          dataLength: '${tags.length}',
          onDeleted: () {},
        );
      },
    );
  }

  /// Filters the provided tags by the current search query.
  List<VehicleTagEntity> _filterTags(
    List<VehicleTagEntity>? tags,
    String query,
  ) {
    final source = tags ?? const <VehicleTagEntity>[];
    if (query.trim().isEmpty) return source;
    final lower = query.toLowerCase();
    return source.where((tag) {
      final label = (tag.label ?? '').toLowerCase();
      final description = (tag.description ?? '').toLowerCase();
      final typeLabels =
          tag.types?.map((t) => t.name.toLowerCase()).join(' ') ?? '';
      return label.contains(lower) ||
          description.contains(lower) ||
          typeLabels.contains(lower);
    }).toList();
  }

  /// Renders a list of [VehicleTagType] as compact `Chip`s inside a `Wrap`.
  Widget _buildTypeChips(List<dynamic>? types) {
    if (types == null || types.isEmpty) {
      return const Text('—');
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final t in types)
            Chip(
              label: Text(
                _formatTypeLabel(t),
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: Colors.indigo.shade50,
              side: BorderSide(color: Colors.indigo.shade200),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            ),
        ],
      ),
    );
  }

  /// Produces a readable label for a tag type enum or string.
  ///
  /// The result keeps the first letter capitalised and inserts a space
  /// before each subsequent capital letter, e.g. `VehicleTagType.capacity`
  /// becomes `Capacity`.
  String _formatTypeLabel(dynamic type) {
    if (type == null) return 'Unknown';
    final raw = type.toString();
    // If the enum's toString looks like "VehicleTagType.capacity",
    // strip the class name and split camelCase into words.
    final name = raw.contains('.') ? raw.split('.').last : raw;
    final spaced = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    if (spaced.isEmpty) return 'Unknown';
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  /// Translates a raw PocketBase / network error string into a
  /// short, user-friendly message.
  String _humanizeError(String? raw) {
    final original = raw ?? '';
    final lower = original.toLowerCase();

    if (lower.contains('404') ||
        lower.contains('not found') ||
        lower.contains('failed to load resource')) {
      return 'Vehicle not found.';
    }

    if (lower.contains('401') || lower.contains('unauthorized')) {
      return 'You are not signed in or your session has expired. ';
    }

    if (lower.contains('403') ||
        lower.contains('forbidden') ||
        lower.contains('not allowed')) {
      return 'You don\'t have permission to view this vehicle.';
    }

    if (lower.contains('400') ||
        lower.contains('bad request') ||
        lower.contains('validation')) {
      return 'The request was invalid. Please refresh or contact support.';
    }

    if (lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('408')) {
      return 'The request timed out. Check your connection and try again.';
    }

    if (lower.contains('500') ||
        lower.contains('502') ||
        lower.contains('503') ||
        lower.contains('504') ||
        lower.contains('internal server error') ||
        lower.contains('bad gateway') ||
        lower.contains('service unavailable')) {
      return 'The server is temporarily unavailable. Please try again.';
    }

    if (lower.contains('socketexception') ||
        lower.contains('connection refused') ||
        lower.contains('connection failed') ||
        lower.contains('network is unreachable') ||
        lower.contains('failed host lookup') ||
        lower.contains('no internet') ||
        lower.contains('no address associated with hostname')) {
      return 'Cannot reach the server. Check your connection and try again.';
    }

    if (lower.contains('formatexception') ||
        lower.contains('unexpected character') ||
        lower.contains('unexpected token') ||
        (lower.contains('type') && lower.contains('is not a subtype'))) {
      return 'Received an unexpected response. Please try again or contact support.';
    }

    if (original.trim().isEmpty) {
      return 'Something went wrong while loading the vehicle tags. Please try again.';
    }

    return 'Failed to load vehicle tags. ${original.trim()}';
  }
}
