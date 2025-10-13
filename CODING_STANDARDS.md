# KrishiBondhu Flutter Project - Coding Standards

## 📋 Table of Contents
1. [Project Structure](#project-structure)
2. [Naming Conventions](#naming-conventions)
3. [Code Organization](#code-organization)
4. [Widget Development](#widget-development)
5. [State Management](#state-management)
6. [Asset Management](#asset-management)
7. [Error Handling](#error-handling)
8. [Performance Guidelines](#performance-guidelines)
9. [Documentation Standards](#documentation-standards)
10. [Testing Guidelines](#testing-guidelines)

---

## 🏗️ Project Structure

### Directory Organization
```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── user_model.dart
│   ├── weather_model.dart
│   └── activity_model.dart
├── screens/                     # UI screens
│   ├── auth/                    # Authentication screens
│   ├── dashboard/               # Dashboard and related screens
│   ├── onboarding/             # Onboarding flow
│   └── splash_screen.dart
├── services/                    # Business logic & API calls
│   ├── auth_service.dart
│   └── weather_service.dart
├── utils/                       # Utilities and helpers
│   ├── constants.dart           # App constants
│   └── validators.dart          # Input validation
└── widgets/                     # Reusable widgets
    ├── custom_button.dart
    └── custom_text_field.dart
```

### Subdirectory Rules
- Each screen should have its own directory if it has multiple related files
- Create `widgets/` subdirectory within screen folders for screen-specific widgets
- Group related functionality in dedicated directories

---

## 📝 Naming Conventions

### Files and Directories
- **Files**: Use `snake_case` for all file names
  ```dart
  ✅ login_screen.dart
  ✅ weather_service.dart
  ✅ custom_text_field.dart
  
  ❌ LoginScreen.dart
  ❌ weatherService.dart
  ❌ customTextField.dart
  ```

- **Directories**: Use `snake_case` for directory names
  ```
  ✅ dashboard/
  ✅ quick_actions/
  ✅ auth_service/
  
  ❌ Dashboard/
  ❌ quickActions/
  ```

### Classes and Widgets
- **Classes**: Use `PascalCase`
  ```dart
  ✅ class LoginScreen extends StatefulWidget
  ✅ class WeatherService
  ✅ class UserModel
  
  ❌ class loginScreen
  ❌ class weather_service
  ```

### Variables and Functions
- **Variables**: Use `camelCase`
  ```dart
  ✅ String userName = 'John';
  ✅ bool isLoading = false;
  ✅ List<FarmActivity> recentActivities = [];
  
  ❌ String user_name;
  ❌ bool IsLoading;
  ```

- **Functions**: Use `camelCase`
  ```dart
  ✅ void navigateToLogin()
  ✅ Future<bool> handleLogin()
  ✅ Widget buildWelcomeHeader()
  
  ❌ void navigate_to_login()
  ❌ Widget BuildWelcomeHeader()
  ```

### Constants
- **Constants**: Use `camelCase` for constant variables, `SCREAMING_SNAKE_CASE` for compile-time constants
  ```dart
  ✅ static const String appName = 'KrishiBondhu';
  ✅ static const Color primaryGreen = Color(0xFF4CAF50);
  ✅ const int MAX_RETRY_ATTEMPTS = 3;
  
  ❌ static const String APP_NAME = 'KrishiBondhu';
  ❌ static const Color PRIMARY_GREEN = Color(0xFF4CAF50);
  ```

---

## 🎯 Code Organization

### Import Order
```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:convert';

// 2. Flutter framework libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';

// 4. Local imports (relative paths)
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
```

### Class Structure Order
```dart
class ExampleWidget extends StatefulWidget {
  // 1. Constructor and key
  const ExampleWidget({super.key, required this.title});
  
  // 2. Final fields
  final String title;
  
  // 3. Override methods
  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  // 1. Private fields
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // 2. Lifecycle methods
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
  
  // 3. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Widget tree
    );
  }
  
  // 4. Private helper methods
  void _initialize() {
    // Implementation
  }
  
  Future<void> _handleSubmit() async {
    // Implementation
  }
  
  Widget _buildFormField() {
    // Implementation
  }
}
```

---

## 🔧 Widget Development

### Widget Creation Guidelines
```dart
// ✅ Good: Stateless when possible
class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.weather,
  });
  
  final Weather weather;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // Implementation
    );
  }
}

// ✅ Good: Use const constructors
const SizedBox(height: 16)
const Icon(Icons.home)
const Text('Welcome')

// ❌ Bad: Unnecessary StatefulWidget
class StaticTextWidget extends StatefulWidget {
  // This should be StatelessWidget
}
```

### Widget Composition
```dart
// ✅ Good: Break down complex widgets
class DashboardScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildWelcomeHeader(),    // Separate method
          _buildWeatherCard(),      // Separate method
          _buildQuickActions(),     // Separate method
        ],
      ),
    );
  }
  
  Widget _buildWelcomeHeader() {
    return Container(/* implementation */);
  }
}

// ✅ Even better: Extract to separate widgets
class DashboardScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WelcomeHeader(userName: _userName),
          WeatherCard(weather: _weather),
          QuickActionsGrid(),
        ],
      ),
    );
  }
}
```

### Layout Best Practices
```dart
// ✅ Good: Use proper constraints
Expanded(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ItemCard(item: items[index]),
  ),
)

// ✅ Good: Prevent overflow
Flexible(
  child: Text(
    longText,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
)

// ✅ Good: Consistent spacing
const SizedBox(height: 16)
const EdgeInsets.all(20)
const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
```

---

## 🔄 State Management

### Local State Management
```dart
// Use StatefulWidget for simple local state
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Login logic
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
```

### Service Layer Pattern
```dart
// ✅ Good: Service classes for business logic
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  Future<bool> login(String email, String password) async {
    try {
      // Implementation
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

---

## 📁 Asset Management

### Asset Organization
```
assets/
├── images/
│   ├── logos/
│   ├── icons/
│   └── illustrations/
├── fonts/
└── data/
    └── mock_data.json
```

### Asset Usage
```dart
// ✅ Good: Use constants for asset paths
class AppAssets {
  static const String logoPath = 'assets/images/logos/app_logo.png';
  static const String defaultAvatar = 'assets/images/icons/default_avatar.png';
}

// Usage
Image.asset(AppAssets.logoPath)
```

### pubspec.yaml Configuration
```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/logos/
    - assets/images/icons/
  
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

---

## ⚠️ Error Handling

### Exception Handling
```dart
// ✅ Good: Proper error handling
Future<Weather> getCurrentWeather() async {
  try {
    final response = await http.get(Uri.parse(weatherUrl));
    
    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw WeatherException('Failed to fetch weather data');
    }
  } on SocketException {
    throw WeatherException('No internet connection');
  } on FormatException {
    throw WeatherException('Invalid response format');
  } catch (e) {
    throw WeatherException('Unexpected error: ${e.toString()}');
  }
}

// Usage in UI
void _loadWeather() async {
  try {
    final weather = await _weatherService.getCurrentWeather();
    setState(() {
      _currentWeather = weather;
    });
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
```

### Custom Exceptions
```dart
class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);
  
  @override
  String toString() => 'WeatherException: $message';
}
```

---

## ⚡ Performance Guidelines

### Widget Optimization
```dart
// ✅ Good: Use const widgets
const Icon(Icons.home)
const SizedBox(height: 16)
const Text('Static text')

// ✅ Good: Extract expensive operations
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const _ExpensiveWidgetContent();
  }
}

class _ExpensiveWidgetContent extends StatelessWidget {
  const _ExpensiveWidgetContent();
  
  @override
  Widget build(BuildContext context) {
    // Expensive widget tree here
    return Container(/* complex tree */);
  }
}
```

### List Performance
```dart
// ✅ Good: Use ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemCard(
      key: ValueKey(items[index].id),
      item: items[index],
    );
  },
)

// ✅ Good: Add keys for list items
ListView(
  children: items.map((item) => 
    ItemCard(
      key: ValueKey(item.id),
      item: item,
    )
  ).toList(),
)
```

### Memory Management
```dart
// ✅ Good: Dispose controllers and subscriptions
class _ScreenState extends State<Screen> {
  late TextEditingController _controller;
  late StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _subscription = stream.listen(_handleData);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }
}
```

---

## 📚 Documentation Standards

### Class Documentation
```dart
/// Authentication service to handle login and signup operations.
/// 
/// This service provides methods for user authentication including:
/// - User login with email/password
/// - User registration
/// - Session management
/// - Password reset functionality
/// 
/// Example usage:
/// ```dart
/// final authService = AuthService();
/// final success = await authService.login('user@example.com', 'password');
/// ```
class AuthService {
  /// Login user with email and password.
  /// 
  /// Returns `true` if login successful, `false` otherwise.
  /// Throws [AuthException] if authentication fails.
  Future<bool> login(String email, String password) async {
    // Implementation
  }
}
```

### Method Documentation
```dart
/// Build welcome header widget with user information.
/// 
/// Displays:
/// - User profile picture
/// - Welcome message with user name
/// - Current date and time
/// 
/// The header adapts to different screen sizes and uses
/// gradient background for visual appeal.
Widget _buildWelcomeHeader() {
  return Container(
    // Implementation
  );
}
```

### TODO Comments
```dart
// TODO: Implement push notifications
// FIXME: Handle network timeout properly
// HACK: Temporary workaround for API issue
// NOTE: This logic will change in v2.0
```

---

## 🧪 Testing Guidelines

### Test File Organization
```
test/
├── unit/
│   ├── models/
│   ├── services/
│   └── utils/
├── widget/
│   ├── screens/
│   └── widgets/
└── integration/
    └── app_test.dart
```

### Unit Tests
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:krishibondhu/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    
    setUp(() {
      authService = AuthService();
    });
    
    test('should return true when login is successful', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      
      // Act
      final result = await authService.login(email, password);
      
      // Assert
      expect(result, isTrue);
    });
    
    test('should return false when login fails', () async {
      // Arrange
      const email = '';
      const password = '';
      
      // Act
      final result = await authService.login(email, password);
      
      // Assert
      expect(result, isFalse);
    });
  });
}
```

### Widget Tests
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krishibondhu/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton displays text and handles tap', (tester) async {
    // Arrange
    bool tapped = false;
    const buttonText = 'Test Button';
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: CustomButton(
          text: buttonText,
          onPressed: () => tapped = true,
        ),
      ),
    );
    
    // Assert
    expect(find.text(buttonText), findsOneWidget);
    
    await tester.tap(find.byType(CustomButton));
    expect(tapped, isTrue);
  });
}
```

---

## 🔍 Code Review Checklist

### Before Submitting Code
- [ ] Code follows naming conventions
- [ ] All imports are organized properly
- [ ] No unused imports or variables
- [ ] All widgets use const constructors where possible
- [ ] Error handling is implemented
- [ ] Controllers and subscriptions are disposed
- [ ] Code is properly documented
- [ ] Tests are written and passing
- [ ] No debug prints in production code
- [ ] Performance considerations addressed

### Code Quality Metrics
- **Complexity**: Keep methods under 50 lines
- **Nesting**: Maximum 4 levels of nesting
- **Parameters**: Maximum 5 parameters per method
- **File Length**: Keep files under 500 lines
- **Class Responsibility**: One responsibility per class

---

## 🛠️ Development Tools

### Recommended VS Code Extensions
- Flutter
- Dart
- Flutter Widget Snippets
- GitLens
- Error Lens
- Bracket Pair Colorizer

### Useful Commands
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Generate code coverage
flutter test --coverage

# Clean build
flutter clean && flutter pub get
```

---

## 📋 Final Notes

### Key Principles
1. **Consistency**: Follow the same patterns throughout the project
2. **Readability**: Write code that others can easily understand
3. **Maintainability**: Structure code for easy updates and modifications
4. **Performance**: Consider performance implications of code decisions
5. **Testing**: Write tests for critical functionality

### Resources
- [Flutter Style Guide](https://docs.flutter.dev/development/tools/formatting)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Material Design Guidelines](https://material.io/design)

---

*This document should be reviewed and updated regularly as the project evolves.*