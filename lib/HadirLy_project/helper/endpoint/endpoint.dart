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
}
