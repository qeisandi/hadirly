import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/bottomNav/bottom_nav.dart';
import 'package:hadirly/HadirLy_project/login_regis/login.dart';
import 'package:hadirly/HadirLy_project/login_regis/regis.dart';
import 'package:hadirly/HadirLy_project/main/dashboard.dart';
import 'package:hadirly/HadirLy_project/main/profile.dart';
import 'package:hadirly/HadirLy_project/main/riwayat.dart';
import 'package:hadirly/HadirLy_project/splas/splash.dart';
// import 'package:hadirly/HadirLy_project/splas/splash.dart';
// import 'package:hadirly/HadirLy_project/splas/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      // home: const SplashScreen(),
    );
  }
}
