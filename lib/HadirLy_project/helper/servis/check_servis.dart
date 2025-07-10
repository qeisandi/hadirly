import 'dart:convert';

import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_cekin.dart';
import 'package:hadirly/HadirLy_project/helper/sharedpref/pref_api.dart';
import 'package:http/http.dart' as http;

class CheckServis {
  Future<bool> postCheckIn(CheckInGet data) async {
    final token = await SharedPref.getToken();
    final url = Uri.parse(Endpoint.checkIn);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data.toJson()),
      );

      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Gagal Check In: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print("Error saat Check In: $e");
      return false;
    }
  }
}
