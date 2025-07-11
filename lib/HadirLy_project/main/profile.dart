import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_photo_pro.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_profile.dart';
import 'package:hadirly/HadirLy_project/helper/servis/auth_servis.dart';
import 'package:hadirly/HadirLy_project/main/update.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  static String id = "/profile";

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  PhotoProfile? _photoProfile;
  bool _isLoadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadPhotoProfile();
  }

  Future<void> _loadPhotoProfile() async {
    setState(() {
      _isLoadingPhoto = true;
    });

    try {
      final photo = await _authService.getPhotoProfile();
      setState(() {
        _photoProfile = photo;
        _isLoadingPhoto = false;
      });
    } catch (e) {
      print("Error loading photo profile: $e");
      setState(() {
        _isLoadingPhoto = false;
      });
    }
  }

  Future<void> _showPhotoDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Ubah Foto Profil',
            style: TextStyle(fontFamily: 'Gilroy'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih sumber foto:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                        icon: const Icon(Icons.camera_alt, size: 40),
                        color: Colors.blue,
                      ),
                      const Text('Kamera'),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.photo_library, size: 40),
                        color: Colors.green,
                      ),
                      const Text('Galeri'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadPhoto(File(image.path));
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memilih gambar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadPhoto(File imageFile) async {
    setState(() {
      _isLoadingPhoto = true;
    });

    try {
      final result = await _authService.photoProfile(imageFile: imageFile);

      setState(() {
        _photoProfile = result;
        _isLoadingPhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingPhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memperbarui foto profil: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _isLoadingPhoto
                              ? const CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                              : CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    _photoProfile?.data?.profilePhoto != null
                                        ? NetworkImage(
                                          _photoProfile!.data!.profilePhoto!,
                                        )
                                        : const AssetImage(
                                              'assets/image/profile.png',
                                            )
                                            as ImageProvider,
                              ),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.teal,
                              ),
                              onPressed: _showPhotoDialog,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
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

                    SizedBox(height: 16),
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
