# KrishiBondhu Flutter App

A modern Flutter application designed for the farming community, providing digital solutions for modern agriculture.

## Features

- **Splash Screen**: Beautiful animated splash screen with app branding
- **Onboarding**: Three-slide introduction to app features
- **Authentication**: Complete login and signup system with validation
- **Modern UI**: Material 3 design with green theme
- **Responsive**: Works on different screen sizes
- **Form Validation**: Email, password, and field validation

## Screenshots

### Splash Screen
- App logo with fade-in animation
- Loading indicator
- Auto-navigation after 3 seconds

### Onboarding Screens
- Welcome to KrishiBondhu
- Smart Farming Solutions  
- Connect with Community

### Authentication
- Login with email/password
- Signup with full name, email, phone (optional), password
- Form validation and error handling
- Forgot password functionality

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/                     # All screen widgets
│   ├── splash_screen.dart       # Splash screen
│   ├── onboarding/              # Onboarding screens
│   │   ├── onboarding_screen.dart
│   │   └── onboarding_content.dart
│   └── auth/                    # Authentication screens
│       ├── login_screen.dart
│       └── signup_screen.dart
├── widgets/                     # Reusable widgets
│   ├── custom_button.dart       # Custom button component
│   └── custom_text_field.dart   # Custom text field component
├── services/                    # Business logic
│   └── auth_service.dart        # Authentication service
├── models/                      # Data models
│   └── user_model.dart          # User data model
└── utils/                       # Utilities and constants
    ├── constants.dart           # App constants and colors
    └── validators.dart          # Form validation logic
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  email_validator: ^2.1.17      # Email validation
  shared_preferences: ^2.2.2    # Local storage

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## Installation & Setup

### Prerequisites
- Flutter SDK (3.1.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS emulator or physical device

### Steps to Run

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd krishibondhu
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Create assets folder**
```bash
mkdir -p assets/images
```

4. **Add placeholder images** (optional)
   - Add logo.png, onboarding1.png, onboarding2.png, onboarding3.png to assets/images/
   - Or use the built-in icons (current implementation)

5. **Run the app**
```bash
flutter run
```

## Navigation Flow

```
Splash Screen (3s delay)
    ↓
Onboarding Screen (3 slides)
    ↓ (Skip/Complete)
Login Screen ←→ Signup Screen
    ↓ (Successful login)
Main App (to be implemented)
```

## Key Features Implementation

### Form Validation
- **Email**: Valid email format required
- **Password**: Minimum 8 characters
- **Required Fields**: Name, email validation
- **Phone**: Optional but validated if provided

### Authentication Service
- Mock authentication with local storage
- User session management
- Login/logout functionality
- User data persistence

### UI/UX Features
- **Material 3 Design**: Modern Google design system
- **Green Theme**: Agriculture-focused color scheme
- **Responsive Layout**: Adapts to different screen sizes
- **Loading States**: Visual feedback during operations
- **Error Handling**: User-friendly error messages

## Customization

### Colors
Edit `lib/utils/constants.dart` to change the color scheme:

```dart
class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  // Add your custom colors
}
```

### Text Styles
Modify text styles in `AppTextStyles` class in constants.dart

### Add New Screens
1. Create new screen in appropriate folder under `lib/screens/`
2. Add route in `main.dart`
3. Implement navigation logic

## Testing

### Demo Credentials
- **Email**: Any valid email format (e.g., test@example.com)
- **Password**: Any password with 8+ characters

### Testing the App
1. Open app → See splash screen
2. View onboarding slides
3. Skip or complete onboarding
4. Try login with invalid credentials → See error
5. Try login with valid format → Success message
6. Navigate to signup and test validation
7. Complete signup → Navigate to login

## Next Steps

To make this a production app, consider adding:

- **Backend Integration**: Replace mock auth with real API
- **Main Dashboard**: Home screen after login
- **User Profile**: Edit profile functionality  
- **Forgot Password**: Actual reset functionality
- **Push Notifications**: Firebase integration
- **Offline Support**: Local database
- **Testing**: Unit and widget tests
- **CI/CD**: Automated builds and deployment

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.