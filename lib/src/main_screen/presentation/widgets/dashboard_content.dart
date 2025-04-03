import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Master Data',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  icon: Icons.receipt_long,
                  title: 'Trip Tickets',
                  subtitle: 'Manage delivery trips',
                  color: Colors.blue,
                  onTap: () => context.push('/tripticket'),
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.store,
                  title: 'Customers',
                  subtitle: 'View customer details',
                  color: Colors.green,
                  onTap:
                      () =>
                          Navigator.pushReplacementNamed(context, '/customers'),
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.people,
                  title: 'Users',
                  subtitle: 'Manage system users',
                  color: Colors.orange,
                  onTap:
                      () => Navigator.pushReplacementNamed(context, '/users'),
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.assignment_return,
                  title: 'Returns',
                  subtitle: 'Track returned items',
                  color: Colors.red,
                  onTap:
                      () => Navigator.pushReplacementNamed(context, '/returns'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
