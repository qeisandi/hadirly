import 'dart:convert';
import 'dart:io';

import 'package:hadirly/HadirLy_project/helper/model/model_profile_photo.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePhotoService {
  static const String _endpoint =
      'https://appabsensi.mobileprojp.com/api/profile';
  static const String _photoEndpoint =
      'https://appabsensi.mobileprojp.com/api/profile/photo';

  Future<ProfilePhotoResponse?> fetchProfilePhoto({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return profilePhotoResponseFromJson(response.body);
      } else {
        print('Gagal mengambil profile photo: \\${response.statusCode}');
        print('Body: \\${response.body}');
        return null;
      }
    } catch (e) {
      print('Error mengambil profile photo: \\${e.toString()}');
      return null;
    }
  }

  Future<ProfilePhotoUploadData?> photoProfile({
    required File imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUri = 'data:image/png;base64,$base64Image';
      final response = await http.put(
        Uri.parse(_photoEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'profile_photo': dataUri}),
      );
      if (response.statusCode == 200) {
        final uploadResponse = ProfilePhotoUploadResponse.fromJson(
          json.decode(response.body),
        );
        return uploadResponse.data;
      } else {
        print('Gagal upload profile photo: \\${response.statusCode}');
        print('Body: \\${response.body}');
        return null;
      }
    } catch (e) {
      print('Error upload profile photo: \\${e.toString()}');
      return null;
    }
  }
}
