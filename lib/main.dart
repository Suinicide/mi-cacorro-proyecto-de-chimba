import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/stats_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/home_screen.dart';
import 'views/stats_screen.dart';
import 'views/alarms_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => StatsViewModel()),
      ],
      child: MaterialApp(
        title: 'HidraApp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Trebuchet MS',
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/stats': (context) => const StatsScreen(),
          '/alarms': (context) => const AlarmsScreen(),
        },
      ),
    );
  }
}