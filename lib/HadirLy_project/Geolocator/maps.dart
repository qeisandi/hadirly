import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(-6.200000, 106.816666);
  String _currentAdress = 'Alamat Tidak Ada';
  Marker? _marker;

  Future<void> _getCurrentLocation() async {
    bool serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
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
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentPosition = LatLng(position.latitude, position.longitude);

    List<Placemark> placemark = await placemarkFromCoordinates(
      _currentPosition.latitude,
      _currentPosition.longitude,
    );
    Placemark place = placemark[0];

    setState(() {
      _marker = Marker(
        markerId: MarkerId("Lokasi Saya"),
        position: _currentPosition,
        infoWindow: InfoWindow(
          title: "Lokasi Anda",
          snippet: "${place.street},${place.locality}",
        ),
      );

      _currentAdress =
          "${place.name},${place.street},${place.locality},${place.country}";

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 16),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFF9F3EF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF1B3C53),
        title: Text(
          'Kehadiran',
          style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
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
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(_currentAdress, style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff456882),
        onPressed: _getCurrentLocation,
        tooltip: "Refresh Lokasi",
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
