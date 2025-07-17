import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/entity/customer_data_entity.dart';

class CustomerDataDialog extends StatefulWidget {
  final Function(List<CustomerDataEntity>) onCustomersSelected;

  const CustomerDataDialog({
    super.key,
    required this.onCustomersSelected,
  });

  @override
  State<CustomerDataDialog> createState() => _CustomerDataDialogState();
}

class _CustomerDataDialogState extends State<CustomerDataDialog> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedCustomerIds = {};
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() {
    context.read<CustomerDataBloc>().add(
      const GetAllUnassignedCustomerDataEvent(),
    );
  }

  void _closeDialog() {
    if (mounted) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Select Customers',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCustomers,
                  tooltip: 'Refresh list',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _closeDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Customer Name or Ref ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<CustomerDataBloc, CustomerDataState>(
                builder: (context, state) {
                  if (state is CustomerDataLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CustomerDataError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadCustomers,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AllUnassignedCustomerDataLoaded) {
                    var customers = state.unassignedCustomerData;

                    // Apply local search filtering
                    if (_searchController.text.trim().isNotEmpty) {
                      final query = _searchController.text.trim().toLowerCase();
                      customers = customers.where((customer) {
                        return (customer.name?.toLowerCase().contains(query) ?? false) ||
                               (customer.refId?.toLowerCase().contains(query) ?? false);
                      }).toList();
                    }

                    if (customers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.trim().isNotEmpty
                                  ? 'No customers found matching "${_searchController.text.trim()}"'
                                  : 'No customers found',
                              style: const TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Selection controls
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _selectedCustomerIds.length == customers.length && customers.isNotEmpty,
                                tristate: true,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      // Select all
                                      _selectedCustomerIds.clear();
                                      _selectedCustomerIds.addAll(
                                        customers.map((c) => c.id!),
                                      );
                                    } else {
                                      // Deselect all
                                      _selectedCustomerIds.clear();
                                    }
                                  });
                                },
                              ),
                              Text(
                                'Select All (${_selectedCustomerIds.length}/${customers.length})',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Customer list
                        Expanded(
                          child: ListView.builder(
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              final isSelected = _selectedCustomerIds.contains(customer.id);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: isSelected ? Colors.blue.shade50 : null,
                                child: ListTile(
                                  leading: Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedCustomerIds.add(customer.id!);
                                        } else {
                                          _selectedCustomerIds.remove(customer.id!);
                                        }
                                      });
                                    },
                                  ),
                                  title: Text(
                                    customer.name ?? 'Unnamed Customer',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ref ID: ${customer.refId ?? 'N/A'}'),
                                      Text('${customer.municipality ?? ''}, ${customer.province ?? ''}'),
                                      if (customer.barangay != null)
                                        Text('Barangay: ${customer.barangay}'),
                                    ],
                                  ),
                                  trailing: CircleAvatar(
                                    child: Icon(
                                      Icons.person,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedCustomerIds.remove(customer.id!);
                                      } else {
                                        _selectedCustomerIds.add(customer.id!);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(
                    child: Text('Select customers from the list'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Bulk selection button
            BlocBuilder<CustomerDataBloc, CustomerDataState>(
              builder: (context, state) {
                final isLoading = state is CustomerDataLoading || _isProcessing;

                return ElevatedButton.icon(
                  onPressed: (_selectedCustomerIds.isNotEmpty && !isLoading)
                      ? () {
                          setState(() {
                            _isProcessing = true;
                          });

                          debugPrint(
                            '🔘 Selecting ${_selectedCustomerIds.length} customers',
                          );

                          // Get selected customers from the current state
                          if (state is AllUnassignedCustomerDataLoaded) {
                            final selectedCustomers = state.unassignedCustomerData
                                .where((customer) => _selectedCustomerIds.contains(customer.id))
                                .toList();

                            // Apply search filter if active
                            var filteredCustomers = selectedCustomers;
                            if (_searchController.text.trim().isNotEmpty) {
                              final query = _searchController.text.trim().toLowerCase();
                              filteredCustomers = selectedCustomers.where((customer) {
                                return (customer.name?.toLowerCase().contains(query) ?? false) ||
                                       (customer.refId?.toLowerCase().contains(query) ?? false);
                              }).toList();
                            }

                            widget.onCustomersSelected(filteredCustomers);
                            _closeDialog();
                          }

                          setState(() {
                            _isProcessing = false;
                          });
                        }
                      : null,
                  icon: isLoading
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                  isLoading
                  ? 'Invoice processing to delivery...'
                  : 'Select ${_selectedCustomerIds.length} Customer${_selectedCustomerIds.length != 1 ? 's' : ''}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}