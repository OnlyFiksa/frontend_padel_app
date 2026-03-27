import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'qris_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String venueName;
  final String imageUrl;
  final int subtotal;
  final int serviceFee;
  final int total;
  final String bookingDate;
  final String startTime;
  final int duration;

  const PaymentScreen({
    super.key,
    required this.venueName,
    required this.imageUrl,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
    required this.bookingDate,
    required this.startTime,
    required this.duration,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Color primaryColor = const Color(0xFF0d59f2);
  final Color bgColor = const Color(0xFFF5F6F8);

  final TextEditingController _promoController = TextEditingController();
  bool isPromoApplied = false;
  bool _isVerifyingPromo = false;
  bool _isAutoPromo = false; 
  int discountAmount = 0;
  late int finalTotal;

  @override
  void initState() {
    super.initState();
    finalTotal = widget.total;
    _checkAutoPromo(); // Panggil pengecekan promo saat halaman dibuka!
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // 🔥 INI DIA FUNGSI YANG BIKIN PROMO OTOMATIS JALAN! 🔥
  Future<void> _checkAutoPromo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Tarik data yang udah diset sama Dashboard
    bool isPromoClaimed = prefs.getBool('isPromoClaimed') ?? false; 
    bool isPromoUsed = prefs.getBool('isPromoUsed') ?? false;       

    // Kalau udah diklaim & belum dipakai bayar -> SIKAT DISKONNYA!
    if (isPromoClaimed && !isPromoUsed) {
      int discount = (widget.subtotal * 0.20).toInt(); // Diskon 20%
      
      setState(() {
        _isAutoPromo = true;
        isPromoApplied = true;
        discountAmount = discount;
        finalTotal = widget.subtotal + widget.serviceFee - discount;
        _promoController.text = 'NEW20'; 
      });
    }
  }

  // FUNGSI KETIK PROMO MANUAL (Jaga-jaga kalau dia nggak klik claim di dashboard)
  Future<void> _applyPromoCode() async {
    String code = _promoController.text.trim();
    if (code.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isPromoUsed = prefs.getBool('isPromoUsed') ?? false;

    if (isPromoUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maaf, Promo NEW20 hanya bisa digunakan 1x untuk pengguna baru!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        )
      );
      _promoController.clear();
      return; 
    }

    setState(() {
      _isVerifyingPromo = true;
    });

    try {
      int userId = prefs.getInt('userId') ?? 0;
      final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
      final response = await dio.post('/promos/apply', data: {
        'user_id': userId,
        'promo_code': code,
      });

      if (response.statusCode == 200) {
        int discountPercentage = response.data['data']['discount_percentage'];

        setState(() {
          isPromoApplied = true;
          discountAmount = (widget.subtotal * (discountPercentage / 100)).toInt();
          finalTotal = widget.subtotal + widget.serviceFee - discountAmount;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(response.data['message']),
              backgroundColor: Colors.green));
        }
      }
    } on DioException catch (e) {
      String errorMessage = "Gagal memverifikasi promo.";
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
        _promoController.clear();
      }
    } catch (e) {
      debugPrint("Error Promo: $e");
    } finally {
      if (mounted) setState(() {_isVerifyingPromo = false;});
    }
  }

  String formatRp(int number) {
    return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Payment',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      bottomNavigationBar: _buildBottomPayButton(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(),
            const SizedBox(height: 24),
            // Banner otomatis jika promo udah diklaim di dashboard
            if (_isAutoPromo) _buildAutoPromoBanner(),
            if (!_isAutoPromo) _buildPromoSection(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            _buildPriceDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ORDER SUMMARY',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                    color: primaryColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]),
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(widget.imageUrl,
                      height: 80, width: 80, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(height: 80, width: 80, color: Colors.grey))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('PADEL COURT',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryColor))),
                    const SizedBox(height: 8),
                    Text(widget.venueName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.2)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.calendar_today,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(widget.bookingDate,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey))
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.schedule, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${widget.startTime.substring(0, 5)} WIB',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey))
                    ]),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAutoPromoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade300, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.green.shade100, shape: BoxShape.circle),
            child: Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Promo NEW20 Otomatis Diterapkan! 🎉',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.green.shade800)),
                const SizedBox(height: 2),
                Text('Diskon 20% dari promo yang kamu klaim berhasil dipotong.',
                    style:
                        TextStyle(fontSize: 12, color: Colors.green.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PROMO PENGGUNA BARU',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: isPromoApplied
                        ? Colors.green.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isPromoApplied
                            ? Colors.green
                            : Colors.grey.shade300)),
                child: TextField(
                  controller: _promoController,
                  enabled: !isPromoApplied && !_isVerifyingPromo,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Ketik: NEW20',
                    hintStyle: TextStyle(
                        color:
                            isPromoApplied ? Colors.green : Colors.grey,
                        fontSize: 14,
                        fontWeight: isPromoApplied
                            ? FontWeight.bold
                            : FontWeight.normal),
                    prefixIcon: Icon(Icons.local_offer_outlined,
                        color: isPromoApplied ? Colors.green : Colors.grey,
                        size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: (isPromoApplied ||
                      _isVerifyingPromo ||
                      _promoController.text.isEmpty)
                  ? null
                  : _applyPromoCode,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isPromoApplied ? Colors.grey.shade300 : primaryColor,
                minimumSize: const Size(80, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isVerifyingPromo
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(isPromoApplied ? 'Applied' : 'Apply',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPromoApplied
                              ? Colors.grey
                              : Colors.white)),
            )
          ],
        )
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PAYMENT METHOD',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor, width: 2),
              boxShadow: [
                BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]),
          child: Row(
            children: [
              Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)),
                  alignment: Alignment.center,
                  child: const Icon(Icons.qr_code_scanner,
                      color: Color(0xFF0d59f2), size: 28)),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('QRIS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Pay with any E-Wallet or Bank App',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12))
                  ])),
              Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                      color: primaryColor, shape: BoxShape.circle),
                  child:
                      const Icon(Icons.check, color: Colors.white, size: 16))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PRICE DETAILS',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Court Booking Fee',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(formatRp(widget.subtotal),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),

          if (isPromoApplied) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Promo NEW20 (20%)',
                        style:
                            TextStyle(color: Colors.green, fontSize: 14)),
                    const SizedBox(width: 6),
                    if (_isAutoPromo)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade300)),
                        child: Text('AUTO',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700)),
                      ),
                  ],
                ),
                Text('- ${formatRp(discountAmount)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green)),
              ],
            ),
          ],

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Service Fee',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(formatRp(widget.serviceFee),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(formatRp(finalTotal),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPayButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ]),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // LEMPAR HARGA FINAL KE QRIS (Sudah dikurang diskon!)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QrisScreen(
                  venueName: widget.venueName,
                  imageUrl: widget.imageUrl,
                  total: finalTotal, // <--- INI PENTING: Harga yang dikirim ke QRIS udah dipotong diskon!
                  bookingDate: widget.bookingDate,
                  startTime: widget.startTime,
                  duration: widget.duration, 
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              shadowColor: primaryColor.withOpacity(0.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Pay Now • ${formatRp(finalTotal)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}