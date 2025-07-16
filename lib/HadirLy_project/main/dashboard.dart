import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hadirly/HadirLy_project/helper/Utils/snackbar_util.dart';
import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_absen.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_history.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_photo_pro.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_profile.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_profile_photo.dart';
import 'package:hadirly/HadirLy_project/helper/servis/auth_servis.dart';
import 'package:hadirly/HadirLy_project/helper/servis/check_servis.dart';
import 'package:hadirly/HadirLy_project/helper/servis/history_servis.dart';
import 'package:hadirly/HadirLy_project/helper/servis/izin_servis.dart';
import 'package:hadirly/HadirLy_project/helper/servis/profile_photo_servis.dart';
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
  ProfilePhotoData? _profileData;
  bool _isLoadingProfilePhoto = true;
  final CheckServis _checkServis = CheckServis();
  final AuthService _authService = AuthService();
  final AttendanceService _attendanceService = AttendanceService();
  bool _isLoadingAttendance = true;
  bool isLoadingPhoto = false;
  final IzinService _izinService = IzinService();
  final ProfilePhotoService _profilePhotoService = ProfilePhotoService();
  final TextEditingController _alasanController = TextEditingController();
  List<History>? _historyData;
  bool _isLoadingHistory = true;
  DateTime? _selectedIzinDate;

  @override
  void initState() {
    super.initState();
    fetchProfilePhoto();
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
        if (mounted) {
          setState(() {
            _profile = data.data;
          });
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchPhotoProfile() async {
    if (!mounted) return;
    setState(() {
      isLoadingPhoto = true;
    });

    try {
      final photo = await _authService.getPhotoProfile();
      if (mounted) {
        setState(() {
          _photoProfile = photo;
          isLoadingPhoto = false;
        });
      }
    } catch (e) {
      print("Error loading photo profile: $e");
      if (mounted) {
        setState(() {
          isLoadingPhoto = false;
        });
      }
    }
  }

  Future<void> fetchProfilePhoto() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfilePhoto = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        if (!mounted) return;
        setState(() {
          _isLoadingProfilePhoto = false;
        });
        return;
      }
      final response = await _profilePhotoService.fetchProfilePhoto(
        token: token,
      );
      if (!mounted) return;
      setState(() {
        _profileData = response?.data;
        _isLoadingProfilePhoto = false;
      });
    } catch (e) {
      print("Error loading profile photo: $e");
      if (!mounted) return;
      setState(() {
        _isLoadingProfilePhoto = false;
      });
    }
  }

  ImageProvider getProfileImage() {
    final url = _profileData?.profilePhoto;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('data:image')) {
        return MemoryImage(base64Decode(url.split(',').last));
      } else if (url.length > 100) {
        return MemoryImage(base64Decode(url));
      } else if (url.startsWith('http')) {
        return NetworkImage(url);
      } else {
        return NetworkImage('https://appabsensi.mobileprojp.com/public/$url');
      }
    }
    return const AssetImage('assets/image/profile.png');
  }

  Future<void> fetchTodayAttendance() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAttendance = true;
    });

    try {
      final attendance = await _checkServis.getTodayAttendance();
      if (mounted) {
        setState(() {
          _todayAttendance = attendance;
          _isLoadingAttendance = false;
        });
      }
    } catch (e) {
      print("Error fetching attendance: $e");
      if (mounted) {
        setState(() {
          _isLoadingAttendance = false;
        });
      }
    }
  }

  Future<void> fetchHistoryData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final historyResponse = await _attendanceService.fetchHistoryAttendance();
      if (historyResponse?.data != null) {
        final latestHistory = historyResponse!.data!.take(4).toList();
        if (mounted) {
          setState(() {
            _historyData = latestHistory;
            _isLoadingHistory = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _historyData = [];
            _isLoadingHistory = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching history: $e");
      if (mounted) {
        setState(() {
          _historyData = [];
          _isLoadingHistory = false;
        });
      }
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
    if (hasSubmittedIzin) {
      if (!mounted) return;
      showCustomSnackbar(
        context,
        "Anda sudah mengajukan izin hari ini!",
        type: SnackbarType.warning,
      );
      return;
    }

    if (isCheckedIn) {
      if (!mounted) return;
      showCustomSnackbar(
        context,
        "Anda sudah melakukan check-in hari ini!",
        type: SnackbarType.info,
      );
      return;
    }

    // Set default tanggal izin ke hari ini
    _selectedIzinDate = DateTime.now();
    final currentContext = context;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
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
                      "Silakan pilih tanggal dan tulis alasan izin Anda:",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Color(0xFF1B3C53),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    _selectedIzinDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 7),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  _selectedIzinDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                _selectedIzinDate != null
                                    ? "${_selectedIzinDate!.day.toString().padLeft(2, '0')}-${_selectedIzinDate!.month.toString().padLeft(2, '0')}-${_selectedIzinDate!.year}"
                                    : "Pilih tanggal izin",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1B3C53),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                        if (!mounted) return;
                        showCustomSnackbar(
                          currentContext,
                          "Alasan tidak boleh kosong!",
                          type: SnackbarType.warning,
                        );
                        return;
                      }
                      if (_selectedIzinDate == null) {
                        showCustomSnackbar(
                          currentContext,
                          "Pilih tanggal izin terlebih dahulu!",
                          type: SnackbarType.warning,
                        );
                        return;
                      }
                      Navigator.of(context).pop();
                      showCustomSnackbar(
                        currentContext,
                        "Mengajukan izin...",
                        type: SnackbarType.info,
                        icon: Icons.hourglass_top_rounded,
                      );
                      try {
                        final result = await _izinService.postIzin(
                          alasanIzin: alasan,
                          tanggalIzin: _selectedIzinDate,
                        );
                        if (!mounted) return;
                        if (result != null && result.message != null) {
                          showCustomSnackbar(
                            currentContext,
                            "Izin berhasil diajukan!",
                            type: SnackbarType.success,
                          );
                          _alasanController.clear();
                          fetchTodayAttendance();
                        } else {
                          showCustomSnackbar(
                            currentContext,
                            "Gagal mengajukan izin. Silakan coba lagi.",
                            type: SnackbarType.error,
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        showCustomSnackbar(
                          currentContext,
                          "Terjadi kesalahan: $e",
                          type: SnackbarType.error,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1B3C53),
                    ),
                    child: Text("Kirim", style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> handleCheckOut() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showCustomSnackbar(
          context,
          "Izin lokasi ditolak!",
          type: SnackbarType.error,
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
        showCustomSnackbar(
          context,
          "Berhasil Check Out!",
          type: SnackbarType.success,
        );
        fetchTodayAttendance();
      } else {
        showCustomSnackbar(
          context,
          "Gagal Check Out!",
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      print("Error saat check out: $e");
      showCustomSnackbar(
        context,
        "Terjadi kesalahan saat Check Out",
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 70, horizontal: 20),
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
                  _isLoadingProfilePhoto
                      ? CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : CircleAvatar(
                        radius: 50,
                        backgroundImage: getProfileImage(),
                      ),
                  SizedBox(height: 10),
                  Text(
                    _profile?.trainingTitle ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
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
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                              : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Silakan lakukan check-in di halaman kehadiran",
                                    ),
                                    backgroundColor: Colors.red,
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
                    GestureDetector(
                      onTap:
                          (!isCheckedIn || isCheckedOut)
                              ? null
                              : handleCheckOut,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
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
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
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
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Riwayat()),
                      );
                      fetchHistoryData();
                    },
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoadingAttendance)
              CircularProgressIndicator()
            else if (_todayAttendance?.data == null)
              (!_isLoadingHistory &&
                      _historyData != null &&
                      _historyData!.isNotEmpty)
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._historyData!.map((item) {
                          final date = item.attendanceDate?.toLocal();
                          final day = _getDayName(date);
                          final number =
                              date?.day.toString().padLeft(2, '0') ?? "";
                          final isIzin = item.status == 'izin';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              margin: EdgeInsets.zero,
                              color:
                                  isIzin ? Colors.orange[50] : Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isIzin
                                                ? Colors.orange
                                                : Color(0xFF1B3C53),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                isIzin ? 'Izin' : 'Check In',
                                                style: TextStyle(
                                                  color:
                                                      isIzin
                                                          ? Colors.orange
                                                          : Color(0xFF1B3C53),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              if (isIzin)
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'IZIN',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              Spacer(),
                                              Text(
                                                isIzin
                                                    ? '-'
                                                    : (item.checkInTime ?? '-'),
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
                                                isIzin ? 'Alasan' : 'Check Out',
                                                style: TextStyle(
                                                  color:
                                                      isIzin
                                                          ? Colors.orange
                                                          : Color(0xFF1B3C53),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Spacer(),
                                              Flexible(
                                                child: Text(
                                                  isIzin
                                                      ? (item.alasanIzin
                                                              ?.toString() ??
                                                          '-')
                                                      : (item.checkOutTime ??
                                                          '-'),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        isIzin
                                                            ? Colors.orange[800]
                                                            : null,
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                        }),
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
              (_historyData != null && _historyData!.isNotEmpty)
                  ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          _historyData!.length > 4 ? 4 : _historyData!.length,
                      itemBuilder: (context, index) {
                        final item = _historyData![index];
                        final date = item.attendanceDate?.toLocal();
                        final day = _getDayName(date);
                        final number =
                            date?.day.toString().padLeft(2, '0') ?? "";
                        final isIzin = item.status == 'izin';

                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            margin: EdgeInsets.zero,
                            color:
                                isIzin ? Colors.orange[50] : Colors.grey[100],
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
                                      color:
                                          isIzin
                                              ? Colors.orange
                                              : Color(0xFF1B3C53),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              isIzin ? 'Izin' : 'Check In',
                                              style: TextStyle(
                                                color:
                                                    isIzin
                                                        ? Colors.orange
                                                        : Color(0xFF1B3C53),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (isIzin)
                                              Container(
                                                margin: EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'IZIN',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            Spacer(),
                                            Text(
                                              isIzin
                                                  ? '-'
                                                  : (item.checkInTime ?? '-'),
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
                                              isIzin ? 'Alasan' : 'Check Out',
                                              style: TextStyle(
                                                color:
                                                    isIzin
                                                        ? Colors.orange
                                                        : Color(0xFF1B3C53),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Spacer(),
                                            Flexible(
                                              child: Text(
                                                isIzin
                                                    ? (item.alasanIzin
                                                            ?.toString() ??
                                                        '-')
                                                    : (item.checkOutTime ??
                                                        '-'),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      isIzin
                                                          ? Colors.orange[800]
                                                          : null,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
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
                      },
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
