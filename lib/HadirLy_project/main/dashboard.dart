import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_absen.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_history.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_photo_pro.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_profile.dart';
import 'package:hadirly/HadirLy_project/helper/servis/auth_servis.dart';
import 'package:hadirly/HadirLy_project/helper/servis/check_servis.dart';
import 'package:hadirly/HadirLy_project/helper/servis/history_servis.dart';
import 'package:hadirly/HadirLy_project/helper/servis/izin_servis.dart';
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
  PhotoProfile? _photoProfile;
  final CheckServis _checkServis = CheckServis();
  final AuthService _authService = AuthService();
  final AttendanceService _attendanceService = AttendanceService();
  bool _isLoadingAttendance = true;
  bool isLoadingPhoto = false;
  final IzinService _izinService = IzinService();
  final TextEditingController _alasanController = TextEditingController();
  List<History>? _historyData;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchTodayAttendance();
    fetchPhotoProfile();
    fetchHistoryData();
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

  Future<void> fetchPhotoProfile() async {
    setState(() {
      isLoadingPhoto = true;
    });

    try {
      final photo = await _authService.getPhotoProfile();
      setState(() {
        _photoProfile = photo;
        isLoadingPhoto = false;
      });
    } catch (e) {
      print("Error loading photo profile: $e");
      setState(() {
        isLoadingPhoto = false;
      });
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

  Future<void> fetchHistoryData() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final historyResponse = await _attendanceService.fetchHistoryAttendance();
      if (historyResponse?.data != null) {
        // Get only the latest 4 records
        final latestHistory = historyResponse!.data!.take(4).toList();
        setState(() {
          _historyData = latestHistory;
          _isLoadingHistory = false;
        });
      } else {
        setState(() {
          _historyData = [];
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      print("Error fetching history: $e");
      setState(() {
        _historyData = [];
        _isLoadingHistory = false;
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
  bool get hasSubmittedIzin => _todayAttendance?.data?.status == 'izin';

  Future<void> showIzinDialog() async {
    // Check if user has already submitted izin today
    if (hasSubmittedIzin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Anda sudah mengajukan izin hari ini!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if user has already checked in
    if (isCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Anda sudah melakukan check-in hari ini!"),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Ajukan Izin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Silakan tulis alasan izin Anda:",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _alasanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Tulis alasan izin...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF1B3C53)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _alasanController.clear();
            },
            child: Text("Batal", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              final alasan = _alasanController.text.trim();
              if (alasan.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Alasan tidak boleh kosong!"),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              // Show loading state
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text("Mengajukan izin..."),
                    ],
                  ),
                  backgroundColor: Color(0xFF1B3C53),
                  duration: Duration(seconds: 2),
                ),
              );

              try {
                final result = await _izinService.postIzin(
                  alasanIzin: alasan,
                );

                if (!mounted) return;

                if (result != null && result.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Izin berhasil diajukan!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _alasanController.clear();
                  // Refresh attendance data to show updated status
                  fetchTodayAttendance();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Gagal mengajukan izin. Silakan coba lagi."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                print("Error submitting izin: $e");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Terjadi kesalahan: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1B3C53),
            ),
            child: Text(
              "Kirim",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

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
              padding: EdgeInsets.symmetric(vertical: 70,horizontal: 20),
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
                      fontSize: 50,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _profile?.name ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 10),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _photoProfile?.data?.profilePhoto != null
                            ? NetworkImage(_photoProfile!.data!.profilePhoto!)
                            : AssetImage('assets/image/profile.png')
                                as ImageProvider,
                  ),
                  SizedBox(height: 10),
                  Text(
                    _profile?.trainingTitle ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.white70),textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap:
                          isCheckedIn
                              ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Kamu sudah check-in hari ini!",
                                    ),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              }
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF1B3C53),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
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
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
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
            SizedBox(height: 16),
if (_isLoadingAttendance)
  CircularProgressIndicator()
else if (_todayAttendance?.data == null)
  // Check if there's history data to show instead of "belum ada riwayat"
  (!_isLoadingHistory && _historyData != null && _historyData!.isNotEmpty)
    ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._historyData!.map((item) {
              final date = item.attendanceDate?.toLocal();
              final day = _getDayName(date);
              final number = date?.day.toString().padLeft(2, '0') ?? "";

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  margin: EdgeInsets.zero,
                  color: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          padding: EdgeInsets.symmetric(vertical: 8),
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
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                number,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          height: 35,
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
                                      fontSize: 12,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    item.checkInTime ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Check Out',
                                    style: TextStyle(
                                      color: Color(0xFF1B3C53),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    item.checkOutTime ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
                ),
              );
            }).toList(),
          ],
        ),
      )
    : Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Belum ada riwayat kehadiran untuk hari ini. Yuk mulai dengan melakukan check-in!',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  )
else
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 10),
              Text(
                "Hari ini kamu sudah melakukan kehadiran!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Waktu Check-In: ${getCheckInTime()}",
            style: TextStyle(color: Colors.black87),
          ),
          Text(
            "Waktu Check-Out: ${getCheckOutTime()}",
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    ),
  ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showIzinDialog,
        label: Text("Ajukan Izin", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.edit_calendar_rounded, color: Colors.white),
        backgroundColor: Color(0xFF1B3C53),
      ),
    );
  }

  String _getDayName(DateTime? date) {
    if (date == null) return '';
    switch (date.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
