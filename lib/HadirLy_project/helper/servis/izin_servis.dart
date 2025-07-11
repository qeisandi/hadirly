import 'dart:convert';

import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_izin.dart';
import 'package:hadirly/HadirLy_project/helper/sharedpref/pref_api.dart';
import 'package:http/http.dart' as http;

class IzinService {
  Future<Perizinan?> postIzin({required String alasanIzin}) async {
    try {
      final token = await SharedPref.getToken();

      final response = await http.post(
        Uri.parse(Endpoint.izin),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"alasan_izin": alasanIzin}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return perizinanFromJson(response.body);
      } else {
        print("Gagal mengirim izin: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error saat post izin: $e");
      return null;
    }
  }
}
