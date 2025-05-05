import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/entity/product_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_event.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';

import 'package:xpro_delivery_admin_app/src/master_data/product_list_screen/presentation/widgets/product_list_widget/product_search_bar_widget.dart';
//import 'package:xpro_delivery_admin_app/src/master_data/product_list_screen/presentation/widgets/product_list_widget/product_status_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProductDataTable extends StatelessWidget {
  final List<ProductEntity> products;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const ProductDataTable({
    super.key,
    required this.products,
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
      title: 'Products',
      searchBar: ProductSearchBar(
        controller: searchController,
        searchQuery: searchQuery,
        onSearchChanged: onSearchChanged,
      ),
      onCreatePressed: () {
        // Navigate to create product screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create product feature coming soon')),
        );
      },
      createButtonText: 'Create Product',
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Description')),
        DataColumn(label: Text('Price Per Case')),
        DataColumn(label: Text('Price Per Pc')),
        DataColumn(label: Text('Total Amount')),
        //  DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product.id ?? 'N/A')),
                DataCell(Text(product.name ?? 'N/A')),
                DataCell(Text(product.description ?? 'N/A')),
                DataCell(Text(_formatCurrency(product.pricePerCase))),
                DataCell(Text(_formatCurrency(product.pricePerPc))),
                DataCell(Text(_formatCurrency(product.totalAmount))),
                //   DataCell(ProductStatusChip(product: product)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () {
                          // View product details
                          if (product.id != null) {
                            // Navigate to product details screen
                            context.go('/product/${product.id}');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          // Edit product
                          if (product.id != null) {
                            // Navigate to edit screen with product data
                            context.go('/product/edit/${product.id}');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          // Show confirmation dialog before deleting
                          _showDeleteConfirmationDialog(context, product);
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
      onFiltered: () {
        // Show filter options
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filter options coming soon')),
        );
      },
      dataLength: '${products.length}', onDeleted: () {  },
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'N/A';

    final formatter = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    if (amount is double) {
      return formatter.format(amount);
    } else if (amount is int) {
      return formatter.format(amount.toDouble());
    } else if (amount is String) {
      try {
        return formatter.format(double.parse(amount));
      } catch (_) {
        return amount;
      }
    }
    return amount.toString();
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    ProductEntity product,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete product "${product.name}"?',
                ),
                const SizedBox(height: 10),
                const Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (product.id != null) {
                  context.read<ProductsBloc>().add(
                    DeleteProductEvent(product.id!),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
