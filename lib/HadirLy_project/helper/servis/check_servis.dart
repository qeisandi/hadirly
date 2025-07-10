import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_absen.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_cekin.dart';
import 'package:hadirly/HadirLy_project/helper/sharedpref/pref_api.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckServis {
  Future<bool> postCheckIn(CheckInGet data) async {
    final token = await SharedPref.getToken();
    final url = Uri.parse(Endpoint.checkIn);

    final List<String> possibleStatuses = [
      "hadir",
      "present",
      "attended",
      "check_in",
      "1",
      "active",
      "masuk",
      "dalam",
      "on_time",
      "tepat_waktu",
      "normal",
      "ok",
      "yes",
      "true",
    ];

    for (String status in possibleStatuses) {
      try {
        final testData = CheckInGet(
          id: data.id,
          attendanceDate: data.attendanceDate,
          checkInTime: data.checkInTime,
          checkInLat: data.checkInLat,
          checkInLng: data.checkInLng,
          checkInLocation: data.checkInLocation,
          checkInAddress: data.checkInAddress,
          status: status,
          alasanIzin: data.alasanIzin,
          checkIn: data.checkIn,
        );
        final jsonData = testData.toJson();
        print("Trying status: $status");
        print("Request Data: ${jsonEncode(jsonData)}");

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(jsonData),
        );

        print("Status Code: ${response.statusCode}");
        print("Response Headers: ${response.headers}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          print("Success with status: $status");
          return true;
        } else if (response.statusCode == 422) {
          try {
            final errorData = jsonDecode(response.body);
            print('Validation Errors for status "$status": $errorData');

            if (errorData['errors'] != null) {
              final errors = errorData['errors'] as Map<String, dynamic>;
              errors.forEach((field, messages) {
                print('Field: $field, Errors: $messages');
              });
            }
          } catch (e) {
            print('Error parsing validation response: $e');
          }
          continue;
        } else {
          print('Gagal Check In with status "$status": ${response.statusCode}');
          print('Response: ${response.body}');
          continue;
        }
      } catch (e) {
        print("Error saat Check In with status '$status': $e");
        continue;
      }
    }
    print(
      "All status values failed. Check API documentation for valid status values.",
    );
    return false;
  }

  Future<void> postCheckOut(BuildContext context) async {
    try {
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Token tidak ditemukan.')));
        return;
      }

      // Ambil waktu sekarang dalam format yyyy-MM-dd HH:mm:ss
      final now = DateTime.now();
      final formattedNow = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // Ambil lokasi sekarang
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = position.latitude.toString();
      final lng = position.longitude.toString();

      // Kirim data ke API
      final url = Uri.parse(
        'https://your-api.com/attendance/check-out',
      ); // Ganti dengan URL endpoint check-out kamu
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'check_out': formattedNow,
          'check_out_lat': lat,
          'check_out_lng': lng,
        }),
      );

      // Handle response
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Check Out berhasil.')));
        print('Check Out success: ${response.body}');
      } else {
        final error = jsonDecode(response.body);
        print('Check Out error: ${error.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal Check Out: ${error['message'] ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Exception during Check Out: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  // Get today's attendance data
  Future<AbsenToday?> getTodayAttendance({String? attendanceDate}) async {
    final token = await SharedPref.getToken();

    // Use provided date or current date
    final date =
        attendanceDate ??
        "${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    final url = Uri.parse(
      '${Endpoint.baseUrl}/absen/today?attendance_date=$date',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Get Today Attendance - Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = absenTodayFromJson(response.body);
        return data;
      } else if (response.statusCode == 404) {
        // No attendance data for today
        print("No attendance data found for date: $date");
        return null;
      } else {
        print('Gagal mengambil data kehadiran: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print("Error saat mengambil data kehadiran: $e");
      return null;
    }
  }

  // Get attendance history
  Future<List<Data>?> getAttendanceHistory({int? page, int? limit}) async {
    final token = await SharedPref.getToken();
    final queryParams = <String, String>{};

    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = Uri.parse(
      '${Endpoint.baseUrl}/absen/history',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Get Attendance History - Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['data'] != null) {
          final List<dynamic> dataList = jsonData['data'];
          return dataList.map((item) => Data.fromJson(item)).toList();
        }
        return [];
      } else {
        print('Gagal mengambil riwayat kehadiran: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print("Error saat mengambil riwayat kehadiran: $e");
      return null;
    }
  }

  // Check out (legacy method - kept for backward compatibility)
  Future<bool> checkOut({
    required double checkOutLat,
    required double checkOutLng,
    required String checkOutAddress,
  }) async {
    final token = await SharedPref.getToken();
    final url = Uri.parse('${Endpoint.baseUrl}/absen/check-out');

    try {
      final now = DateTime.now();

      final String date =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final String time =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final data = {
        "attendance_date": date,
        "check_out": time,
        "check_out_lat": checkOutLat,
        "check_out_lng": checkOutLng,
        "check_out_location": checkOutAddress,
        "check_out_address": checkOutAddress,
      };

      print("Check Out Data: ${jsonEncode(data)}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print("Check Out - Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Gagal Check Out: $e");
      return false;
    }
  }

  // Get attendance statistics
  Future<Map<String, dynamic>?> getAttendanceStats() async {
    final token = await SharedPref.getToken();
    final url = Uri.parse('${Endpoint.baseUrl}/absen/stats');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Get Attendance Stats - Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Gagal mengambil statistik kehadiran: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print("Error saat mengambil statistik kehadiran: $e");
      return null;
    }
  }

  // Submit leave request
  Future<bool> submitLeaveRequest({
    required DateTime leaveDate,
    required String reason,
    required String leaveType,
  }) async {
    final token = await SharedPref.getToken();
    final url = Uri.parse('${Endpoint.baseUrl}/absen/leave');

    try {
      final data = {
        "leave_date":
            "${leaveDate.year.toString().padLeft(4, '0')}-${leaveDate.month.toString().padLeft(2, '0')}-${leaveDate.day.toString().padLeft(2, '0')}",
        "reason": reason,
        "leave_type": leaveType,
      };

      print("Leave Request Data: ${jsonEncode(data)}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print("Submit Leave Request - Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Gagal mengajukan izin: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print("Error saat mengajukan izin: $e");
      return false;
    }
  }
}
