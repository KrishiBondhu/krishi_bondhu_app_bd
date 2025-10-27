# KrishiBondhu Project - Screen Integration Guide

## 🔗 **Integration Status for Each Screen**

---

## 📱 **1. Splash Screen (`splash_screen.dart`)**

### **Current Integrations** ✅
```dart
// Services Connected:
- AuthService: Checks if user is logged in
- SharedPreferences: Reads onboarding completion status

// Current Implementation:
final authService = AuthService();
final hasCompletedOnboarding = await authService.hasCompletedOnboarding();
final isLoggedIn = await authService.isLoggedIn();
```

### **Backend Integration Needed** 🔄
```dart
// Token Validation API
Future<bool> validateStoredToken() async {
  final token = await secureStorage.read(key: 'auth_token');
  if (token != null) {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/validate-token'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
  return false;
}

// App Version Check API
Future<Map<String, dynamic>> checkAppVersion() async {
  final response = await http.get(
    Uri.parse('$baseUrl/app/version-check'),
    headers: {'Content-Type': 'application/json'},
  );
  return json.decode(response.body);
}
```

### **Integration Flow**
```
App Launch → Check Token → Validate with Server → Route Decision
           ↓
    Check App Version → Force Update if Required
           ↓
    Load Critical Data → Navigate to Appropriate Screen
```

---

## 📚 **2. Onboarding Screen (`onboarding_screen.dart`)**

### **Current Integrations** ✅
```dart
// Local Storage:
- SharedPreferences: Marks onboarding as completed

// Current Implementation:
Future<void> _completeOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_completed', true);
  Navigator.pushReplacementNamed(context, '/login');
}
```

### **Backend Integration Needed** 🔄
```dart
// User Onboarding Analytics API
Future<void> trackOnboardingProgress(int slideIndex) async {
  await http.post(
    Uri.parse('$baseUrl/analytics/onboarding'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'slide_index': slideIndex,
      'timestamp': DateTime.now().toIso8601String(),
      'device_info': await _getDeviceInfo(),
    }),
  );
}

// Dynamic Onboarding Content API
Future<List<OnboardingContent>> getOnboardingContent() async {
  final response = await http.get(
    Uri.parse('$baseUrl/content/onboarding'),
    headers: {'Content-Type': 'application/json'},
  );
  final data = json.decode(response.body);
  return (data['slides'] as List)
      .map((slide) => OnboardingContent.fromJson(slide))
      .toList();
}
```

### **Integration Flow**
```
Load Dynamic Content → Display Slides → Track Progress → Mark Complete
```

---

## 🔐 **3. Login Screen (`login_screen.dart`)**

### **Current Integrations** ✅
```dart
// Services Connected:
- AuthService: Handles login logic (currently mock)
- Validators: Email and password validation
- SharedPreferences: Stores login status

// Current Implementation:
final success = await _authService.login(
  _emailController.text.trim(),
  _passwordController.text,
);
```

### **Backend Integration Needed** 🔄
```dart
// Login API Implementation
class AuthService {
  static const String baseUrl = 'https://api.krishibondhu.com';
  
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'device_id': await _getDeviceId(),
          'fcm_token': await _getFCMToken(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Store tokens securely
        await _secureStorage.write(key: 'auth_token', value: data['access_token']);
        await _secureStorage.write(key: 'refresh_token', value: data['refresh_token']);
        
        // Store user data
        final user = User.fromJson(data['user']);
        await _storeUserData(user);
        
        return LoginResponse.success(user, data['access_token']);
      } else {
        final error = json.decode(response.body);
        return LoginResponse.error(error['message']);
      }
    } catch (e) {
      return LoginResponse.error('Network error: ${e.toString()}');
    }
  }

  // Social Login Integration
  Future<LoginResponse> loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_token': googleAuth.idToken,
          'access_token': googleAuth.accessToken,
        }),
      );
      
      // Handle response similar to regular login
    }
  }
}

// Login Response Model
class LoginResponse {
  final bool success;
  final User? user;
  final String? token;
  final String? error;

  LoginResponse({required this.success, this.user, this.token, this.error});

  factory LoginResponse.success(User user, String token) =>
      LoginResponse(success: true, user: user, token: token);

  factory LoginResponse.error(String error) =>
      LoginResponse(success: false, error: error);
}
```

### **Integration Flow**
```
User Input → Validate → API Call → Store Tokens → Store User Data → Navigate to Dashboard
           ↓
    Handle Errors → Show User-Friendly Messages
           ↓
    Track Login Attempts → Security Monitoring
```

---

## 📝 **4. Signup Screen (`signup_screen.dart`)**

### **Current Integrations** ✅
```dart
// Services Connected:
- AuthService: Handles signup logic (currently mock)  
- Validators: Form field validation
- SharedPreferences: Stores user data

// Current Implementation:
final success = await _authService.signup(
  _fullNameController.text.trim(),
  _emailController.text.trim(),
  _passwordController.text,
  phoneNumber: _phoneController.text.trim(),
);
```

