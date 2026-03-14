import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../config/api_config.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl, 
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  // ==========================================
  // FUNGSI LOGIN
  // ==========================================
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: FormData.fromMap({
          'username': username, 
          'password': password,
        }),
      );

      print('=== RESPONS SUKSES LOGIN DARI CI4 ===');
      print(response.data);

      if (response.statusCode == 200 && response.data is Map && response.data['status'] == 200) {
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var userData = response.data['data']; // Tangkap array data dari CI4

        // SIMPAN SEMUA DATA ASLI KE MEMORI HP
        await prefs.setInt('userId', int.parse(userData['id'].toString()));
        await prefs.setString('userName', userData['full_name']); 
        await prefs.setString('userEmail', userData['email']);

        return true;
      }
      return false;
      
    } on DioException catch (e) {
      print('=== DIO ERROR LOGIN ===');
      print('Status Code: ${e.response?.statusCode}');
      print('Isi Pesan: ${e.response?.data}');
      return false;
    } catch (e) {
      print('=== FATAL ERROR LOGIN ===');
      print('Detail Error: $e');
      return false;
    }
  }

  // ==========================================
  // FUNGSI REGISTER
  // ==========================================
  Future<bool> register(String name, String username, String email, String password) async {
    try {
      final response = await _dio.post(
        '/register',
        data: FormData.fromMap({
          'full_name': name,          // Mengirimkan Full Name
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('=== RESPONS SUKSES REGISTER DARI CI4 ===');
      print(response.data);

      // Backend terkadang merespon dengan status 201 (Created) saat insert data baru sukses
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data is Map) {
        if (response.data['status'] == 200 || response.data['status'] == 201) {
          return true;
        }
      }
      return false;
      
    } on DioException catch (e) {
      print('=== DIO ERROR REGISTER ===');
      print('Status Code: ${e.response?.statusCode}');
      print('Isi Pesan: ${e.response?.data}');
      return false;
    } catch (e) {
      print('=== FATAL ERROR REGISTER ===');
      print('Detail Error: $e');
      return false;
    }
  }

  // ==========================================
  // FUNGSI UPDATE PROFILE
  // ==========================================
  Future<bool> updateProfile(String fullName, String email) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? 0; // Ambil ID asli yang lagi login

      final response = await _dio.post(
        '/profile/update',
        data: FormData.fromMap({
          'user_id': userId, // Kirim ID asli ke CI4
          'full_name': fullName,
          'email': email,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error update profile: $e');
      return false;
    }
  }

  // ==========================================
  // FUNGSI UPDATE PASSWORD
  // ==========================================
  Future<bool> updatePassword(String newPassword) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? 0; // Ambil ID asli yang lagi login

      final response = await _dio.post(
        '/password/update',
        data: FormData.fromMap({
          'user_id': userId, // Kirim ID asli ke CI4
          'new_password': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error update password: $e');
      return false;
    }
  }
}