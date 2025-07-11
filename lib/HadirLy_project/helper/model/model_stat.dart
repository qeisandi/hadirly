// To parse this JSON data, do
//
//     final statistikAttend = statistikAttendFromJson(jsonString);

import 'dart:convert';

StatistikAttend statistikAttendFromJson(String str) =>
    StatistikAttend.fromJson(json.decode(str));

String statistikAttendToJson(StatistikAttend data) =>
    json.encode(data.toJson());

class StatistikAttend {
  String? message;
  Data? data;

  StatistikAttend({this.message, this.data});

  factory StatistikAttend.fromJson(Map<String, dynamic> json) =>
      StatistikAttend(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  int? totalAbsen;
  int? totalMasuk;
  int? totalIzin;
  bool? sudahAbsenHariIni;

  Data({
    this.totalAbsen,
    this.totalMasuk,
    this.totalIzin,
    this.sudahAbsenHariIni,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalAbsen: json["total_absen"],
    totalMasuk: json["total_masuk"],
    totalIzin: json["total_izin"],
    sudahAbsenHariIni: json["sudah_absen_hari_ini"],
  );

  Map<String, dynamic> toJson() => {
    "total_absen": totalAbsen,
    "total_masuk": totalMasuk,
    "total_izin": totalIzin,
    "sudah_absen_hari_ini": sudahAbsenHariIni,
  };
}
