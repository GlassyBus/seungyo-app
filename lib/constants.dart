import 'package:intl/intl.dart';

class AppConstants {
  // Shared Preferences Keys
  static const String isLoggedInKey = 'isLoggedIn';
  static const String hasPreviousLoginKey = 'hasPreviousLogin';

  // 예시 텍스트 리소스 (Intl을 사용하여 다국어 지원 가능)
  static String get welcomeMessage => Intl.message(
    'Welcome to Seungyo App!',
    name: 'welcomeMessage',
    desc: 'Welcome message displayed on the home screen',
  );

  static String get loginButtonText => Intl.message(
    'Login',
    name: 'loginButtonText',
    desc: 'Text for the login button',
  );

  static String get signupButtonText => Intl.message(
    'Sign Up',
    name: 'signupButtonText',
    desc: 'Text for the sign up button',
  );
}
