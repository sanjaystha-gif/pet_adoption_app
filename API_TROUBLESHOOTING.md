## 🔧 API Integration Troubleshooting Guide

If you're seeing **APIFailure** errors when trying to login or register, follow these steps to diagnose the problem:

### Step 1: Check Backend Server
```bash
# Make sure your backend is running on http://localhost:5000
# Test with curl:
curl -v http://localhost:5000/api/v1/auth/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

Expected Response:
- Status 400 (invalid credentials) with JSON error message
- Status 200/201 (success) with token and user data

### Step 2: Run API Debug Test
1. Modify `lib/main.dart` and temporarily replace the home screen with:
```dart
import 'package:pet_adoption_app/debug_api_test.dart';

void main() async {
  // ... initialization code ...
  runApp(
    MaterialApp(
      home: const ApiDebugTest(), // Temporary for testing
    ),
  );
}
```

2. Run the app: `flutter run`
3. Click "Test API Connectivity" button
4. Share the output - it will tell you exactly what's wrong

### Step 3: Check Console Output
When you try to login, watch the Flutter console for these messages:

**Good Sign (Connection Working):**
```
🔵 REQUEST: POST http://localhost:5000/api/v1/auth/login
   Headers: {Content-Type: application/json, ...}
   Data: {email: test@test.com, password: test123}
🟢 RESPONSE: 200 from /auth/login
   Data: {token: ..., user: {id: ..., email: ...}}
```

**Bad Sign (Connection Failed):**
```
🔵 REQUEST: POST http://localhost:5000/api/v1/auth/login
   ...
🔴 ERROR: Failed to connect to the server
   Type: SocketException
   Status Code: null
```

### Step 4: Common Issues & Solutions

#### Issue: "Failed to connect to the server"
- **Cause:** Backend not running or not on port 5000
- **Fix:** 
  - Start backend: `npm start` or `python app.py` (depends on your backend)
  - Verify URL in `lib/core/services/api/api_client.dart`: 
    ```dart
    static const String baseUrl = 'http://localhost:5000/api/v1';
    ```

#### Issue: "Connection timeout"
- **Cause:** Backend taking too long to respond
- **Fix:** 
  - Check if backend is hanging
  - Increase timeout in ApiClient baseOptions (currently 30 seconds)

#### Issue: "Status 500 - Internal Server Error"
- **Cause:** Bug in backend code
- **Fix:** Check backend logs and fix the issue there

#### Issue: "Status 404 - Not Found"
- **Cause:** Endpoint path doesn't exist
- **Fix:** 
  - Verify endpoints in backend: `/auth/login` and `/auth/register`
  - Check auth_notifier.dart for correct paths:
    ```dart
    await apiClient.post('/auth/login', data: {...})
    ```

#### Issue: "No token in response from server"
- **Cause:** Backend response format doesn't match expected format
- **Fix:** Your backend might be returning token in different field
  - Check if backend returns `token` or `accessToken`
  - Update field mapping in auth_notifier.dart login() method:
    ```dart
    final token = response.data['token'] ?? 
                  response.data['accessToken'] ?? 
                  response.data['access_token'];
    ```

#### Issue: "Invalid user data in response"
- **Cause:** Backend response structure differs
- **Fix:** Print the actual response and update parsing
  - Add print statement: `print('Raw response: ${response.data}');`
  - Check what fields your backend actually returns
  - Update the field mapping in auth_notifier.dart

### Step 5: Share Debug Output
Copy the console output from the Flutter console showing:
- 🔵 REQUEST (what's being sent)
- 🟢 RESPONSE (what's received) OR 🔴 ERROR (what went wrong)

This will help identify the exact issue.

### Backend Response Format Examples

**Expected Login Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "userId123",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "123-456-7890",
    "address": "123 Main St"
  }
}
```

**Alternative Response Format (also supported):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "_id": "userId123",
  "firstName": "John",
  "lastName": "Doe",
  "email": "user@example.com"
}
```

### API Endpoints Being Called

From your auth system:
- **POST** `/auth/login` - Login with email & password
- **POST** `/auth/register` - Register new user
- **POST** `/auth/logout` - Logout (optional, just clears local storage)

### Quick Verification

Run this one-liner to test connectivity:
```bash
curl -i -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

You should get:
- Status 400 or 401 (invalid credentials) - ✅ Backend works!
- Status 200 or 201 (success) - ✅ Backend works!
- Connection refused or timeout - ❌ Backend not running
