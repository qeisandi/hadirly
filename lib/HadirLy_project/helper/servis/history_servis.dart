import 'package:hadirly/HadirLy_project/helper/endpoint/endpoint.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_history.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_stat.dart';
import 'package:hadirly/HadirLy_project/helper/sharedpref/pref_api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  Future<HistoryAttend?> fetchHistoryAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(Endpoint.history),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return historyAttendFromJson(response.body);
      } else {
        print("Gagal get history: ${response.statusCode}");
        print("Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error get history: $e");
      return null;
    }
  }

  Future<StatistikAttend?> getStatistikAttend() async {
    try {
      final token = await SharedPref.getToken();
      final url = Uri.parse(Endpoint.getStatistik);
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("Statistik - Status Code: ${response.statusCode}");
      print("Statistik - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return statistikAttendFromJson(response.body);
      } else {
        print("Gagal mengambil statistik: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error saat mengambil statistik: $e");
      return null;
    }
  }

  Future<bool> deleteHistoryAttendance(int historyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('${Endpoint.deleteHistory}/$historyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("Delete History - Status Code: ${response.statusCode}");
      print("Delete History - Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print("Gagal menghapus history: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error saat menghapus history: $e");
      return false;
    }
  }
}