### **Backend Integration Needed** 🔄
```dart
// Registration API Implementation
Future<SignupResponse> signup({
  required String fullName,
  required String email,
  required String password,
  String? phoneNumber,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'device_id': await _getDeviceId(),
        'registration_source': 'mobile_app',
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      
      // Send verification email
      await _sendVerificationEmail(email);
      
      return SignupResponse.success(data['message']);
    } else {
      final error = json.decode(response.body);
      return SignupResponse.error(error['message']);
    }
  } catch (e) {
    return SignupResponse.error('Registration failed: ${e.toString()}');
  }
}

// Email Verification API
Future<void> sendVerificationEmail(String email) async {
  await http.post(
    Uri.parse('$baseUrl/auth/send-verification'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': email}),
  );
}

// Phone Verification API (if phone provided)
Future<void> sendPhoneVerification(String phoneNumber) async {
  await http.post(
    Uri.parse('$baseUrl/auth/send-phone-otp'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'phone_number': phoneNumber}),
  );
}
```

### **Integration Flow**
```
User Input → Validate → Check Email Exists → API Call → Send Verification Email
           ↓
    Show Success Message → Navigate to Verification Screen → Login Screen
```

---

## 📊 **5. Dashboard Screen (`dashboard_screen.dart`)**

### **Current Integrations** ✅
```dart
// Services Connected:
- AuthService: Gets current user data
- WeatherService: Fetches weather information (mock)
- SharedPreferences: User session management

// Current Implementation:
final user = await _authService.getCurrentUser();
_currentWeather = await _weatherService.getCurrentWeather();
```

### **Backend Integration Needed** 🔄
```dart
// Dashboard Data API
class DashboardService {
  // User Dashboard Data
  Future<DashboardData> getDashboardData() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return DashboardData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }

  // Farm Statistics API
  Future<FarmStats> getFarmStatistics() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/farm-stats'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    return FarmStats.fromJson(json.decode(response.body));
  }

  // Recent Activities API
  Future<List<FarmActivity>> getRecentActivities() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/recent-activities'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    final data = json.decode(response.body);
    return (data['activities'] as List)
        .map((activity) => FarmActivity.fromJson(activity))
        .toList();
  }
}

// Weather Service Integration
class WeatherService {
  // Real Weather API (OpenWeatherMap/WeatherAPI)
  Future<Weather> getCurrentWeather() async {
    final location = await _getCurrentLocation();
    final response = await http.get(
      Uri.parse('$weatherApiUrl/current?lat=${location.latitude}&lon=${location.longitude}&key=$apiKey'),
    );
    
    return Weather.fromJson(json.decode(response.body));
  }

  // Location-based Weather
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }
}

// Push Notifications Integration
class NotificationService {
  Future<void> initializePushNotifications() async {
    final messaging = FirebaseMessaging.instance;
    
    // Request permission
    await messaging.requestPermission();
    
    // Get FCM token
    final token = await messaging.getToken();
    await _sendTokenToServer(token);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _sendTokenToServer(String? token) async {
    if (token != null) {
      final authToken = await _getAuthToken();
      await http.post(
        Uri.parse('$baseUrl/users/fcm-token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'fcm_token': token}),
      );
    }
  }
}
```

### **Integration Flow**
```
Dashboard Load → Get User Data → Load Weather → Load Farm Stats → Show Recent Activities
              ↓
        Initialize Push Notifications → Update FCM Token
              ↓
        Set up Real-time Updates → WebSocket Connection
```

---

## 🌤️ **6. Weather Card Widget (`weather_card.dart`)**

### **Current Integrations** ✅
```dart
// Data Sources:
- Weather model with mock data
- Icon mapping for weather conditions

// Current Implementation:
WeatherCard(weather: _currentWeather)
```

### **Backend Integration Needed** 🔄
```dart
// Enhanced Weather Service
class WeatherService {
  // Detailed Weather Information
  Future<DetailedWeather> getDetailedWeather() async {
    final location = await _getCurrentLocation();
    
    // Current weather
    final currentResponse = await http.get(
      Uri.parse('$weatherApiUrl/current?lat=${location.latitude}&lon=${location.longitude}&key=$apiKey'),
    );
    
    // Hourly forecast
    final hourlyResponse = await http.get(
      Uri.parse('$weatherApiUrl/forecast/hourly?lat=${location.latitude}&lon=${location.longitude}&key=$apiKey'),
    );
    
    // Agricultural alerts
    final alertsResponse = await http.get(
      Uri.parse('$weatherApiUrl/alerts?lat=${location.latitude}&lon=${location.longitude}&key=$apiKey'),
    );
    
    return DetailedWeather(
      current: Weather.fromJson(json.decode(currentResponse.body)),
      hourlyForecast: (json.decode(hourlyResponse.body)['forecast'] as List)
          .map((hour) => HourlyWeather.fromJson(hour))
          .toList(),
      alerts: (json.decode(alertsResponse.body)['alerts'] as List)
          .map((alert) => WeatherAlert.fromJson(alert))
          .toList(),
    );
  }

  // Farming-specific Weather Data
  Future<FarmWeatherData> getFarmWeatherData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather/farm-specific'),
      headers: {'Authorization': 'Bearer ${await _getAuthToken()}'},
    );
    
    return FarmWeatherData.fromJson(json.decode(response.body));
  }
}

// Enhanced Weather Models
class DetailedWeather {
  final Weather current;
  final List<HourlyWeather> hourlyForecast;
  final List<WeatherAlert> alerts;
  final FarmingRecommendations recommendations;
}

class FarmingRecommendations {
  final bool goodForPlanting;
  final bool irrigationNeeded;
  final String pestRiskLevel;
  final List<String> suggestedActivities;
}
```

