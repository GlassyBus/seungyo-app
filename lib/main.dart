import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/routes.dart';
import 'package:seungyo/view/login/login_screen.dart';
import 'package:seungyo/view/main/main_screen.dart';
import 'package:seungyo/view/signup/signup_screen.dart';
import 'package:seungyo/view/splash/splash_screen.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';
import 'package:seungyo/viewmodel/splash_vm.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SplashViewModel>(
          create: (_) => SplashViewModel(),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
        ),
      ],
      child: MaterialApp(
        title: '승요',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: Routes.splash,
        routes: {
          Routes.splash: (context) => SplashScreen(),
          Routes.login: (context) => LoginScreen(),
          Routes.signup: (context) => SignupScreen(),
          Routes.main: (context) => MainScreen(),
        },
      ),
    );
  }
}