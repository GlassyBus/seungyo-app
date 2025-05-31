import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:seungyo/routes.dart';
import 'package:seungyo/view/auth/auth_screen.dart';
import 'package:seungyo/view/main/main_screen.dart';
import 'package:seungyo/view/splash/splash_screen.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';
import 'package:seungyo/viewmodel/splash_vm.dart';
import 'package:seungyo/providers/schedule_provider.dart';
import 'package:seungyo/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 locale 데이터 초기화
  await initializeDateFormatting('ko_KR', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // 앱 전체에서 사용할 최대 너비 상수
  static const double maxServiceWidth = 540.0;

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
      ],
      child: MaterialApp(
        title: '승요',
        theme: createLightTheme(),
        darkTheme: createDarkTheme(),
        // 앱 전체의 최대 너비 제한을 적용하는 builder
        builder: (context, child) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: maxServiceWidth),
              child: child!,
            ),
          );
        },
        themeMode: ThemeMode.light,
        initialRoute: Routes.splash,
        routes: {
          Routes.splash: (context) => const SplashScreen(),
          Routes.auth: (context) => const AuthScreen(),
          Routes.main: (context) => const MainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
