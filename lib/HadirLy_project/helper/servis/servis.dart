import 'dart:convert';

import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_register.dart';
import 'package:hadirly/HadirLy_project/helper/sharedpref/pref_api.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<Register?> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse(Endpoint.register);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'jenis_kelamin': jenisKelamin,
          'batch_id': batchId,
          'training_id': trainingId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = registerFromJson(response.body);
        if (result.data?.token != null) {
          await SharedPref.saveToken(result.data!.token!);
        }

        return result;
      } else {
        print('Register failed: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }
}
