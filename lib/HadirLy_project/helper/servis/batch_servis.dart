import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_batch.dart';

class BatchServis {
Future<List<BatchData>> ambilBatch() async {
  final url = Uri.parse(Endpoint.batch);

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final result = BatchResponse.fromJson(jsonResponse);
      return result.data ?? [];
    } else {
      throw Exception('Gagal mengambil data batch: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan saat fetch batch: $e');
  }
}
}
