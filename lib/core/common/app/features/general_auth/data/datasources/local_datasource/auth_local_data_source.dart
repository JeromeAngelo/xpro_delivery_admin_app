// import 'dart:convert';

// import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
// import 'package:xpro_delivery_admin_app/core/common/app/features/driver_auth/data/models/auth_models.dart';
// import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
// import 'package:xpro_delivery_admin_app/objectbox.g.dart';
// import 'package:flutter/material.dart';
// import 'package:objectbox/objectbox.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// abstract class AuthLocalDataSrc {
//   Future<LocalUsersModel> getLocalUser();
//   Future<LocalUsersModel> loadLocalUserById(String userId);
//   Future<void> saveUser(LocalUsersModel user);
//   Future<void> clearUser();
//   Future<bool> hasUser();
//   Future<TripModel> loadLocalUserTrip(String userId);
//   // New sync methods
//   Future<void> cacheUserData(LocalUsersModel user);
//   Future<void> cacheUserTripData(TripModel trip);

// }

// class AuthLocalDataSrcImpl implements AuthLocalDataSrc {
//   final Box<LocalUsersModel> _box;
//   final SharedPreferences _prefs;

//   AuthLocalDataSrcImpl(Store store, this._prefs) : _box = store.box<LocalUsersModel>();
// @override
// Future<LocalUsersModel> getLocalUser() async {
//   try {
//     debugPrint('🔍 Fetching user from local storage');
//     final prefs = await SharedPreferences.getInstance();
//     final storedData = prefs.getString('user_data');
    
//     if (storedData != null) {
//       debugPrint('📦 Raw stored user data: $storedData');
//       final userData = jsonDecode(storedData);
      
//       // Create model with proper token mapping
//       final user = LocalUsersModel(
//         id: userData['id'],
//         collectionId: userData['collectionId'],
//         collectionName: userData['collectionName'],
//         email: userData['email'],
//         name: userData['name'],
//         tripNumberId: userData['tripNumberId'],
//         token: userData['tokenKey'], // Map tokenKey to token
//       );
      
//       debugPrint('✅ Successfully loaded user from local storage');
//       debugPrint('   👤 User: ${user.name}');
//       debugPrint('   🎫 Trip ID: ${user.tripId}');
//       debugPrint('   🔑 Token: ${user.token?.substring(0, 10)}...');
      
//       return user;
//     }
//     throw const CacheException(message: 'No stored user data found');
//   } catch (e) {
//     throw CacheException(message: e.toString());
//   }
// }
// @override
// Future<LocalUsersModel> loadLocalUserById(String userId) async {
//   try {
//     debugPrint('🔍 Fetching user by ID from local storage: $userId');
    
//     // Try SharedPreferences first
//     final prefs = await SharedPreferences.getInstance();
//     final storedData = prefs.getString('user_data');
    
//     if (storedData != null) {
//       final userData = jsonDecode(storedData);
//       if (userData['id'] == userId) {
//         debugPrint('📦 Found user in SharedPreferences');
//         return LocalUsersModel(
//           id: userData['id'],
//           collectionId: userData['collectionId'],
//           collectionName: userData['collectionName'],
//           email: userData['email'],
//           name: userData['name'],
//           tripNumberId: userData['tripNumberId'],
//           token: userData['tokenKey'],
//         );
//       }
//     }

//     // Fallback to ObjectBox
//     String actualUserId;
//     if (userId.startsWith('{')) {
//       final userData = jsonDecode(userId);
//       actualUserId = userData['id'];
//     } else {
//       actualUserId = userId;
//     }

//     final user = _box
//         .query(LocalUsersModel_.pocketbaseId.equals(actualUserId))
//         .build()
//         .findFirst();

//     if (user == null) {
//       debugPrint('⚠️ User not found in local storage');
//       throw const CacheException(message: 'User not found in local storage');
//     }

//     debugPrint('✅ Successfully loaded user by id: ${user.name}');
//     debugPrint('   🎫 Trip ID: ${user.tripId}');
//     debugPrint('   🚛 Delivery Team ID: ${user.deliveryTeamId}');
//     debugPrint('   🔑 Token: ${user.token?.substring(0, 10)}...');

//     return user;
//   } catch (e) {
//     debugPrint('❌ Local storage error: ${e.toString()}');
//     throw CacheException(message: e.toString());
//   }
// }

//   @override
// Future<void> saveUser(LocalUsersModel user) async {
//   try {
//     debugPrint('💾 Saving user data to local storage');
//     await clearUser();  // Clear any existing user data
    
//     // Save to ObjectBox
//     await _autoSave(user);
    
//     // Save to SharedPreferences for persistent session
//     final prefs = await SharedPreferences.getInstance();
//     final userData = {
//       'id': user.id,
//       'collectionId': user.collectionId,
//       'collectionName': user.collectionName,
//       'email': user.email,
//       'name': user.name,
//       'tripNumberId': user.tripNumberId,
//       'tokenKey': user.token,
     
//     };
    
//     await prefs.setString('user_data', jsonEncode(userData));
//     await prefs.setString('auth_token', user.token ?? '');
    
//     debugPrint('✅ User data saved successfully');
//     debugPrint('   👤 User: ${user.name}');
//     debugPrint('   📧 Email: ${user.email}');
//     debugPrint('   🆔 ID: ${user.id}');
//     debugPrint('   🔑 Token: ${user.token?.substring(0, 10)}...');
//   } catch (e) {
//     debugPrint('❌ Failed to save user: ${e.toString()}');
//     throw CacheException(message: e.toString());
//   }
// }


