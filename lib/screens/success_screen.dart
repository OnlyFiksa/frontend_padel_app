import 'package:flutter/material.dart';
import 'main_screen.dart'; // Biar bisa balik ke menu utama yang ada navbar bawahnya

class SuccessScreen extends StatelessWidget {
  final String venueName;
  final String imageUrl;
  final int totalPaid;

  const SuccessScreen({
    super.key,
    required this.venueName,
    required this.imageUrl,
    required this.totalPaid,
  });

  String formatRp(int number) {
    return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF0d59f2);
    final Color bgColor = const Color(0xFFF5F6F8);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tombol Close di atas
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    // FIX: Diganti jadi MainScreen()
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Icon Check Sukses
              Container(
                height: 80, width: 80,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 24),
              const Text('Booking Confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
              const SizedBox(height: 8),
              const Text("Everything is set! You're ready to hit the court.", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),

              // Card Detail Booking
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BOOKING DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.5)),
                          const SizedBox(height: 4),
                          Text(venueName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          
                          _detailRow(Icons.location_on, 'Venue & Court', 'Court #4 • Premium Indoor', primaryColor),
                          const SizedBox(height: 12),
                          _detailRow(Icons.calendar_today, 'Date', 'Tuesday, 14 Oct 2026', primaryColor),
                          const SizedBox(height: 12),
                          _detailRow(Icons.schedule, 'Time', '14:30 - 16:00 (90 mins)', primaryColor),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Booking ID', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text('#PP-88291', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Amount Paid', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(formatRp(totalPaid), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Back to Home
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // FIX: Diganti jadi MainScreen()
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value, Color primaryColor) {
    return Row(
      children: [
        Container(
          height: 32, width: 32,
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: primaryColor, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }
}