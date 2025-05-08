import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final List<Widget> filters;
  final VoidCallback? onClearAll;
  final bool hasActiveFilters;

  const FilterBar({
    super.key,
    required this.filters,
    this.onClearAll,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (hasActiveFilters && onClearAll != null)
                TextButton.icon(
                  onPressed: onClearAll,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < filters.length; i++) ...[
                  filters[i],
                  if (i < filters.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
