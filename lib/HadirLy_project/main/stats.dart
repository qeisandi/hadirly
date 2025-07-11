import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_stat.dart';
import 'package:hadirly/HadirLy_project/helper/servis/history_servis.dart';
import 'package:hadirly/HadirLy_project/main/profile.dart';

class AbsenStatsPage extends StatefulWidget {
  const AbsenStatsPage({super.key});

  @override
  State<AbsenStatsPage> createState() => _AbsenStatsPageState();
}

class _AbsenStatsPageState extends State<AbsenStatsPage> {
  late Future<StatistikAttend?> statistikFuture;

  @override
  void initState() {
    super.initState();
    statistikFuture =
        AttendanceService().getStatistikAttend(); // panggil dari service
  }

  Future<void> _refreshStats() async {
    setState(() {
      statistikFuture = AttendanceService().getStatistikAttend();
    });
    await statistikFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        backgroundColor: const Color(0xFF1B3C53),
        titleSpacing: 0,
        title: const Text(
          "Statistik Absensi",
          style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("Fitur Settings belum tersedia"),
                ),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStats,
        child: FutureBuilder<StatistikAttend?>(
          future: statistikFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text("Terjadi kesalahan saat mengambil data"),
              );
            }

            if (!snapshot.hasData || snapshot.data?.data == null) {
              return const Center(child: Text("Data tidak tersedia"));
            }

            final data = snapshot.data!.data!;

            return ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                buildStatCard(
                  "Total Absen",
                  "${data.totalAbsen}",
                  Icons.assignment,
                ),
                const SizedBox(height: 12),
                buildStatCard("Total Masuk", "${data.totalMasuk}", Icons.login),
                const SizedBox(height: 12),
                buildStatCard(
                  "Total Izin",
                  "${data.totalIzin}",
                  Icons.airline_seat_individual_suite,
                ),
                const SizedBox(height: 12),
                buildStatCard(
                  "Sudah Absen Hari Ini?",
                  data.sudahAbsenHariIni == true ? "Ya" : "Belum",
                  data.sudahAbsenHariIni == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  iconColor:
                      data.sudahAbsenHariIni == true
                          ? Colors.green
                          : Colors.red,
                ),
              ],
            );
          },
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
              backgroundColor: iconColor ?? const Color(0xFF1B3C53),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
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
