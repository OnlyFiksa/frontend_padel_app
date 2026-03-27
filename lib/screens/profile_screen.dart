import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../config/api_config.dart';
import 'login_screen.dart'; 
import 'edit_profile_screen.dart'; 
import 'history_screen.dart'; // IMPORT HISTORY SCREEN!
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryColor = const Color(0xFF0d59f2); 
  
  String _fullName = "Memuat...";
  String? _imagePath;
  
  // STATISTIK DINAMIS! 🔥
  String _totalBookings = "0";
  String _totalHours = "0";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchProfileStats(); // Panggil API Statistik!
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('userName') ?? 'Pemain Padel'; 
      _imagePath = prefs.getString('profileImagePath'); 
    });
  }

  // FUNGSI PENARIK STATISTIK DARI CI4!
  Future<void> _fetchProfileStats() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? 1;

      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
      ));

      final response = await dio.get('/profile/stats/$userId');

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _totalBookings = response.data['data']['total_bookings'].toString();
            _totalHours = response.data['data']['total_hours'].toString();
          });
        }
      }
    } catch (e) {
      print("Error fetch profile stats: $e");
    }
  }

  // 🔥 FUNGSI UBAH PASSWORD BEBAS BUG (ANTI-CRASH) 🔥
  void _showChangePasswordDialog() {
    // Controller Password Baru & Lama
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController oldPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) { // Bedakan nama context-nya biar gak bentrok
        bool obscureOld = true;
        bool obscureNew = true;
        return StatefulBuilder(
          builder: (stateContext, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController, 
                    obscureText: obscureOld,
                    decoration: InputDecoration(
                      hintText: 'Password Lama',
                      filled: true, fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => obscureOld = !obscureOld),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController, 
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      hintText: 'Password Baru',
                      filled: true, fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String realNewPassword = newPasswordController.text;

                    if (realNewPassword.isEmpty || realNewPassword.length < 6) {
                      ScaffoldMessenger.of(stateContext).showSnackBar(
                        const SnackBar(content: Text('Password baru minimal 6 karakter!'), backgroundColor: Colors.red)
                      );
                      return; 
                    }

                    // 🔥 TANGKAP KURIR NOTIFIKASI SEBELUM DIALOG DITUTUP 🔥
                    final messenger = ScaffoldMessenger.of(context); 
                    
                    // SEKARANG BARU BOLEH TUTUP DIALOG
                    Navigator.pop(dialogContext); 

                    // PROSES API
                    AuthService authService = AuthService();
                    bool isSuccess = await authService.updatePassword(realNewPassword); 

                    // TAMPILKAN NOTIFIKASI PAKAI KURIR YANG SUDAH DITANGKAP
                    if (isSuccess) {
                      messenger.showSnackBar(const SnackBar(content: Text('Password berhasil diubah di database!'), backgroundColor: Colors.green));
                    } else {
                      messenger.showSnackBar(const SnackBar(content: Text('Gagal mengubah password.'), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin nih mau keluar dari akun kamu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), 
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: _imagePath != null 
                          ? ClipOval(child: Image.file(File(_imagePath!), fit: BoxFit.cover)) 
                          : const Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Upload Foto belum aktif'))),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                            child: const Icon(Icons.photo_camera, color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [Text(_totalBookings, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)), const SizedBox(height: 4), const Text('Total Booking', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600))]),
                    Container(height: 40, width: 1, color: Colors.grey.shade200),
                    Column(children: [Text('$_totalHours Jam', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)), const SizedBox(height: 4), const Text('Total Bermain', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600))]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuOption(Icons.person_outline, 'Ubah Profile', onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                    _loadUserData(); 
                  }),
                  _buildMenuOption(Icons.lock_outline, 'Ubah Password', onTap: _showChangePasswordDialog),
                  
                  // 🔥 RIWAYAT TRANSAKSI AKTIF! 🔥
                  _buildMenuOption(Icons.history, 'Riwayat Transaksi', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
                  }),
                  
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFF0F0F0), height: 1),
                  const SizedBox(height: 24),
                  ListTile(
                    onTap: _handleLogout, 
                    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle), child: const Icon(Icons.logout, color: Colors.redAccent, size: 24)),
                    title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)), child: Icon(icon, color: Colors.grey.shade700, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Colors.white,
      ),
    );
  }
}