import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hadirly/HadirLy_project/helper/Utils/copyright_footer.dart';
import 'package:hadirly/HadirLy_project/helper/Utils/snackbar_util.dart';
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
      showCustomSnackbar(
        context,
        "Gagal mendapatkan lokasi. Silakan refresh lokasi terlebih dahulu.",
        type: SnackbarType.error,
      );
      return;
    }

    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    final token = await SharedPref.getToken();

    if (token == null) {
      showCustomSnackbar(
        context,
        "Token tidak ditemukan. Harap login ulang.",
        type: SnackbarType.error,
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
    if (!mounted) return;

    if (success) {
      setState(() {
        checkInTime = formattedTime;
        status = "Sudah Check In";
      });
      showCustomSnackbar(
        context,
        "Berhasil Check In",
        type: SnackbarType.success,
      );
    } else {
      showCustomSnackbar(
        context,
        "Gagal Check In. Silakan coba lagi atau hubungi admin.",
        type: SnackbarType.error,
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: Container(),
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1B3C53),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B3C53),
                      Color(0xFF456882),
                      Color(0xFF6B8BA3),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.fingerprint,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kehadiran',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  Text(
                                    '$dayFormatted, $dateFormatted',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.account_circle,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF8FAFC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusItem(
                              icon: Icons.login,
                              label: 'Check In',
                              value: checkInTime,
                              color: const Color(0xFF1B3C53),
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            _buildStatusItem(
                              icon: Icons.logout,
                              label: 'Check Out',
                              value: checkOutTime,
                              color: const Color(0xFF1B3C53),
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            _buildStatusItem(
                              icon:
                                  status == "Sudah Check In"
                                      ? Icons.check_circle
                                      : Icons.access_time,
                              label: 'Status',
                              value: status,
                              color:
                                  status == "Sudah Check In"
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                status == "Sudah Check In"
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  status == "Sudah Check In"
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            status == "Sudah Check In"
                                ? "✓ Sudah melakukan check-in hari ini"
                                : "⏰ Belum melakukan check-in",
                            style: TextStyle(
                              color:
                                  status == "Sudah Check In"
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1B3C53).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF1B3C53),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Lokasi Anda',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: _getCurrentLocation,
                                icon: Icon(
                                  Icons.refresh,
                                  color: Color(0xFF1B3C53),
                                ),
                                tooltip: 'Refresh Lokasi',
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 200,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child:
                                _isLoadingLocation
                                    ? Container(
                                      color: Colors.grey.withOpacity(0.1),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              color: Color(0xFF1B3C53),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Memuat lokasi...',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    : GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target:
                                            _currentPosition ??
                                            LatLng(-6.2, 106.816666),
                                        zoom: 15,
                                      ),
                                      onMapCreated: (controller) {
                                        mapController = controller;
                                      },
                                      markers:
                                          _marker != null ? {_marker!} : {},
                                      myLocationButtonEnabled: true,
                                      myLocationEnabled: true,
                                      zoomControlsEnabled: false,
                                      mapToolbarEnabled: false,
                                    ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.grey,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _currentAddress,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1B3C53), Color(0xFF456882)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B3C53).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap:
                                _currentPosition == null
                                    ? null
                                    : _handleCheckIn,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fingerprint,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Check In Sekarang',
                                    style: TextStyle(
                                      color:
                                          _currentPosition == null
                                              ? Colors.white.withOpacity(0.5)
                                              : Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      //  SizedBox(height: 16),

                      // Container(
                      //   width: double.infinity,
                      //   height: 48,
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(
                      //       color: const Color(0xFF1B3C53).withOpacity(0.2),
                      //     ),
                      //   ),
                      //   child: Material(
                      //     color: Colors.transparent,
                      //     child: InkWell(
                      //       onTap: () {
                      //         showCustomSnackbar(
                      //           context,
                      //           "Fitur foto belum diaktifkan.",
                      //           type: SnackbarType.info,
                      //         );
                      //       },
                      //       borderRadius: BorderRadius.circular(12),
                      //       child: Container(
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 24,
                      //         ),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             const Icon(
                      //               Icons.camera_alt,
                      //               color: Color(0xFF1B3C53),
                      //               size: 20,
                      //             ),
                      //             const SizedBox(width: 8),
                      //             const Text(
                      //               'Ambil Foto',
                      //               style: TextStyle(
                      //                 color: Color(0xFF1B3C53),
                      //                 fontSize: 14,
                      //                 fontWeight: FontWeight.w600,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      CopyrightFooter(),
                    ],
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

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
