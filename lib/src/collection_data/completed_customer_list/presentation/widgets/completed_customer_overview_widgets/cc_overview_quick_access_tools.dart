import 'package:flutter/material.dart';

class QuickAccessTools extends StatelessWidget {
  final VoidCallback? onExportData;
  final VoidCallback? onGenerateReport;
  final VoidCallback? onFilterData;
  final VoidCallback? onSearchCustomers;

  const QuickAccessTools({
    Key? key,
    this.onExportData,
    this.onGenerateReport,
    this.onFilterData,
    this.onSearchCustomers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Access Tools',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAccessButton(
                  context,
                  icon: Icons.file_download,
                  label: 'Export Data',
                  color: Colors.blue,
                  onPressed: onExportData,
                ),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.assessment,
                  label: 'Generate Report',
                  color: Colors.green,
                  onPressed: onGenerateReport,
                ),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.filter_list,
                  label: 'Filter Data',
                  color: Colors.orange,
                  onPressed: onFilterData,
                ),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.search,
                  label: 'Search Customers',
                  color: Colors.purple,
                  onPressed: onSearchCustomers,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
