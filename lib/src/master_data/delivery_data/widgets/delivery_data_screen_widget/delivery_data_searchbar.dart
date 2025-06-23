import 'package:flutter/material.dart';

class DeliveryDataSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onRefreshPressed;

  const DeliveryDataSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onSearchChanged,
    this.onFilterPressed,
    this.onRefreshPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (onRefreshPressed != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefreshPressed,
                tooltip: 'Refresh Data',
              ),
            if (onFilterPressed != null)
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: onFilterPressed,
                tooltip: 'Filter Options',
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText:
                'Search by delivery number, customer name, invoice, or trip...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          onChanged: onSearchChanged,
        ),
        if (searchQuery.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Searching: "$searchQuery"',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    controller.clear();
                    onSearchChanged('');
                  },
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
