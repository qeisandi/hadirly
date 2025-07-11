import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_cekin.dart';
import 'package:hadirly/HadirLy_project/helper/servis/check_servis.dart';
import 'package:hadirly/HadirLy_project/helper/sharedpref/pref_api.dart';
import 'package:hadirly/HadirLy_project/main/profile.dart';
import 'package:intl/intl.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  final CheckServis checkServis = CheckServis();
  GoogleMapController? mapController;

  LatLng? _currentPosition;
  String _currentAddress = 'Memuat lokasi...';
  Marker? _marker;

  String checkInTime = "-";
  String checkOutTime = "-";
  String status = "Belum Check In";

  bool _isLoadingLocation = true;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _currentAddress = 'Memuat lokasi...';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = LatLng(position.latitude, position.longitude);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = "${place.name}, ${place.street}, ${place.locality}";
          _marker = Marker(
            markerId: const MarkerId("Lokasi Saya"),
            position: _currentPosition!,
            infoWindow: InfoWindow(
              title: "Lokasi Anda",
              snippet: _currentAddress,
            ),
          );
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentPosition!, zoom: 16),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = "Gagal mendapatkan lokasi";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null ||
        _currentAddress == "Gagal mendapatkan lokasi") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal mendapatkan lokasi. Silakan refresh lokasi terlebih dahulu.",
          ),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    final token = await SharedPref.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Token tidak ditemukan. Harap login ulang."),
        ),
      );
      return;
    }

    final data = CheckInGet(
      attendanceDate: now,
      checkInTime: formattedTime,
      checkInLat: _currentPosition!.latitude,
      checkInLng: _currentPosition!.longitude,
      checkInLocation: _currentAddress,
      checkInAddress: _currentAddress,
      status: "hadir",
      alasanIzin: null,
    );

    final success = await checkServis.postCheckIn(data);

    // Check if widget is still mounted before calling setState
    if (!mounted) return;

    if (success) {
      setState(() {
        checkInTime = formattedTime;
        status = "Sudah Check In";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil Check In"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal Check In. Silakan coba lagi atau hubungi admin.",
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormatted = DateFormat("dd-MMM-yyyy").format(now);
    final dayFormatted = DateFormat("EEEE").format(now);

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        titleSpacing: 0,
        backgroundColor: const Color(0xFF1B3C53),
        title: const Text(
          'Kehadiran',
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
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fitur Settings belum tersedia"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoadingLocation
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 300,
                              width: double.infinity,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target:
                                      _currentPosition ??
                                      LatLng(-6.2, 106.816666),
                                  zoom: 14,
                                ),
                                onMapCreated: (controller) {
                                  mapController = controller;
                                },
                                markers: _marker != null ? {_marker!} : {},
                                myLocationButtonEnabled: true,
                                myLocationEnabled: true,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          right: 20,
                          child: Card(
                            color: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "Distance from place",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "250.43m",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _currentAddress,
                                      style: const TextStyle(fontSize: 11),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 30,
                          child: FloatingActionButton(
                            backgroundColor: Colors.white,
                            onPressed: _getCurrentLocation,
                            tooltip: "Refresh Lokasi",
                            child: const Icon(
                              Icons.location_searching_rounded,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Waktu Kehadiran",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dayFormatted,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(dateFormatted),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Check In",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(checkInTime),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Check Out",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(checkOutTime),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text.rich(
                                TextSpan(
                                  text: 'Status: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: status,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Fitur foto belum diaktifkan."),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1B3C53),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: const BorderSide(
                                  color: Color(0xFF1B3C53),
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Ambil Foto"),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed:
                                _currentPosition == null
                                    ? null
                                    : _handleCheckIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B3C53),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text("Check In"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
    );
  }
}
