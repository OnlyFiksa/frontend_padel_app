import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../config/api_config.dart';
import 'success_screen.dart';

class QrisScreen extends StatefulWidget {
  final String venueName;
  final String imageUrl;
  final int total;
  final String bookingDate;
  final String startTime;
  final int duration;

  const QrisScreen({
    super.key,
    required this.venueName,
    required this.imageUrl,
    required this.total,
    required this.bookingDate,
    required this.startTime,
    required this.duration,
  });

  @override
  State<QrisScreen> createState() => _QrisScreenState();
}

class _QrisScreenState extends State<QrisScreen> {
  final Color primaryColor = const Color(0xFF0d59f2);
  final Color bgColor = const Color(0xFFF5F6F8);

  bool _isProcessing = true;
  String _loadingText = 'Waiting for payment...';

  Timer? _paymentTimer;
  int _countdown = 5;

  @override
  void initState() {
    super.initState();
    _startPaymentSimulation();
  }

  @override
  void dispose() {
    _paymentTimer?.cancel();
    super.dispose();
  }

  Future<void> _startPaymentSimulation() async {
    _paymentTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _countdown--;

      if (_countdown <= 0) {
        timer.cancel();
        setState(() => _loadingText = 'Confirming payment...');
        await _confirmPayment();
      } else {
        setState(() => _loadingText = 'Waiting for payment... ($_countdown)');
      }
    });
  }

  // LOGIKA BARU: Tembak API Create Booking DI SINI! 🔥
  Future<void> _confirmPayment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? 0;
      int courtId = prefs.getInt('temp_court_id') ?? 1; // Tarik data courtId dari jembatan

      if (userId == 0) {
        _showErrorDialog('Sesi kamu habis. Silakan login ulang.');
        return;
      }

      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
      ));

      // EKSEKUSI API BOOKING & HANGUSKAN PROMO!
      final response = await dio.post('/bookings', data: {
        'user_id': userId,
        'court_id': courtId,
        'booking_date': widget.bookingDate,
        'start_time': widget.startTime,
        'duration': widget.duration,
        'total_amount': widget.total, // HARGA FINAL SETELAH DISKON!
      });

      if (response.statusCode == 201 && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              venueName: widget.venueName,
              imageUrl: widget.imageUrl,
              totalPaid: widget.total,
            ),
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Terjadi kesalahan koneksi ke server.';
      if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? 'Ditolak oleh server.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan sistem di aplikasi.');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    setState(() => _isProcessing = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran Gagal',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = true;
                _countdown = 5;
                _loadingText = 'Waiting for payment...';
              });
              _startPaymentSimulation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String formatRp(int number) {
    return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Scan to Pay',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Total Payment',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                formatRp(widget.total),
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 32),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset('assets/qris.jpg',
                        height: 250, width: 250, fit: BoxFit.contain),
                    const SizedBox(height: 24),
                    const Text(
                      'Scan this QR Code using any E-Wallet or Mobile Banking App',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              if (_isProcessing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            color: primaryColor, strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text(_loadingText,
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}