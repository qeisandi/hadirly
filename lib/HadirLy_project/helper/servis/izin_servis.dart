import 'dart:convert';

import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_izin.dart';
import 'package:hadirly/HadirLy_project/helper/sharedpref/pref_api.dart';
import 'package:http/http.dart' as http;

class IzinService {
  Future<Perizinan?> postIzin({
    required String alasanIzin,
    DateTime? tanggalIzin,
  }) async {
    try {
      final token = await SharedPref.getToken();

      if (token == null) {
        print("Token tidak ditemukan");
        return null;
      }

      final tanggal = (tanggalIzin ?? DateTime.now());
      final tanggalStr =
          "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}";
      print("Mengirim izin dengan alasan: $alasanIzin");
      print("Tanggal izin: $tanggalStr");
      print("Endpoint: ${Endpoint.izin}");

      final response = await http.post(
        Uri.parse(Endpoint.izin),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({"alasan_izin": alasanIzin, "date": tanggalStr}),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final result = perizinanFromJson(response.body);
          print("Izin berhasil diproses: ${result.message}");
          return result;
        } catch (parseError) {
          print("Error parsing response: $parseError");
          return null;
        }
      } else {
        print("Gagal mengirim izin: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error saat post izin: $e");
      return null;
    }
  }
}
