import 'dart:convert';
import 'dart:io';

import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_eror.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_photo_pro.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_profile.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_register.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_update.dart';
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

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        return registerFromJson(response.body).toJson();
      } else if (response.statusCode == 422) {
        return errorParamsFromJson(response.body).toJson();
      } else if (response.statusCode == 404) {
        return {
          "errors": true,
          "message": "email tidak terdaftar atau password salah",
        };
      } else {
        print("Maaf Tidak Bisa Login User:  [33m${response.statusCode} [0m");
        throw Exception("Gagal Untuk login User: ${response.statusCode}");
      }
    } catch (e) {
      print("Login error: $e");
      throw Exception("Login error: $e");
    }
  }

  Future<GetProfile?> getProfile(String token) async {
    final url = Uri.parse(Endpoint.getProfile);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return GetProfile.fromJson(jsonResponse);
      } else {
        print("Gagal mengambil profil: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error saat mengambil profil: $e");
      return null;
    }
  }

  Future<UpdateProfile> updateProfile({required String name}) async {
    try {
      final token = await SharedPref.getToken();

      final response = await http.put(
        Uri.parse(Endpoint.updateProfile),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode != 200) {
        throw Exception("Gagal update profile: ${response.statusCode}");
      }

      return UpdateProfile.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception("Update profile gagal: $e");
    }
  }

  Future<PhotoProfile> photoProfile({File? imageFile}) async {
    try {
      final token = await SharedPref.getToken();
      final uri = Uri.parse(Endpoint.photoProfile);

      String? base64Image;
      String? imageName;

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        base64Image = base64Encode(bytes);
        imageName = imageFile.path.split("/").last;
      }
      final body = {
        if (base64Image != null && imageName != null) ...{
          "profile_photo": base64Image,
          "image_name": imageName,
        },
      };

      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("Upload Photo Profile - Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal update photo profile. Status: ${response.statusCode}. Body: ${response.body}',
        );
      }

      final json = jsonDecode(response.body);
      return PhotoProfile.fromJson(json);
    } catch (e) {
      throw Exception("Update photo profile gagal: $e");
    }
  }

  Future<PhotoProfile?> getPhotoProfile() async {
    try {
      final token = await SharedPref.getToken();
      final uri = Uri.parse(Endpoint.photoProfile);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("Get Photo Profile - Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PhotoProfile.fromJson(json);
      } else {
        print("Gagal mengambil photo profile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error saat mengambil photo profile: $e");
      return null;
    }
  }
}
