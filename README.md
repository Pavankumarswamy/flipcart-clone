# Flipkart Clone

A Flutter application replicating the core functionality and user interface of Flipkart, an e-commerce platform. This project includes user authentication, product browsing, search with filtering, cart management, order tracking, real-time messaging, and product addition, leveraging Firebase for backend services.

## Getting Started

This project serves as a Flutter-based e-commerce application with a Flipkart-inspired design. To set up and run the project, follow these steps:

1. **Prerequisites**:
   - Ensure Flutter and Dart are installed. Refer to the [Flutter installation guide](https://docs.flutter.dev/get-started/install) for setup instructions.
   - Install an IDE such as Visual Studio Code or Android Studio.
   - Set up an Android/iOS emulator or connect a physical device for testing.

2. **Firebase Configuration**:
   - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Enable **Email/Password Authentication** under the Authentication section.
   - Enable **Realtime Database** and set the following rules:
     ```json
     {
       "rules": {
         ".read": "auth != null",
         ".write": "auth != null"
       }
     }
     ```
   - Download the `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) file and place it in the appropriate directory (`android/app` for Android, or follow iOS setup instructions).
   - Initialize Firebase in the `main.dart` file.

3. **Project Setup**:
   - Clone or download the project repository to your local machine.
   - Ensure the project structure includes the following files in `lib/screens/`:
     - `main.dart`
     - `splash_screen.dart`
     - `wrapper.dart`
     - `login_screen.dart`
     - `signup_screen.dart`
     - `home_screen.dart`
     - `search_screen.dart`
     - `cart_screen.dart`
     - `profile_screen.dart`
     - `inbox_page.dart`
     - `chat_screen.dart`
     - `add_product_screen.dart`
   - Update the `pubspec.yaml` file to include the required dependencies:
     ```yaml
     dependencies:
       flutter:
         sdk: flutter
       firebase_core: ^3.6.0
       firebase_auth: ^5.3.1
       firebase_database: ^11.1.4
       cached_network_image: ^3.4.1
     ```

4. **Running the Application**:
   - Open the project in your IDE.
   - Run `flutter pub get` to install dependencies.
   - Use `flutter run` to launch the app on an emulator or device.
   - Test the following features:
     - User authentication (login/signup).
     - Product browsing and addition via the floating action button on the home screen.
     - Search with category filtering.
     - Cart management and order placement.
     - Real-time messaging via the inbox page.
     - Profile view with order history.

5. **Resources for Flutter Development**:
   - [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab) for a beginner-friendly tutorial.
   - [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook) for practical examples.
   - [Flutter Documentation](https://docs.flutter.dev/) for comprehensive tutorials, samples, and API references.

## Project Features
- **Splash Screen**: Displays the Flipkart logo for 3 seconds before routing to the login or home screen.
- **Authentication**: Supports email/password login and signup with user details stored in Firebase Realtime Database.
- **Home Screen**: Features a Flipkart-style UI with a search bar, category chips, a 2-column product grid, and a floating action button to add products.
- **Search Screen**: Allows filtering products by name and category, with a message button to contact sellers.
- **Cart Screen**: Manages cart items with quantity controls and order placement.
- **Profile Screen**: Displays user details and past orders, with a logout option.
- **Inbox Page**: Lists users who have messaged the current user, showing the latest message and timestamp.
- **Chat Screen**: Enables real-time messaging with a Flipkart-inspired design.
- **Product Addition**: Allows users to add products (name, price, image URL, description, category) via a dedicated screen.

## Troubleshooting
- **Firebase Issues**: Ensure Firebase is correctly configured and the Realtime Database rules allow authenticated access.
- **Dependency Errors**: Run `flutter pub get` to resolve missing dependencies.
- **UI Rendering**: Test on multiple screen sizes to ensure responsiveness.
- If issues persist, consult the [Flutter Documentation](https://docs.flutter.dev/) or share error logs for assistance.

This project provides a foundation for a Flipkart-like e-commerce application. For further enhancements, consider adding features like product reviews, payment integration, or product editing capabilities.
