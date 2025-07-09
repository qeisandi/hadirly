import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_profile.dart';
import 'package:hadirly/HadirLy_project/main/riwayat.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Main extends StatefulWidget {
  static String id = "/main";
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

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
        setState(() {
          _profile = data.data;
        });
      } else {
        print("Gagal mengambil data profil: ${response.statusCode}");
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }

  final List<Map<String, String>> attendanceData = [
    {'date': 'Monday 13', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
    {'date': 'Tuesday 14', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
    {'date': 'Wed 15', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
    {'date': 'Thursday 16', 'checkIn': '07:50:00', 'checkOut': '17:50:00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: Color(0xFF1B3C53),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(200),
                        bottomRight: Radius.circular(200),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'MORNING',
                          style: TextStyle(
                            fontFamily: 'BitcountGridDouble',
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _profile?.name ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        SizedBox(height: 10),
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(
                            'assets/image/profile.png',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _profile?.trainingTitle ?? '',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  Text(
                    'Distance from place',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    '250.43m',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF456882),
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Check In',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '07 : 50 : 00',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFD2C1B6),
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Check Out',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 18,
                                    color: Color(0xFF1B3C53),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '17 : 50 : 00',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1B3C53),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 24),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Jl. Kebembem II No.83G 9, Kec. Jagakarsa, Kota Jakarta selatan, Indonesia',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Kehadiran',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 18,
                            color: Color(0xFF1B3C53),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Riwayat(),
                              ),
                            );
                          },
                          child: Text(
                            'Lihat Semua',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
