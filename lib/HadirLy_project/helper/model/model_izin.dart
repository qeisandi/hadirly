// To parse this JSON data, do
//
//     final perizinan = perizinanFromJson(jsonString);

import 'dart:convert';

Perizinan perizinanFromJson(String str) => Perizinan.fromJson(json.decode(str));

String perizinanToJson(Perizinan data) => json.encode(data.toJson());

class Perizinan {
  String? message;
  Izin? data;

  Perizinan({this.message, this.data});

  factory Perizinan.fromJson(Map<String, dynamic> json) => Perizinan(
    message: json["message"],
    data: json["data"] == null ? null : Izin.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Izin {
  int? id;
  DateTime? attendanceDate;
  dynamic checkInTime;
  dynamic checkInLat;
  dynamic checkInLng;
  dynamic checkInLocation;
  dynamic checkInAddress;
  String? status;
  String? alasanIzin;

  Izin({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    this.status,
    this.alasanIzin,
  });

  factory Izin.fromJson(Map<String, dynamic> json) => Izin(
    id: json["id"],
    attendanceDate:
        json["attendance_date"] == null
            ? null
            : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkInLat: json["check_in_lat"],
    checkInLng: json["check_in_lng"],
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date":
        "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
