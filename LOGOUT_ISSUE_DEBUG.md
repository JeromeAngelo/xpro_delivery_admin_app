# 🔧 Automatic Logout Issue - Debug Guide

## 🔍 Problem
When navigating from Main Screen → All Users → Back to Main Screen, the user gets automatically logged out.

## 🕵️ Root Cause Analysis

The issue is likely caused by:

1. **Authentication State Conflicts**: The `GeneralUserBloc` handles both authentication (`UserAuthenticated`) AND user management (`AllUsersLoaded`) in the same bloc
2. **AuthInterceptor Behavior**: When `getAllUsers()` API call fails due to authentication, the AuthInterceptor might automatically log out the user
3. **Multiple API Calls**: The Users screen triggers multiple API calls which can cause authentication race conditions

## ✅ Applied Fixes

### 1. **Reduced API Call Triggers**
- ✅ Removed duplicate `GetAllUsersEvent()` calls from `BlocBuilder`
- ✅ Added defensive checks to only load users when necessary
- ✅ Added mounted checks to prevent calls after navigation

### 2. **Added Error Handling**
- ✅ Added `BlocListener` to detect authentication errors
- ✅ Show SnackBar with retry option instead of auto-logout
- ✅ Added debug logging to track state changes

### 3. **Enhanced Debug Logging**
- ✅ Added logging in MainScreen to track authentication state
- ✅ Added logging in Users screen to track API calls
- ✅ Added logging in BlocBuilder to track state transitions

## 🔍 Debug Instructions

### Monitor Console Output:
Look for these debug messages:

```
🏠 MainScreen initState - Current auth state: UserAuthenticated
📱 AllUsersView initState - Current state: GeneralUserInitial  
🔄 Triggering GetAllUsersEvent from initState
📱 BlocBuilder: GeneralUserInitial state - showing loading
✅ BLOC: Successfully retrieved X users
🏠 MainScreen - Auth state: UserAuthenticated
```

### If Logout Still Occurs:
Look for these error patterns:

```
❌ BLOC: Failed to get all users: Authentication error
⚠️ User management error: User not authenticated
🔒 Authentication error detected, but not auto-logging out
⚠️ User is not authenticated in MainScreen
```

## 🛠️ Additional Fixes to Try

### 1. **Separate Authentication and User Management**
If the issue persists, consider creating separate blocs:
- `AuthBloc` - Handle login/logout only
- `UserManagementBloc` - Handle user CRUD operations

### 2. **Check AuthInterceptor**
The AuthInterceptor might be too aggressive. Consider modifying it to:
- Only logout on 401 errors for authentication endpoints
- Not logout on user management API failures

### 3. **Add State Persistence**
Consider persisting authentication state locally and restoring it:
```dart
// Save auth state
SharedPreferences.setString('auth_state', 'authenticated');

// Restore on app start
final authState = SharedPreferences.getString('auth_state');
```

## 🧪 Test Scenarios

1. **Basic Navigation Test**:
   - Login → Main Screen → Users → Back to Main
   - ✅ Should remain logged in

2. **Multiple Navigation Test**:
   - Repeat navigation 5 times
   - ✅ Should remain logged in

3. **Network Error Test**:
   - Disconnect internet → Navigate to Users → Reconnect
   - ✅ Should show error but remain logged in

## 📊 Current Status

- ✅ API call optimization complete
- ✅ Error handling added
- ✅ Debug logging implemented
- ⏳ Monitor for automatic logout
- ⏳ If issue persists, implement additional fixes

## 🚨 If Issue Persists

If the automatic logout still occurs after these changes:

1. **Check console logs** for the debug messages above
2. **Report the exact sequence** of debug messages when logout occurs
3. **Consider implementing separate blocs** for auth vs user management
4. **Review AuthInterceptor logic** to be less aggressive

The debug logs will help identify exactly where the authentication state is being lost.
