class Endpoint {
  static const baseUrl = "https://appabsensi.mobileprojp.com/api";

  // LOGIN & REGISTER
  static const register = '$baseUrl/register';
  static const login = '$baseUrl/login';

  // Get Batch
  static const batch = '$baseUrl/batches';
  static const kejuruan = '$baseUrl/trainings';

  // Profile
  static const getProfile = '$baseUrl/profile';
  static const updateProfile = '$baseUrl/profile';

  // Attendance
  static const checkIn = '$baseUrl/absen/check-in';

  // Absen
  static const postCheckOut = '$baseUrl/absen/check-out';

  //photo profile
  static const photoProfile = '$baseUrl/profile/photo';

  //History
  static const history = '$baseUrl/absen/history';

  //Statistik
  static const getStatistik = '$baseUrl/absen/stats';

  //Izin
  static const izin = '$baseUrl/izin';
}
