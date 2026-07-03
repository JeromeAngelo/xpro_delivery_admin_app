import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/domain/entity/vehicle_tag_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_event.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:xpro_delivery_admin_app/src/vehicle_management/widgets/vehicle_widgets/vehicle_screen_widgets/vehicle_search_bar.dart';

class VehicleTagDataTable extends StatelessWidget {
  final List<VehicleTagEntity> tags;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const VehicleTagDataTable({
    super.key,
    required this.tags,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DataTableLayout(
      title: 'Vehicle Tags',
      searchBar: VehicleSearchBar(
        controller: searchController,
        searchQuery: searchQuery,
        onSearchChanged: onSearchChanged,
      ),
      onCreatePressed: () {
        context.go('/create-vehicle-tag');
      },
      createButtonText: 'Add Vehicle Tag',
      columns: const [
        DataColumn(label: Text('Label')),
        DataColumn(label: Text('Description')),
        DataColumn(label: Text('Types')),
        DataColumn(label: Text('Sticker Number')),
        DataColumn(label: Text('Expiration')),
        DataColumn(label: Text('Created')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          tags.map((tag) {
            return DataRow(
              cells: [
                DataCell(
                  Text(tag.label ?? 'N/A'),
                  onTap: () => _navigateToTagDetails(context, tag),
                ),
                DataCell(
                  Text(tag.description ?? 'N/A'),
                  onTap: () => _navigateToTagDetails(context, tag),
                ),
                DataCell(
                  _buildTypeChips(tag.types),
                  onTap: () => _navigateToTagDetails(context, tag),
                ),
                DataCell(
                  Text(tag.stickerNumber ?? 'N/A'),
                  onTap: () => _navigateToTagDetails(context, tag),
                ),
                DataCell(
                  Text(_formatDate(tag.expiration)),
                  onTap: () => _navigateToTagDetails(context, tag),
                ),
                DataCell(Text(_formatDate(tag.created))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () => _navigateToTagDetails(context, tag),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          if (tag.id != null) {
                            context.go('/update-vehicle-tag/${tag.id}');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          // TODO: Show confirmation dialog before deleting
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      isLoading: isLoading,
      dataLength: '${tags.length}',
      onDeleted: () {},
    );
  }

  void _navigateToTagDetails(BuildContext context, VehicleTagEntity tag) {
    if (tag.id != null) {
      context.read<VehicleTagBloc>().add(LoadVehicleTagByIdEvent(tag.id!));
      context.go('/vehicle-tag/${tag.id}');
    }
  }

  Widget _buildTypeChips(List<dynamic>? types) {
    if (types == null || types.isEmpty) {
      return const Text('N/A');
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children:
          types.map((type) {
            final label = type.toString().split('.').last;
            return Chip(
              label: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: _chipColorForType(label),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            );
          }).toList(),
    );
  }

  Color _chipColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'sticker':
        return Colors.indigo;
      case 'restrictions':
        return Colors.redAccent;
      case 'permit':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
