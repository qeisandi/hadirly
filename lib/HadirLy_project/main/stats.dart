import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/main/profile.dart';

class AbsenStatsPage extends StatefulWidget {
  const AbsenStatsPage({super.key});

  @override
  State<AbsenStatsPage> createState() => _AbsenStatsPageState();
}

class _AbsenStatsPageState extends State<AbsenStatsPage> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> stats = {
      "total_absen": 1,
      "total_masuk": 1,
      "total_izin": 0,
      "sudah_absen_hari_ini": true,
    };

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        backgroundColor: Color(0xFF1B3C53),
        titleSpacing: 0,
        title: Text(
          "Statistik Absensi",
          style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("Fitur Settings belum tersedia"),
                ),
              );
            },
            icon: Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            buildStatCard(
              "Total Absen",
              stats["total_absen"].toString(),
              Icons.assignment,
            ),
            SizedBox(height: 12),
            buildStatCard(
              "Total Masuk",
              stats["total_masuk"].toString(),
              Icons.login,
            ),
            SizedBox(height: 12),
            buildStatCard(
              "Total Izin",
              stats["total_izin"].toString(),
              Icons.airline_seat_individual_suite,
            ),
            SizedBox(height: 12),
            buildStatCard(
              "Sudah Absen Hari Ini",
              stats["sudah_absen_hari_ini"] ? "Ya" : "Belum",
              stats["sudah_absen_hari_ini"] ? Icons.check_circle : Icons.cancel,
              iconColor:
                  stats["sudah_absen_hari_ini"] ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatCard(
    String title,
    String value,
    IconData icon, {
    Color? iconColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor ?? Color(0xFF1B3C53),
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B3C53),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
