import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_absen.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_profile.dart';
import 'package:hadirly/HadirLy_project/helper/servis/check_servis.dart';
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
  AbsenToday? _todayAttendance;
  final CheckServis _checkServis = CheckServis();
  bool _isLoadingAttendance = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchTodayAttendance();
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
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchTodayAttendance() async {
    setState(() {
      _isLoadingAttendance = true;
    });

    try {
      final attendance = await _checkServis.getTodayAttendance();
      setState(() {
        _todayAttendance = attendance;
        _isLoadingAttendance = false;
      });
    } catch (e) {
      print("Error fetching attendance: $e");
      setState(() {
        _isLoadingAttendance = false;
      });
    }
  }

  String getCheckInTime() {
    if (_isLoadingAttendance) return '-- : -- : --';
    return _todayAttendance?.data?.checkInTime ?? '-- : -- : --';
  }

  String getCheckOutTime() {
    if (_isLoadingAttendance) return '-- : -- : --';
    return _todayAttendance?.data?.checkOutTime ?? '-- : -- : --';
  }

  bool get isCheckedIn => _todayAttendance?.data?.checkInTime != null;
  bool get isCheckedOut => _todayAttendance?.data?.checkOutTime != null;

  Future<void> handleCheckOut() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Izin lokasi ditolak!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double lat = position.latitude;
      double lng = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      String address =
          placemarks.isNotEmpty
              ? "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}"
              : "Tidak diketahui";

      bool success = await _checkServis.checkOut(
        checkOutLat: lat,
        checkOutLng: lng,
        checkOutAddress: address,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berhasil Check Out!"),
            backgroundColor: Colors.green,
          ),
        );
        fetchTodayAttendance();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal Check Out!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error saat check out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan saat Check Out"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 70),
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
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/image/profile.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _profile?.trainingTitle ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('Distance from place', style: TextStyle(color: Colors.black)),
            Text(
              '250.43m',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // CHECK IN
                Column(
                  children: [
                    ElevatedButton(
                      onPressed:
                          isCheckedIn
                              ? null
                              : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Silakan lakukan check-in di halaman kehadiran",
                                    ),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1B3C53),
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
                            isCheckedIn ? 'Checked In' : 'Check In',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            getCheckInTime(),
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                // CHECK OUT
                Column(
                  children: [
                    ElevatedButton(
                      onPressed:
                          (!isCheckedIn || isCheckedOut)
                              ? null
                              : handleCheckOut,
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
                            isCheckedOut ? 'Checked Out' : 'Check Out',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF1B3C53),
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            getCheckOutTime(),
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
                      fontSize: 18,
                      color: Color(0xFF1B3C53),
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Riwayat()),
                      );
                    },
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
