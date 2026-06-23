import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/domain/entity/vehicle_profile_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';

/// Read-only dashboard that surfaces a single [VehicleProfileEntity] fetched
/// via [GetVehicleProfileByDeliveryVehicleIdEvent] (the new "by delivery
/// vehicle data id" usecase) and renders it using the same `DataTableLayout`
/// style as the assigned-trips table.
class VehicleProfileDashboard extends StatefulWidget {
  /// The `deliveryVehicleData` record id used by the
  /// `GetVehicleProfileByDeliveryVehicleIdEvent`.
  final String deliveryVehicleDataId;

  /// Pagination – mirrors the assigned-trips table contract.
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  /// Search bar state – mirrors the assigned-trips table contract.
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  /// Optional callback fired when the user taps "View". Defaults to a no-op.
  final VoidCallback? onView;

  /// Optional callback fired when the user taps "Edit". Defaults to a no-op.
  final VoidCallback? onEdit;

  /// Optional callback fired when the user taps "Delete". Defaults to a no-op.
  final VoidCallback? onDelete;

  const VehicleProfileDashboard({
    super.key,
    required this.deliveryVehicleDataId,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<VehicleProfileDashboard> createState() =>
      _VehicleProfileDashboardState();
}

class _VehicleProfileDashboardState extends State<VehicleProfileDashboard> {
  @override
  void initState() {
    super.initState();
    // Defer the dispatch to after the first frame so the surrounding
    // `BlocProvider` is guaranteed to be available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchProfile();
    });
  }

