import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/bottomNav/bottom_nav.dart';
import 'package:hadirly/HadirLy_project/login_regis/login.dart';
import 'package:hadirly/HadirLy_project/login_regis/regis.dart';
import 'package:hadirly/HadirLy_project/main/dashboard.dart';
import 'package:hadirly/HadirLy_project/main/profile.dart';
import 'package:hadirly/HadirLy_project/main/riwayat.dart';
import 'package:hadirly/HadirLy_project/splas/splash.dart';

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
      title: 'HadirLy',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        Login.id: (context) => Login(),
        Regis.id: (context) => Regis(),
        Main.id: (context) => Main(),
        ProfilePage.id: (context) => ProfilePage(),
        Riwayat.id: (context) => Riwayat(),
        BottomNavScreen.id: (context) => BottomNavScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
    );
  }
}
