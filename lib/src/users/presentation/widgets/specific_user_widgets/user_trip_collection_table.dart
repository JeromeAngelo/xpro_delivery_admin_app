import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/domain/entity/user_trip_collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';

class UserTripCollectionTable extends StatefulWidget {
  final List<UserTripCollectionEntity> tripCollections;
  final bool isLoading;
  final String userId;
  final VoidCallback? onRefresh;

  const UserTripCollectionTable({
    super.key,
    required this.tripCollections,
    required this.userId,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  State<UserTripCollectionTable> createState() => _UserTripCollectionTableState();
}

class _UserTripCollectionTableState extends State<UserTripCollectionTable> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter trip collections based on search query
    List<UserTripCollectionEntity> filteredCollections = widget.tripCollections;
    if (_searchQuery.isNotEmpty) {
      filteredCollections = widget.tripCollections.where((collection) {
        final query = _searchQuery.toLowerCase();
        final tripIds = collection.trips.map((trip) => trip.id?.toLowerCase() ?? '').join(' ');
        final tripNumbers = collection.trips.map((trip) => trip.tripNumberId?.toLowerCase() ?? '').join(' ');
        
        return tripIds.contains(query) || 
               tripNumbers.contains(query) || 
               (collection.id?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Calculate total pages
    final totalPages = (filteredCollections.length / _itemsPerPage).ceil();
    
    // Paginate collections
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage > filteredCollections.length 
        ? filteredCollections.length 
        : startIndex + _itemsPerPage;
    
    final paginatedCollections = startIndex < filteredCollections.length 
        ? filteredCollections.sublist(startIndex, endIndex) 
        : [];

    return DataTableLayout(
      title: 'Trip History',
      searchBar: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by Trip ID or Number...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _currentPage = 1; // Reset to first page when searching
          });
        },
      ),
      onCreatePressed: null, // No create button for history
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Trip Number')),
        DataColumn(label: Text('Trip Count')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Created')),
        DataColumn(label: Text('Updated')),
        DataColumn(label: Text('Actions')),
      ],
      rows: paginatedCollections.map((collection) {
        return DataRow(
          cells: [
            DataCell(Text(collection.id?.substring(0, 8) ?? 'N/A')),
            DataCell(
              collection.trips.isNotEmpty
                  ? Text(collection.trips.first.tripNumberId ?? 'N/A')
                  : const Text('N/A')
            ),
            DataCell(Text(collection.trips.length.toString())),
            DataCell(_buildStatusChip(collection.isActive ?? false)),
            DataCell(Text(_formatDate(collection.created))),
            DataCell(Text(_formatDate(collection.updated))),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'View Details',
                  onPressed: () {
                    // View trip collection details
                    _showTripDetailsDialog(context, collection);
                  },
                ),
              ],
            )),
          ],
        );
      }).toList(),
      currentPage: _currentPage,
      totalPages: totalPages > 0 ? totalPages : 1,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      isLoading: widget.isLoading,
      onFiltered: () {
        // Handle filtering
      },
      onDeleted: () {
        // Handle deletion
      },
      dataLength: filteredCollections.length.toString(),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Chip(
      label: Text(
        isActive ? 'Active' : 'Inactive',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: isActive ? Colors.green : Colors.grey,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  void _showTripDetailsDialog(BuildContext context, UserTripCollectionEntity collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trip Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ...collection.trips.map((trip) => ListTile(
                title: Text(trip.tripNumberId ?? 'No Trip Number'),
                subtitle: Text('ID: ${trip.id}'),
                leading: const Icon(Icons.receipt_long),
                trailing: trip.isEndTrip == true
                    ? const Chip(
                        label: Text('Completed', style: TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: Colors.green,
                      )
                    : const Chip(
                        label: Text('In Progress', style: TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: Colors.blue,
                      ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
