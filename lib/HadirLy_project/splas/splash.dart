import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/helper/sharedpref/pref_splas.dart';
import 'package:hadirly/HadirLy_project/login_regis/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  void changePage() {
    Future.delayed(const Duration(seconds: 3), () async {
      bool isLogin = await PreferenceHandler.getLogin();
      print("isLogin: $isLogin");
      if (isLogin) {
        return Navigator.pushNamedAndRemoveUntil(
          context,
          Login.id,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    changePage();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset('assets/image/logo.png', scale: 2),
              ),
            ),
            const Spacer(),
            const SafeArea(
              child: Text("v 1.0.0", style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
