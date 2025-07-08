import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  static String id = "/profile";

  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF9F3EF),
      appBar: AppBar(
        backgroundColor: Color(0xFF1B3C53),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 40),
            decoration: BoxDecoration(
              color: Color(0xFF1B3C53),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(80)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/image/profile.png'),
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(height: 16),
                Text(
                  'Muhammad Adolf Santoso',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Gilroy',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '123456789',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Ubah Profil',
                  iconColor: Colors.deepPurple,
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Ubah Kata Sandi',
                  iconColor: Colors.green,
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Keluar',
                  iconColor: Colors.red,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title, style: const TextStyle(fontFamily: 'Gilroy')),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
