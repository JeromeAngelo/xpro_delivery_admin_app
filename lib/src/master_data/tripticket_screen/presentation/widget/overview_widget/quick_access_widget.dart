import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickAccessWidget extends StatelessWidget {
  const QuickAccessWidget({super.key});

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
              'Quick Access',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildQuickAccessButton(
                  context,
                  icon: Icons.add_circle,
                  label: 'Create Trip',
                  color: Colors.blue,
                  onTap: () => context.go('/tripticket-create'),
                ),
                const SizedBox(width: 16),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.visibility,
                  label: 'View All Trips',
                  color: Colors.green,
                  onTap: () => context.go('/tripticket'),
                ),
                const SizedBox(width: 16),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.check_circle,
                  label: 'Completed Trips',
                  color: Colors.orange,
                  onTap: () => context.go('/tripticket?filter=completed'),
                ),
                const SizedBox(width: 16),
                _buildQuickAccessButton(
                  context,
                  icon: Icons.pending_actions,
                  label: 'Pending Trips',
                  color: Colors.purple,
                  onTap: () => context.go('/tripticket?filter=pending'),
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
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
