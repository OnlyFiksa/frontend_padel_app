import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailScreen({super.key, required this.orderData});

  final Color primaryColor = const Color(0xFF0d59f2);
  final Color bgColor = const Color(0xFFF5F6F8);
  final Color successColor = const Color(0xFF10b981);

  String formatRp(dynamic number) {
    if (number == null) return 'Rp 0';
    int num = int.tryParse(number.toString()) ?? 0;
    return 'Rp ${num.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 BACA DATA ASLI DARI DATABASE 🔥
    String venueName = orderData['title'] ?? 'Padel Venue';
    String courtName = 'Padel Court (Indoor)'; // Bisa ditambahin ke API kalau butuh
    String bookingDate = orderData['date'] ?? '-';
    String startTime = orderData['time'] != null ? orderData['time'].toString().substring(0, 5) : '-';
    int duration = int.tryParse(orderData['duration']?.toString() ?? '60') ?? 60;
    
    int totalAmount = int.tryParse(orderData['total_amount']?.toString() ?? '0') ?? 0;
    int serviceFee = 5000;
    int subtotal = totalAmount - serviceFee; // Hitung mundur buat nyari harga awal
    if (subtotal < 0) subtotal = 0;

    String orderId = orderData['order_id'] ?? 'TRX-UNKNOWN';
    String status = orderData['status'] ?? 'Active';
    bool isActive = status.toLowerCase() == 'active' || status.toLowerCase() == 'completed';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Pesanan', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive ? successColor.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isActive ? successColor.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(isActive ? Icons.qr_code_2 : Icons.cancel, color: isActive ? successColor : Colors.red, size: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isActive ? 'Pembayaran Berhasil' : 'Pesanan Dibatalkan', 
                          style: TextStyle(color: isActive ? successColor : Colors.red, fontWeight: FontWeight.bold)),
                        Text(isActive ? 'Dibayar via QRIS Dinamis' : 'Status: Cancelled', 
                          style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Text(status.toUpperCase(), 
                    style: TextStyle(color: isActive ? successColor : Colors.red, fontWeight: FontWeight.w900, fontSize: 10)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Informasi Lapangan', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            // Info Card
            _buildInfoCard(
              icon: Icons.location_on_outlined,
              title: venueName,
              subtitle: courtName,
            ),
            _buildInfoCard(
              icon: Icons.event_available_outlined,
              title: bookingDate,
              subtitle: '$startTime WIB ($duration Menit)',
            ),

            const SizedBox(height: 24),
            const Text('Rincian Pembayaran', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            // Ringkasan Transaksi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _rowBiaya('Sewa Lapangan', formatRp(subtotal)),
                  _rowBiaya('Biaya Layanan', formatRp(serviceFee)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(formatRp(totalAmount), 
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text('ID Transaksi: $orderId', 
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    height: 1, width: 40, color: Colors.grey.shade300,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _rowBiaya(String label, String harga) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(harga, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}