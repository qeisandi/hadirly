import 'dart:convert';

import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_training.dart';
import 'package:http/http.dart' as http;

class TrainingService {
  Future<List<Trainings>> ambilTrainings() async {
    final url = Uri.parse(Endpoint.kejuruan);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final result = GetTrainings.fromJson(jsonResponse);
        return result.data ?? [];
      } else {
        throw Exception(
          'Gagal mengambil data training: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat fetch training: $e');
    }
  }
}
