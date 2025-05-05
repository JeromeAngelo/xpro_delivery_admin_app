// import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/entity/auth_entity.dart';
// import 'package:xpro_delivery_admin_app/core/common/app/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:xpro_delivery_admin_app/core/common/app/features/auth/presentation/bloc/auth_event.dart';
// import 'package:xpro_delivery_admin_app/core/common/app/features/auth/presentation/bloc/auth_state.dart';
// import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
// import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
// import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/user_list_widgets/user_error.dart';
// import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/user_list_widgets/user_table.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// class UsersListView extends StatefulWidget {
//   const UsersListView({super.key});

//   @override
//   State<UsersListView> createState() => _UsersListViewState();
// }

// class _UsersListViewState extends State<UsersListView> {
//   int _currentPage = 1;
//   int _totalPages = 1;
//   final int _itemsPerPage = 25;
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();
  
//   @override
//   void initState() {
//     super.initState();
//     // Load users when the screen initializes
//     context.read<AuthBloc>().add(const GetAllUsersEvent());
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Define navigation items
//     final navigationItems = AppNavigationItems.usersNavigationItems();

//     return DesktopLayout(
//       navigationItems: navigationItems,
//       currentRoute: '/users',
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
//       child: BlocBuilder<AuthBloc, AuthState>(
//         builder: (context, state) {
//           // Handle different states
//           if (state is AuthInitial) {
//             // Initial state, trigger loading
//             context.read<AuthBloc>().add(const GetAllUsersEvent());
//             return const Center(child: CircularProgressIndicator());
//           }
          
//           if (state is AuthLoading) {
//             return UserDataTable(
//               users: [],
//               isLoading: true,
//               currentPage: _currentPage,
//               totalPages: _totalPages,
//               onPageChanged: (page) {
//                 setState(() {
//                   _currentPage = page;
//                 });
//               },
//               searchController: _searchController,
//               searchQuery: _searchQuery,
//               onSearchChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//             );
//           }
          
//           if (state is AuthError) {
//             return UserErrorWidget(errorMessage: state.message);
//           }
          
//           if (state is UsersLoaded) {
//             List<AuthEntity> users = state.users;
            
//             // Filter users based on search query
//             if (_searchQuery.isNotEmpty) {
//               users = users.where((user) {
//                 final query = _searchQuery.toLowerCase();
//                 return (user.name?.toLowerCase().contains(query) ?? false) ||
//                        (user.email?.toLowerCase().contains(query) ?? false) ||
//                        (user.role?.toString().toLowerCase().contains(query) ?? false);
//               }).toList();
//             }
            
//             // Calculate total pages
//             _totalPages = (users.length / _itemsPerPage).ceil();
//             if (_totalPages == 0) _totalPages = 1;
            
//             // Paginate users
//             final startIndex = (_currentPage - 1) * _itemsPerPage;
//             final endIndex = startIndex + _itemsPerPage > users.length 
//                 ? users.length 
//                 : startIndex + _itemsPerPage;
            
//             final paginatedUsers = startIndex < users.length 
//                 ? users.sublist(startIndex, endIndex) 
//                 : [];
            
//             return UserDataTable(
//               users: paginatedUsers as List<AuthEntity>,
//               isLoading: false,
//               currentPage: _currentPage,
//               totalPages: _totalPages,
//               onPageChanged: (page) {
//                 setState(() {
//                   _currentPage = page;
//                 });
//               },
//               searchController: _searchController,
//               searchQuery: _searchQuery,
//               onSearchChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//                 // If search query is empty, refresh the users list
//                 if (value.isEmpty) {
//                   context.read<AuthBloc>().add(const GetAllUsersEvent());
//                 }
//               },
//             );
//           }
          
//           // Default fallback
//           return const Center(child: Text('Unknown state'));
//         },
//       ),
//     );
//   }
// }