  void _fetchProfile() {
    if (widget.deliveryVehicleDataId.isEmpty) return;
    try {
      context.read<VehicleProfileBloc>().add(
        GetVehicleProfileByDeliveryVehicleIdEvent(widget.deliveryVehicleDataId),
      );
    } catch (_) {
      // Bloc not available in this subtree – ignore.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleProfileBloc, VehicleProfileState>(
      builder: (context, state) {
        VehicleProfileEntity? profile;
        bool loading = false;
        String? errorMessage;

        if (state is VehicleProfileLoading) {
          loading = true;
          debugPrint('🔄 [PROFILE DASHBOARD] Loading vehicle profile...');
        } else if (state is VehicleProfileByDeliveryVehicleIdLoaded) {
          final candidate = state.vehicleProfile;
          // Only adopt the loaded profile if it actually belongs to the
          // requested delivery vehicle – guards against races when the
          // user navigates between vehicles quickly.
          if (candidate.deliveryVehicleData?.id ==
              widget.deliveryVehicleDataId) {
            profile = candidate;
            debugPrint('✅ [PROFILE DASHBOARD] Profile loaded: ${profile.id}');
          } else {
            debugPrint(
              '⚠️ [PROFILE DASHBOARD] Loaded profile does not match '
              'requested deliveryVehicleDataId – ignoring.',
            );
          }
        } else if (state is VehicleProfileByIdLoaded) {
          // Fallback: if the dashboard was somehow reached with a profile
          // fetched by record-id, surface it as well.
          profile = state.vehicleProfile;
        } else if (state is VehicleProfileError) {
          errorMessage = _humanizeError(state.message);
          debugPrint(
            '❌ [PROFILE DASHBOARD] Error loading profile: ${state.message}',
          );
        }

        return DataTableLayout(
          title: 'Vehicle Profile',
          searchBar: TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              hintText: 'Search by Plate, Make, Model, Status, or Province...',
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
            DataColumn(label: Text('Plate No.')),
            DataColumn(label: Text('Make / Model')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Assigned Region(s)')),
            DataColumn(label: Text('Assigned Province(s)')),
            DataColumn(label: Text('Designated Municipality')),
            DataColumn(label: Text('Attachments')),
            DataColumn(label: Text('Last Updated')),
            DataColumn(label: Text('Actions')),
          ],

          rows:
              profile == null
                  ? const []
                  : [
                    DataRow(
                      cells: [
                        // Plate No.
                        DataCell(
                          Text(
                            profile.deliveryVehicleData?.name ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        // Make / Model
                        DataCell(
                          Text(
                            '${profile.deliveryVehicleData?.make ?? 'N/A'} '
                                    '${profile.deliveryVehicleData?.name ?? ''}'
                                .trim(),
                          ),
                        ),

                        // Status (chip)
                        DataCell(_buildStatusChip(profile.status)),

                        // Assigned Region(s) — one chip per region
                        DataCell(_buildRegionChips(profile.assignedRegions)),

                        // Assigned Province(s) — one chip per province
                        DataCell(
                          _buildProvinceChips(profile.assignedProvinces),
                        ),

                        // Designated Municipality
                        DataCell(
                          Text(
                            _cleanRelationLabel(
                                  profile.designatedMunicipality,
                                ) ??
                                'N/A',
                          ),
                        ),

                        // Attachments
                        DataCell(
                          Text(
                            (profile.attachments == null ||
                                    profile.attachments!.isEmpty)
                                ? '0'
                                : '${profile.attachments!.length} file(s)',
                          ),
                        ),

                        // Last Updated
                        DataCell(Text(_fmtDate(profile.updated))),

                        // Actions
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                tooltip: 'View Profile',
                                onPressed:
                                    profile.id == null
                                        ? null
                                        : () {
                                          if (widget.onView != null) {
                                            widget.onView!();
                                          } else {
                                            // Default behaviour: navigate to
                                            // the specific profile route.
                                          }
                                        },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                tooltip: 'Edit Profile',
                                onPressed:
                                    profile.id == null
                                        ? null
                                        : () {
                                          if (widget.onEdit != null) {
                                            widget.onEdit!();
                                          } else {
                                            context.go(
                                              '/vehicle/${profile!.id}/edit',
                                            );
                                          }
                                        },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete Profile',
                                onPressed: () {
                                  if (widget.onDelete != null) {
                                    widget.onDelete!();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

          currentPage: widget.currentPage,
          totalPages: widget.totalPages,
          onPageChanged: widget.onPageChanged,

          isLoading: loading,
          errorMessage: errorMessage,
          onRetry: errorMessage != null ? () => _fetchProfile() : null,

          onFiltered: null,
          dataLength: profile == null ? '0' : '1',
          onDeleted: () {},
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  /// Strips the surrounding square brackets that PocketBase sometimes wraps
  /// relation-field values in (e.g. `[Pampanga]` → `Pampanga`).
  String? _cleanRelationLabel(String? raw) {
    if (raw == null) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;
    if (value.length >= 2 && value.startsWith('[') && value.endsWith(']')) {
      value = value.substring(1, value.length - 1).trim();
    }
    if (value.isEmpty) return null;
    return value;
  }

  /// Translates a raw PocketBase / network error string into a
  /// short, user-friendly message.
  ///
  /// PocketBase surfaces errors in a few shapes:
  ///   * `Failed to load resource (404).` — record missing.
  ///   * `Client error with status code: 401` — auth issue.
  ///   * `Client error with status code: 403` — forbidden.
  ///   * `Client error with status code: 400` — bad request.
  ///   * `Client error with status code: 500` — server bug.
  ///   * `SocketException` / `Connection refused` — no network.
  ///   * `TimeoutException` — slow network.
  ///   * `FormatException` — unexpected server response shape.
  ///
  /// Anything we can't classify falls back to a generic message.
  String _humanizeError(String? raw) {
    final original = raw ?? '';
    final lower = original.toLowerCase();

    // ---- 404 — record not found ----
    if (lower.contains('404') ||
        lower.contains('not found') ||
        lower.contains('failed to load resource')) {
      return 'No vehicle profile found for this vehicle yet. '
          'Create one from the Create Vehicle screen.';
    }

    // ---- 401 / unauthorized ----
    if (lower.contains('401') || lower.contains('unauthorized')) {
      return 'You are not signed in or your session has expired. '
          'Please sign in again.';
    }

    // ---- 403 / forbidden ----
    if (lower.contains('403') ||
        lower.contains('forbidden') ||
        lower.contains('not allowed')) {
      return 'You don\'t have permission to view this profile. '
          'Contact your administrator.';
    }

    // ---- 400 — bad request / validation ----
    if (lower.contains('400') ||
        lower.contains('bad request') ||
        lower.contains('validation')) {
      return 'The request was invalid. '
          'Please refresh the page or contact support.';
    }

    // ---- 408 / timeout ----
    if (lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('408')) {
      return 'The request timed out. Check your internet connection '
          'and try again.';
    }

    // ---- 500 / 502 / 503 / 504 — server-side ----
    if (lower.contains('500') ||
        lower.contains('502') ||
        lower.contains('503') ||
        lower.contains('504') ||
        lower.contains('internal server error') ||
        lower.contains('bad gateway') ||
        lower.contains('service unavailable')) {
      return 'The server is temporarily unavailable. '
          'Please try again in a moment.';
    }

    // ---- Network / socket / DNS ----
    if (lower.contains('socketexception') ||
        lower.contains('connection refused') ||
        lower.contains('connection failed') ||
        lower.contains('network is unreachable') ||
        lower.contains('failed host lookup') ||
        lower.contains('no internet') ||
        lower.contains('no address associated with hostname')) {
      return 'Cannot reach the server. '
          'Check your internet connection and try again.';
    }

    // ---- Response parsing ----
    if (lower.contains('formatexception') ||
        lower.contains('unexpected character') ||
        lower.contains('unexpected token') ||
        lower.contains('type') && lower.contains('is not a subtype')) {
      return 'Received an unexpected response from the server. '
          'Please try again or contact support.';
    }

    // ---- Empty / unknown ----
    if (original.trim().isEmpty) {
      return 'Something went wrong while loading the profile. '
          'Please try again.';
    }

    // ---- Fallback: trim and surface as-is ----
    return 'Failed to load profile. ${original.trim()}';
  }

  /// Renders a list of [RegionEntity] as compact `Chip`s inside a
  /// `Wrap`. Each chip displays the region as "`name` - `alias`".
  /// Returns a fallback "N/A" when the list is null or empty.
  Widget _buildRegionChips(List<dynamic>? regions) {
    if (regions == null || regions.isEmpty) {
      return const Text('N/A');
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final r in regions)
            Chip(
              label: Text(
                _formatRegionLabel(r.name, r.alias),
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

  /// Renders a list of [ProvinceEntity] as compact `Chip`s inside a
  /// `Wrap`. Each chip displays the province `name`. Returns a
  /// fallback "N/A" when the list is null or empty.
  Widget _buildProvinceChips(List<dynamic>? provinces) {
    if (provinces == null || provinces.isEmpty) {
      return const Text('N/A');
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final p in provinces)
            Chip(
              label: Text(
                (p.name ?? '').toString(),
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: Colors.teal.shade50,
              side: BorderSide(color: Colors.teal.shade200),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            ),
        ],
      ),
    );
  }

  /// Format a region as "`name` - `alias`" (e.g.
  /// `Region III - Central Luzon`). Falls back to just the name
  /// when no alias is available, and to "Unnamed" when both are
  /// empty.
  String _formatRegionLabel(dynamic name, dynamic alias) {
    final n = (name ?? '').toString().trim();
    final a = (alias ?? '').toString().trim();
    if (n.isEmpty && a.isEmpty) return 'Unnamed';
    if (a.isEmpty) return n;
    if (n.isEmpty) return a;
    return '$n - $a';
  }

  /// Builds a coloured status chip that reflects the [VehicleStatus] enum.
  Widget _buildStatusChip(VehicleStatus? status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case VehicleStatus.goodCondition:
        color = Colors.green;
        label = 'Good Condition';
        icon = Icons.verified;
        break;
      case VehicleStatus.underMaintenance:
        color = Colors.orange;
        label = 'Under Maintenance';
        icon = Icons.build;
        break;
      case VehicleStatus.inspectionRequired:
        color = Colors.amber.shade700;
        label = 'Inspection Required';
        icon = Icons.fact_check_outlined;
        break;
      case VehicleStatus.outOfService:
        color = Colors.red;
        label = 'Out of Service';
        icon = Icons.block;
        break;
      case VehicleStatus.retired:
        color = Colors.grey;
        label = 'Retired';
        icon = Icons.archive_outlined;
        break;
      default:
        color = Colors.blueGrey;
        label = 'Unknown';
        icon = Icons.help_outline;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      side: BorderSide.none,
    );
  }

  String _fmtDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MM/dd/yyyy hh:mm a').format(date);
  }
}
