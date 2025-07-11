// To parse this JSON data, do
//
//     final historyAttend = historyAttendFromJson(jsonString);

import 'dart:convert';

HistoryAttend historyAttendFromJson(String str) =>
    HistoryAttend.fromJson(json.decode(str));

String historyAttendToJson(HistoryAttend data) => json.encode(data.toJson());

class HistoryAttend {
  String? message;
  List<History>? data;

  HistoryAttend({this.message, this.data});

  factory HistoryAttend.fromJson(Map<String, dynamic> json) => HistoryAttend(
    message: json["message"],
    data:
        json["data"] == null
            ? []
            : List<History>.from(json["data"]!.map((x) => History.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class History {
  int? id;
  DateTime? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  double? checkInLat;
  double? checkInLng;
  double? checkOutLat;
  double? checkOutLng;
  String? checkInAddress;
  String? checkOutAddress;
  String? checkInLocation;
  String? checkOutLocation;
  String? status;
  dynamic alasanIzin;

  History({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInLocation,
    this.checkOutLocation,
    this.status,
    this.alasanIzin,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
    id: json["id"],
    attendanceDate:
        json["attendance_date"] == null
            ? null
            : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkOutLat: json["check_out_lat"]?.toDouble(),
    checkOutLng: json["check_out_lng"]?.toDouble(),
    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    checkInLocation: json["check_in_location"],
    checkOutLocation: json["check_out_location"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date":
        "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "check_in_location": checkInLocation,
    "check_out_location": checkOutLocation,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