//   Future<void> _autoSave(LocalUsersModel user) async {
//     try {
//       debugPrint('🔍 Processing user: ${user.name} (PocketBase ID: ${user.pocketbaseId})');

//       final existingUser = _box
//           .query(LocalUsersModel_.pocketbaseId.equals(user.pocketbaseId))
//           .build()
//           .findFirst();

//       if (existingUser != null) {
//         debugPrint('🔄 Updating existing user: ${user.name}');
//         user.objectBoxId = existingUser.objectBoxId;
//       } else {
//         debugPrint('➕ Adding new user: ${user.name}');
//       }

//       _box.put(user);
      
//       // Save to SharedPreferences
//       await _prefs.setString('user_data', user.toJson().toString());
      
//       final totalUsers = _box.count();
//       debugPrint('📊 Current total users: $totalUsers');
//     } catch (e) {
//       debugPrint('❌ Save operation failed: ${e.toString()}');
//       throw CacheException(message: e.toString());
//     }
//   }

//   @override
//   Future<void> clearUser() async {
//     debugPrint('🧹 Clearing user data from local storage');
//     _box.removeAll();
//     await _prefs.remove('user_data');
//     await _prefs.remove('user_trip_data');
//   }

//   @override
//   Future<bool> hasUser() async {
//     final query = _box.query(LocalUsersModel_.pocketbaseId.notEquals(''))
//         .build();
//     final count = query.count();
//     final hasStoredUser = _prefs.containsKey('user_data');
//     debugPrint('📊 Current users in storage: $count');
//     debugPrint('📦 Has stored user data: $hasStoredUser');
//     return count > 0 && hasStoredUser;
//   }
  
// @override
// Future<TripModel> loadLocalUserTrip(String userId) async {
//   try {
//     debugPrint('🔍 Fetching local trip data for user: $userId');

//     final storedTripData = _prefs.getString('user_trip_data');
//     if (storedTripData != null) {
//       debugPrint('📦 Found cached trip data');
//       final tripData = jsonDecode(storedTripData);
//       return TripModel.fromJson(tripData);
//     }

//     final user = _box
//         .query(LocalUsersModel_.pocketbaseId.equals(userId))
//         .build()
//         .findFirst();

//     if (user == null) {
//       debugPrint('⚠️ User not found in local storage');
//       throw const CacheException(message: 'User not found in local storage');
//     }

//     final userTrip = user.trip.target;
//     if (userTrip == null) {
//       debugPrint('⚠️ No trip found for user in local storage');
//       throw const CacheException(message: 'No trip found for user in local storage');
//     }

//     debugPrint('✅ Successfully loaded local trip data');
//     debugPrint('   🎫 Trip Number: ${userTrip.tripNumberId}');
//     debugPrint('   👥 Customers: ${userTrip.customers.length}');
//     debugPrint('   🚛 Delivery Team: ${userTrip.deliveryTeam.target?.id}');

//     return userTrip;
//   } catch (e) {
//     debugPrint('❌ Local storage error: ${e.toString()}');
//     throw CacheException(message: e.toString());
//   }
// }

//   @override
//   Future<void> cacheUserData(LocalUsersModel user) async {
//     try {
//       debugPrint('💾 Caching user data locally');
      
//       // Clear existing user data
//       await clearUser();
      
//       // Save to ObjectBox
//       _box.put(user);
      
//       // Save to SharedPreferences for quick access
//       final userData = {
//         'id': user.id,
//         'collectionId': user.collectionId,
//         'collectionName': user.collectionName,
//         'email': user.email,
//         'name': user.name,
//         'tripNumberId': user.tripNumberId,
   
//         'deliveryTeam': user.deliveryTeam,
  
//       };
      
//       await _prefs.setString('user_data', jsonEncode(userData));
      
//       debugPrint('✅ User cached successfully');
//       debugPrint('   👤 User: ${user.name}');
//       debugPrint('   📧 Email: ${user.email}');
//       debugPrint('   🎫 Trip Number: ${user.tripNumberId}');
      
//     } catch (e) {
//       debugPrint('❌ Cache operation failed: ${e.toString()}');
//       throw CacheException(message: e.toString());
//     }
//   }

//   @override
//   Future<void> cacheUserTripData(TripModel trip) async {
//     try {
//       debugPrint('💾 Caching trip data locally');
      
//       // Save to SharedPreferences
//       final tripData = {
//         'id': trip.id,
//         'tripNumberId': trip.tripNumberId,
//         'isAccepted': trip.isAccepted,
//         'customers': trip.customers.map((c) => c.toJson()).toList(),
//         'deliveryTeam': trip.deliveryTeam.target?.toJson(), 
//         'personels': trip.personels.map((p) => p.toJson()).toList(),
//         'vehicle': trip.vehicle.map((c) => c.toJson()).toList(),
//         'checklist': trip.checklist.map((c) => c.toJson()).toList(),
//       };
      
//       await _prefs.setString('user_trip_data', jsonEncode(tripData));
      
//       debugPrint('✅ Trip cached successfully');
//       debugPrint('   🎫 Trip Number: ${trip.tripNumberId}');
//       debugPrint('   👥 Customers: ${trip.customers.length}');
//       debugPrint('   🚛 Vehicle: ${trip.vehicle.length}');
      
//     } catch (e) {
//       debugPrint('❌ Trip cache operation failed: ${e.toString()}');
//       throw CacheException(message: e.toString());
//     }
//   }

// }
