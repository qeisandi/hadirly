import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/bottomNav/bottom_nav.dart';
import 'package:hadirly/HadirLy_project/helper/sharedpref/pref_api.dart';
import 'package:hadirly/HadirLy_project/login_regis/login.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hadirly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        Login.id: (context) => const Login(),
        BottomNavScreen.id: (context) => const BottomNavScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await SharedPref.getToken();
    await Future.delayed(const Duration(seconds: 3));
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, BottomNavScreen.id);
    } else {
      Navigator.pushReplacementNamed(context, Login.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
