import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/Attendence/kehadiran.dart';
import 'package:hadirly/HadirLy_project/main/dashboard.dart';
import 'package:hadirly/HadirLy_project/main/profile.dart';
import 'package:hadirly/HadirLy_project/main/stats.dart';
import 'package:hadirly/HadirLy_project/src/bootom_nav_2.dart';

class BottomNavScreen extends StatefulWidget {
  static String id = "/bottom";
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Main(),
    AbsenStatsPage(),
    ProfilePage(),
    CheckIn(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.data_exploration_outlined, size: 30, color: Colors.white),
          Icon(Icons.account_circle_outlined, size: 30, color: Colors.white),
          Icon(Icons.fingerprint, size: 30, color: Colors.white),
        ],
        index: _currentIndex,
        color: Color(0xFF1B3C53),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Color(0xff456882),
        animationDuration: Duration(milliseconds: 500),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
