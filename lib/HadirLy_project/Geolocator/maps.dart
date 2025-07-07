import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeoLocation extends StatefulWidget {
  const GeoLocation({super.key});

  @override
  State<GeoLocation> createState() => _GeoLocationState();
}

class _GeoLocationState extends State<GeoLocation> {
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(-6.200000, 106.816666);
  String _currentAdress = 'Alamat Tidak Ada';
  Marker? _marker;

  Future<void> _getCurrentLocation() async {
    bool serviceEnable = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnable) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentPosition = LatLng(position.latitude, position.longitude);

    List<Placemark> placemark = await placemarkFromCoordinates(_currentPosition.latitude, _currentPosition.longitude);
    Placemark place = placemark[0];

    setState(() {
      _marker = Marker(markerId: MarkerId("Lokasi Saya"),
      position: _currentPosition,
      infoWindow: InfoWindow(title: "Lokasi Anda",snippet: "${place.street},${place.locality}",),);

      _currentAdress = "${place.name},${place.street},${place.locality},${place.country}";

      mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _currentPosition,zoom: 16),));
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
      appBar: AppBar(title: Text('Map',style: TextStyle(color: Colors.black,fontFamily: 'Gilroy'),),),
      body: Stack(
        children: [
          GoogleMap(initialCameraPosition: CameraPosition(target: _currentPosition,zoom: 14,
          ),
          onMapCreated: (controller) {
            mapController = controller;
          },
          markers: _marker != null ? {_marker!} : {},
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(color: Colors.white,
            elevation: 4,
            child: Padding(padding: EdgeInsetsGeometry.all(12.0),
            child: Text(_currentAdress,style: TextStyle(fontSize: 14),),),))
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _getCurrentLocation,child: Icon(Icons.refresh),tooltip: "Refresh Lokasi",),
    );
  }
}