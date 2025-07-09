import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/main/profile.dart';

class Riwayat extends StatefulWidget {
  static String id = "/riwayat";

  const Riwayat({super.key});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  final List<Map<String, String>> attendanceData = [
    {'date': 'Monday 13', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
    {'date': 'Tuesday 14', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
    {'date': 'Wed 15', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
    {'date': 'Thursday 16', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
    {'date': 'Monday 13', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
    {'date': 'Tuesday 14', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
    {'date': 'Wed 15', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
    {'date': 'Thursday 16', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Kehadiran',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF1B3C53),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final item = attendanceData[index];
                  final parts = item['date']!.split(" ");
                  final day = parts[0];
                  final number = parts.length > 1 ? parts[1] : "";

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF1B3C53),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  day,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  number,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Check In',
                                      style: TextStyle(
                                        color: Color(0xFF1B3C53),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      item['checkIn'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Check Out',
                                      style: TextStyle(
                                        color: Color(0xFF1B3C53),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      item['checkOut'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
