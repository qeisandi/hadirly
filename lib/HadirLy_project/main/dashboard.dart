import 'package:flutter/material.dart';

class Main extends StatefulWidget {
  static const String id = "/main";

  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final List<Map<String, String>> dummyAttendance = [
    {'status': 'Check In', 'time': '08:00 AM', 'date': '2025-07-07'},
    {'status': 'Check Out', 'time': '17:00 PM', 'date': '2025-07-07'},
    {'status': 'Check In', 'time': '08:15 AM', 'date': '2025-07-06'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F3EF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Color(0xFF1B3C53),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Morning',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/image/profile.png'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF456882),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Check In',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD2C1B6),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Check Out',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 18,
                      color: Color(0xFF1B3C53),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFD2C1B6).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Absensi',
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B3C53),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...dummyAttendance.map((entry) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              entry['status'] == 'Check In'
                                  ? Icons.login
                                  : Icons.logout,
                              color:
                                  entry['status'] == 'Check In'
                                      ? Color(0xFF456882)
                                      : Color(0xFF1B3C53),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry['status']} - ${entry['time']}',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1B3C53),
                                  ),
                                ),
                                Text(
                                  'Tanggal: ${entry['date']}',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
