import 'package:flutter/material.dart';

class EmptyDataTable extends StatefulWidget {
  final String title;
  final String errorMessage;
  final List<DataColumn> columns;
  final VoidCallback onRetry;
  final VoidCallback? onCreatePressed;
  final String createButtonText;
  final Widget? searchBar;

  const EmptyDataTable({
    super.key,
    required this.title,
    required this.errorMessage,
    required this.columns,
    required this.onRetry,
    this.onCreatePressed,
    this.createButtonText = 'Create New',
    this.searchBar,
  });

  @override
  State<EmptyDataTable> createState() => _EmptyDataTableState();
}

class _EmptyDataTableState extends State<EmptyDataTable> {
  // Create explicit ScrollController for horizontal scrolling
  final ScrollController _horizontalScrollController = ScrollController();

  final headerStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black, // or any color you prefer
  );

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title and Create Button in the same row
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Create button
              if (widget.onCreatePressed != null)
                ElevatedButton.icon(
                  onPressed: widget.onCreatePressed,
                  icon: const Icon(Icons.add),
                  label: Text(widget.createButtonText),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Search bar row
        if (widget.searchBar != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: widget.searchBar!,
          ),

        // Error message if present
        if (widget.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
                      widget.errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

        // Data table content - Always show the table structure
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Horizontal scroll hint
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

                // Table with horizontal scrolling - Always show the structure
                Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _horizontalScrollController,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Set a minimum width that's wider than the screen
                        minWidth: MediaQuery.of(context).size.width - 100,
                      ),
                      child: _buildTableContent(),
                    ),
                  ),
                ),

                // Pagination controls
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 36, 34, 34),
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: null, // Disabled for empty table
                        child: const Text('Previous'),
                      ),
                      Text(
                        'Page 1 of 1',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: null, // Disabled for empty table
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
      ],
    );
  }

  // Build the appropriate table content based on state
  Widget _buildTableContent() {
    return _buildTableWithMessage(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            widget.errorMessage,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper method to build a table with a centered message
  Widget _buildTableWithMessage(Widget messageWidget) {
    // Create a DataTable with the same columns but with a single row containing our message
    return DataTable(
      columns: widget.columns,
      rows: [
        DataRow(
          cells: [
            // First cell contains our message and spans all columns visually
            DataCell(
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: messageWidget,
                ),
              ),
            ),
            // Add empty cells for the remaining columns
            for (int i = 1; i < widget.columns.length; i++)
              const DataCell(SizedBox.shrink()),
          ],
        ),
      ],
      headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
      headingTextStyle: headerStyle,
      dataRowMinHeight: 48,
      dataRowMaxHeight: 64,
      horizontalMargin: 16,
      columnSpacing: 24,
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
    );
  }
}