### **Integration Flow**
```
Location Permission → Get GPS Coordinates → Fetch Weather Data → Process Farm Recommendations
                   ↓
            Display Current Weather → Show Alerts → Suggest Farm Activities
```

---

## ⚡ **7. Quick Actions Grid (`quick_actions_grid.dart`)**

### **Current Integrations** ✅
```dart
// Static Data:
- Hardcoded action items
- Navigation placeholders

// Current Implementation:
// Shows "Coming Soon" for all actions
```

### **Backend Integration Needed** 🔄
```dart
// Action-specific Service Integrations
class QuickActionsService {
  // Crop Management Integration
  Future<void> navigateToCropManagement(BuildContext context) async {
    final crops = await _getCropData();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropManagementScreen(crops: crops),
      ),
    );
  }

  // Market Prices Integration
  Future<void> navigateToMarketPrices(BuildContext context) async {
    final prices = await _getMarketPrices();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketPricesScreen(prices: prices),
      ),
    );
  }

  // Expert Advice Integration
  Future<void> navigateToExpertAdvice(BuildContext context) async {
    final experts = await _getAvailableExperts();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpertAdviceScreen(experts: experts),
      ),
    );
  }

  // Community Integration
  Future<void> navigateToCommunity(BuildContext context) async {
    final posts = await _getCommunityPosts();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityScreen(posts: posts),
      ),
    );
  }
}

// Data Fetching Methods
Future<List<Crop>> _getCropData() async {
  final response = await http.get(
    Uri.parse('$baseUrl/crops/user-crops'),
    headers: {'Authorization': 'Bearer ${await _getAuthToken()}'},
  );
  
  final data = json.decode(response.body);
  return (data['crops'] as List)
      .map((crop) => Crop.fromJson(crop))
      .toList();
}

Future<List<MarketPrice>> _getMarketPrices() async {
  final response = await http.get(
    Uri.parse('$baseUrl/market/current-prices'),
    headers: {'Authorization': 'Bearer ${await _getAuthToken()}'},
  );
  
  final data = json.decode(response.body);
  return (data['prices'] as List)
      .map((price) => MarketPrice.fromJson(price))
      .toList();
}
```

### **Integration Flow**
```
Action Tap → Load Relevant Data → Navigate to Feature Screen → Update User Activity
```

---

## 🔧 **Required Dependencies for Full Integration**

### **Add to `pubspec.yaml`:**
```yaml
dependencies:
  # HTTP and API calls
  http: ^1.1.0
  dio: ^5.3.2  # Alternative HTTP client
  
  # Secure storage
  flutter_secure_storage: ^9.0.0
  
  # Location services
  geolocator: ^10.1.0
  permission_handler: ^11.0.2
  
  # Push notifications
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  
  # Social authentication
  google_sign_in: ^6.1.5
  
  # Local database
  sqflite: ^2.3.0
  
  # State management (optional)
  provider: ^6.1.1
  # or
  bloc: ^8.1.2
```

---

## 🎯 **Integration Priority Order**

### **Phase 1: Core Authentication** (1-2 weeks)
1. **Login Screen** - Real login API
2. **Signup Screen** - Registration API  
3. **Splash Screen** - Token validation

### **Phase 2: Dashboard Data** (1-2 weeks)
1. **Dashboard Screen** - User data API
2. **Weather Card** - Real weather API
3. **Push Notifications** - Firebase setup

### **Phase 3: Feature Integration** (2-3 weeks)
1. **Quick Actions** - Individual feature APIs
2. **Advanced Features** - Crop management, market prices
3. **Community Features** - Social integration

### **Phase 4: Enhancement** (1-2 weeks)
1. **Offline Support** - Local database
2. **Performance** - Caching and optimization
3. **Analytics** - User behavior tracking

---

## 🔐 **Security Considerations**

### **Token Management:**
```dart
// Use flutter_secure_storage for sensitive data
final storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
```

### **API Security:**
```dart
// Add request interceptors
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $token';
    options.headers['X-API-Key'] = apiKey;
    super.onRequest(options, handler);
  }
}
```

### **Error Handling:**
```dart
// Centralized error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
}
```

This guide provides a complete roadmap for integrating each screen with backend services and external APIs. Each screen has specific integration requirements and the implementation can be done in phases based on priority.