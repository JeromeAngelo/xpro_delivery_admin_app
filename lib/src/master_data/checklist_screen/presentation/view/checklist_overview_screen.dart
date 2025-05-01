// import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
// import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class ChecklistsOverviewScreenView extends StatelessWidget {
//   const ChecklistsOverviewScreenView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Define navigation items
//     final navigationItems = AppNavigationItems.tripticketNavigationItems();

//     return DesktopLayout(
//       userName: 'Admin User',
//       navigationItems: navigationItems,
//       currentRoute: '/checklists-overview',
//       onNavigate: (route) {
//         // Handle navigation using GoRouter
//         context.go(route);
//       },
//       onThemeToggle: () {
//         // Handle theme toggle
//       },
//       onNotificationTap: () {
//         // Handle notification tap
//       },
//       onProfileTap: () {
//         // Handle profile tap
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Checklists',
//               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Manage different types of checklists for your delivery operations',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 32),
//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 24,
//                 mainAxisSpacing: 24,
//                 children: [
//                   _buildChecklistCard(
//                     context,
//                     title: 'In Transit Checklist',
//                     description: 'Manage checklists for vehicles during transit',
//                     icon: Icons.fact_check,
//                     color: Colors.blue,
//                     onTap: () => context.go('/checklist'),
//                   ),
//                   _buildChecklistCard(
//                     context,
//                     title: 'End Trip Checklist',
//                     description: 'Manage checklists for completing delivery trips',
//                     icon: Icons.assignment_turned_in,
//                     color: Colors.green,
//                     onTap: () => context.go('/end-trip-checklist'),
//                   ),
//                   _buildChecklistCard(
//                     context,
//                     title: 'Checklist Templates',
//                     description: 'Create and manage reusable checklist templates',
//                     icon: Icons.list_alt,
//                     color: Colors.purple,
//                     onTap: () => _showFeatureComingSoon(context),
//                   ),
//                   _buildChecklistCard(
//                     context,
//                     title: 'Checklist Reports',
//                     description: 'View analytics and reports on checklist completion',
//                     icon: Icons.analytics,
//                     color: Colors.orange,
//                     onTap: () => _showFeatureComingSoon(context),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChecklistCard(
//     BuildContext context, {
//     required String title,
//     required String description,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, size: 64, color: color),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 title,
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 description,
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFeatureComingSoon(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('This feature is coming soon!'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
// }
