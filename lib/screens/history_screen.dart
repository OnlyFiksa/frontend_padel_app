import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'order_detail_screen.dart'; // IMPORT BARU BIAR BISA PINDAH HALAMAN! 🔥

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryColor = const Color(0xFF0d59f2);
  final Color bgColor = const Color(0xFFF5F6F8);

  bool _isLoading = true;
  List<dynamic> _bookings = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  // FUNGSI NARIK DATA DARI CI4 (KODE LEBIH PENDEK & LEBIH CEPAT!)
  Future<void> _fetchHistoryData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? 1; 

      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
      ));

      final response = await dio.get('/bookings/user/$userId');

      if (response.statusCode == 200) {
        // KARENA DATABASE UDAH PINTAR, KITA LANGSUNG AMBIL DATANYA TANPA DI-GROUP! 🔥
        List<dynamic> rawData = response.data['data'] ?? [];

        if (mounted) {
          setState(() {
            _bookings = rawData;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal mengambil data riwayat. Cek koneksi server.';
          _isLoading = false;
        });
        print("Error fetch history: $e");
      }
    }
  }

  String formatRp(dynamic number) {
    int num = int.tryParse(number.toString()) ?? 0;
    return 'Rp ${num.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('My Bookings', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
            TextButton(onPressed: _fetchHistoryData, child: const Text('Coba Lagi'))
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Belum ada riwayat pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Yuk booking lapangan pertamamu sekarang!", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        bool isActive = booking['status'] == 'Active';
        
        // Ambil durasi matang dari database yang udah kita benerin! (Bug 3 Solved)
        int durationMinutes = int.tryParse(booking['duration'].toString()) ?? 60; 

        // BUNGKUS PAKAI INKWELL BIAR BISA DIKLIK! 🚀
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(
                  // Sesuaikan data yang dilempar dengan yang diminta OrderDetailScreen
                  orderData: {
                    'title': booking['venue_name'] ?? 'Padel Venue',
                    'date': booking['booking_date'],
                    'time': booking['start_time'],
                    'order_id': booking['order_id'],
                    'status': booking['status'],
                    'total_amount': booking['total_amount'],
                    'duration': durationMinutes,
                  },
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(booking['order_id'] ?? 'INV-XXX', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Text(
                          booking['status'] ?? 'Unknown',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.red),
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        height: 60, width: 60,
                        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.sports_tennis, color: primaryColor, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking['venue_name'] ?? 'Padel Venue', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Court ${booking['court_number'] ?? '-'}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(booking['booking_date'] ?? 'Tanggal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 12),
                                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('${booking['start_time'].toString().substring(0, 5)} ($durationMinutes Min)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      // KARENA DATABASE UDAH BENAR, HARGA DI SINI 100% SAMA DENGAN YANG DIBAYAR!
                      Text(formatRp(booking['total_amount']), style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}