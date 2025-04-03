import 'package:flutter/material.dart';

class EmptyDataTable extends StatelessWidget {
  final String title;
  final String errorMessage;
  final List<DataColumn> columns;
  final VoidCallback? onRetry;
  final VoidCallback? onCreatePressed;
  final String createButtonText;
  final Widget? searchBar;

  const EmptyDataTable({
    super.key,
    required this.title,
    required this.errorMessage,
    required this.columns,
    this.onRetry,
    this.onCreatePressed,
    this.createButtonText = 'Create New',
    this.searchBar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and actions row
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onCreatePressed != null)
                ElevatedButton.icon(
                  onPressed: onCreatePressed,
                  icon: const Icon(Icons.add),
                  label: Text(createButtonText),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
            ],
          ),
        ),
        
        // Search bar row
        if (searchBar != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: searchBar!,
          ),
        
        // Error message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
                if (onRetry != null)
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
              ],
            ),
          ),
        ),
        
        // Empty data table
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table header with hint about scrolling
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.swipe, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Scroll horizontally to see more',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Empty table with error message
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - 64,
                          ),
                          child: _buildEmptyTableWithErrorMessage(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Pagination row (disabled in error state)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Company name or copyright
              Text(
                '© ${DateTime.now().year} X-Pro Delivery',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              
              // Pagination controls (disabled)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.grey),
                    onPressed: null,
                  ),
                  Text('Page 1 of 1', style: TextStyle(color: Colors.grey[600])),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.grey),
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTableWithErrorMessage(BuildContext context) {
    return DataTable(
      columns: columns,
      rows: [
        DataRow(
          cells: [
            // First cell contains our error message and spans all columns visually
            DataCell(
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 200,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error Loading Data',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (onRetry != null)
                        ElevatedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Add empty cells for the remaining columns
            for (int i = 1; i < columns.length; i++)
              const DataCell(SizedBox.shrink()),
          ],
        ),
      ],
      headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
      dataRowMinHeight: 200,
      dataRowMaxHeight: 300,
      horizontalMargin: 16,
      columnSpacing: 24,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
    );
  }
}
