// To parse this JSON data, do
//
//     final checkIn = checkInFromJson(jsonString);

import 'dart:convert';

CheckIn checkInFromJson(String str) => CheckIn.fromJson(json.decode(str));

String checkInToJson(CheckIn data) => json.encode(data.toJson());

class CheckIn {
  String? message;
  CheckInGet? data;

  CheckIn({this.message, this.data});

  factory CheckIn.fromJson(Map<String, dynamic> json) => CheckIn(
    message: json["message"],
    data: json["data"] == null ? null : CheckInGet.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class CheckInGet {
  int? id;
  DateTime? attendanceDate;
  String? checkInTime;
  double? checkInLat;
  double? checkInLng;
  String? checkInLocation;
  String? checkInAddress;
  String? status;
  dynamic alasanIzin;
  String? checkIn; // Added check_in field

  CheckInGet({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    this.status,
    this.alasanIzin,
    this.checkIn,
  });

  factory CheckInGet.fromJson(Map<String, dynamic> json) => CheckInGet(
    id: json["id"],
    attendanceDate:
        json["attendance_date"] == null
            ? null
            : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
    checkIn: json["check_in"],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data["id"] = id;

    if (attendanceDate != null) {
      data["attendance_date"] =
          "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}";
    }

    if (checkInTime != null) data["check_in_time"] = checkInTime;
    if (checkInLat != null) data["check_in_lat"] = checkInLat;
    if (checkInLng != null) data["check_in_lng"] = checkInLng;
    if (checkInLocation != null) data["check_in_location"] = checkInLocation;
    if (checkInAddress != null) data["check_in_address"] = checkInAddress;
    if (status != null) data["status"] = status;

    // Fix check_in field to use time format H:i
    if (checkInTime != null) {
      // Convert HH:mm:ss to HH:mm format
      final timeParts = checkInTime!.split(':');
      if (timeParts.length >= 2) {
        data["check_in"] = "${timeParts[0]}:${timeParts[1]}";
      } else {
        data["check_in"] = checkInTime;
      }
    } else if (checkIn != null) {
      data["check_in"] = checkIn;
    }

    // Only include alasan_izin if it's not null and not empty
    if (alasanIzin != null && alasanIzin.toString().isNotEmpty) {
      data["alasan_izin"] = alasanIzin;
    }

    return data;
  }
}
