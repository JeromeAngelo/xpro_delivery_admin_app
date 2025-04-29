import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/domain/entity/product_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:desktop_app/core/enums/products_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceProductsDataTable extends StatefulWidget {
  final List<ProductEntity> products;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback? onAddProduct;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const InvoiceProductsDataTable({
    super.key,
    required this.products,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    this.onAddProduct,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<InvoiceProductsDataTable> createState() =>
      _InvoiceProductsDataTableState();
}

class _InvoiceProductsDataTableState extends State<InvoiceProductsDataTable> {
  @override
  Widget build(BuildContext context) {
    return DataTableLayout(
      title: 'Invoice Products',
      searchBar: TextField(
        controller: widget.searchController,
        decoration: InputDecoration(
          hintText: 'Search products by name or description...',
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: widget.onSearchChanged,
      ),
      onCreatePressed: widget.onAddProduct,
      createButtonText: 'Add Product',
      columns: const [
        DataColumn(label: Text('ID')),

        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Description')),
        DataColumn(label: Text('Quantity')),
        //    DataColumn(label: Text('Unit Price')),
        DataColumn(label: Text('Total Amount')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          widget.products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product.id ?? 'N/A')),
                DataCell(Text(product.name ?? 'N/A')),
                DataCell(Text(product.description ?? 'N/A')),
                DataCell(Text(_formatQuantity(product))),
                //     DataCell(Text(_formatUnitPrice(product))),
                DataCell(Text(_formatAmount(product.totalAmount))),
                DataCell(_buildStatusChip(product.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () {
                          // View product details
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('View product details coming soon'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          // Edit product
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit product feature coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
      currentPage: widget.currentPage,
      totalPages: widget.totalPages,
      onPageChanged: widget.onPageChanged,
      isLoading: widget.isLoading,
      errorMessage: widget.errorMessage,
      onRetry: widget.onRetry,
      onFiltered: () {
        // Show filter options dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filter options coming soon')),
        );
      }, dataLength: '',
    );
  }

  String _formatQuantity(ProductEntity product) {
    List<String> quantities = [];

    if (product.case_ != null && product.case_ != 0) {
      quantities.add('${product.case_} Case');
    }
    if (product.pcs != null && product.pcs != 0) {
      quantities.add('${product.pcs} Pcs');
    }
    if (product.pack != null && product.pack != 0) {
      quantities.add('${product.pack} Pack');
    }
    if (product.box != null && product.box != 0) {
      quantities.add('${product.box} Box');
    }

    return quantities.isEmpty ? 'N/A' : quantities.join(', ');
  }

  // String _formatUnitPrice(ProductEntity product) {
  //   List<String> prices = [];

  //   if (product.pricePerCase != null && product.pricePerCase! > 0) {
  //     prices.add('₱${product.pricePerCase!.toStringAsFixed(2)}/Case');
  //   }
  //   if (product.pricePerPc != null && product.pricePerPc! > 0) {
  //     prices.add('₱${product.pricePerPc!.toStringAsFixed(2)}/Pc');
  //   }

  //   return prices.isEmpty ? 'N/A' : prices.join(', ');
  // }

  String _formatAmount(double? amount) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    return formatter.format(amount);
  }

  Widget _buildStatusChip(ProductsStatus? status) {
    Color color;
    String statusText;

    switch (status) {
      case ProductsStatus.truck:
        color = Colors.blue;
        statusText = 'In Truck';
        break;
      case ProductsStatus.unloading:
        color = Colors.orange;
        statusText = 'Unloading';
        break;
      case ProductsStatus.unloaded:
        color = Colors.amber;
        statusText = 'Unloaded';
        break;
      case ProductsStatus.completed:
        color = Colors.green;
        statusText = 'Completed';
        break;
      default:
        color = Colors.grey;
        statusText = 'Unknown';
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
