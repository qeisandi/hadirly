import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_profile.dart';
import 'package:hadirly/HadirLy_project/main/update.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  static String id = "/profile";

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Profile?> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    final url = Uri.parse(Endpoint.getProfile);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = GetProfile.fromJson(jsonResponse);
        return data.data;
      } else {
        print("Gagal mengambil data profil: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
      return null;
    }
  }

  Future<void> _logoutConfirmed(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Konfirmasi",
              style: TextStyle(fontFamily: 'Inter'),
            ),
            content: const Text("Apakah Anda yakin ingin keluar?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tidak"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logoutConfirmed(context);
                },
                child: const Text("Iya"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3C53),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Settings belum tersedia")),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<Profile?>(
        future: fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Gagal memuat data profil."));
          }

          final user = snapshot.data!;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 40),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B3C53),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(80),
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/image/profile.png'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    if (user.trainingTitle != null)
                      Text(
                        user.trainingTitle!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    if (user.batchKe != null)
                      Text(
                        "Batch ${user.batchKe}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children:
                      ListTile.divideTiles(
                        context: context,
                        tiles: [
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Ubah Profil',
                            iconColor: Colors.deepPurple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateProfilePage(),
                                ),
                              );
                            },
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
                            onTap: () => _showLogoutConfirmation(context),
                          ),
                        ],
                      ).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontFamily: 'Gilroy')),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
