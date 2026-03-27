import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String venueName;
  final String location;
  final String rating;
  final String pricePerHour;
  final String imageUrl;
  final int courtId; 

  const BookingScreen({
    super.key,
    required this.venueName,
    required this.location,
    required this.rating,
    required this.pricePerHour,
    required this.imageUrl,
    this.courtId = 1, 
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final Color primaryColor = const Color(0xFF0d59f2);
  final Color bgColor = const Color(0xFFF5F6F8);

  int selectedDateIndex = 0;
  int selectedDurationIndex = 0;
  String? selectedStartTime;

  bool _isLoading = false;
  List<dynamic> _schedules = [];

  late List<DateTime> dynamicDates;
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final List<String> durations = ['60 min', '120 min'];

  @override
  void initState() {
    super.initState();
    dynamicDates = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() {
      _isLoading = true;
      selectedStartTime = null;
    });

    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
      DateTime selectedDate = dynamicDates[selectedDateIndex];
      String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      final response = await dio.get('/schedules/available?court_id=${widget.courtId}&date=$formattedDate');

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _schedules = response.data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat jadwal. Periksa koneksi internet kamu.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // LOGIKA BARU: TANPA POST API! LANGSUNG PINDAH KE PAYMENT! 🔥
  Future<void> _processBooking() async {
    if (selectedStartTime == null) return;

    // Simpan courtId sementara di memori HP buat diambil sama QrisScreen nanti
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('temp_court_id', widget.courtId);

    DateTime selectedDate = dynamicDates[selectedDateIndex];
    String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    String cleanPrice = widget.pricePerHour.replaceAll(RegExp(r'[^0-9]'), '');
    int basePrice = int.tryParse(cleanPrice) ?? 150000;
    if (widget.pricePerHour.toLowerCase().contains('k') || basePrice < 1000) basePrice *= 1000;
    
    double multiplier = selectedDurationIndex == 0 ? 1.0 : 2.0;
    int currentDuration = selectedDurationIndex == 0 ? 60 : 120;
    int subtotal = (basePrice * multiplier).toInt();
    int serviceFee = 5000;
    int total = subtotal + serviceFee;

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            venueName: widget.venueName,
            imageUrl: widget.imageUrl,
            subtotal: subtotal,
            serviceFee: serviceFee,
            total: total,
            bookingDate: formattedDate,
            startTime: selectedStartTime!,
            duration: currentDuration,
          ),
        ),
      );
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Book Court', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      bottomNavigationBar: _buildBottomPaymentBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            _buildVenueSummaryCard(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSelection(),
                  const SizedBox(height: 32),
                  _buildDurationSelection(),
                  const SizedBox(height: 32),
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: primaryColor))
                      : _buildTimeSlotSelection(),
                  const SizedBox(height: 32),
                  _buildPriceSummary(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(widget.imageUrl, height: 64, width: 64, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(height: 64, width: 64, color: Colors.grey, child: const Icon(Icons.image, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.venueName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(child: Text(widget.location, style: TextStyle(color: Colors.grey.shade500, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text('${widget.rating} ★', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    DateTime selectedDate = dynamicDates[selectedDateIndex];
    String currentMonth = months[selectedDate.month - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('$currentMonth ${selectedDate.year}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(dynamicDates.length, (index) {
              bool isSelected = selectedDateIndex == index;
              DateTime date = dynamicDates[index];
              String dayName = weekDays[date.weekday - 1];

              return GestureDetector(
                onTap: () {
                  setState(() => selectedDateIndex = index);
                  _fetchSchedules();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 64, height: 80,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
                    boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dayName, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text('${date.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: List.generate(durations.length, (index) {
            bool isSelected = selectedDurationIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedDurationIndex = index),
                child: Container(
                  margin: EdgeInsets.only(right: index == 1 ? 0 : 12),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    durations[index],
                    style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? primaryColor : Colors.grey.shade600),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelection() {
    if (_schedules.isEmpty) {
      return const Center(child: Text("Tidak ada jadwal tersedia di tanggal ini.", style: TextStyle(color: Colors.grey)));
    }

    List<dynamic> morning = [];
    List<dynamic> afternoon = [];
    List<dynamic> evening = [];

    for (var sch in _schedules) {
      int hour = int.parse(sch['start_time'].toString().substring(0, 2));
      if (hour < 12) {
        morning.add(sch);
      } else if (hour < 18) {
        afternoon.add(sch);
      } else {
        evening.add(sch);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morning.isNotEmpty) _timeGroup('MORNING', morning),
        if (morning.isNotEmpty) const SizedBox(height: 24),
        if (afternoon.isNotEmpty) _timeGroup('AFTERNOON', afternoon),
        if (afternoon.isNotEmpty) const SizedBox(height: 24),
        if (evening.isNotEmpty) _timeGroup('EVENING', evening),
      ],
    );
  }

  Widget _timeGroup(String title, List<dynamic> schedules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, childAspectRatio: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
          ),
          itemCount: schedules.length,
          itemBuilder: (context, idx) {
            var sch = schedules[idx];
            String timeString = sch['start_time'].toString().substring(0, 5);
            bool isAvailable = sch['is_available'];
            bool isSelected = selectedStartTime == sch['start_time'];

            return GestureDetector(
              onTap: isAvailable ? () => setState(() => selectedStartTime = sch['start_time']) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: !isAvailable ? Colors.grey.shade100 : (isSelected ? primaryColor : Colors.white),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: !isAvailable ? Colors.transparent : (isSelected ? primaryColor : Colors.grey.shade300)),
                  boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: !isAvailable ? Colors.grey.shade400 : (isSelected ? Colors.white : Colors.black87),
                    decoration: !isAvailable ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    if (selectedStartTime == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: const Text(
          'Silakan pilih jam bermain untuk melihat rincian harga.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    String cleanPrice = widget.pricePerHour.replaceAll(RegExp(r'[^0-9]'), '');
    int basePrice = int.tryParse(cleanPrice) ?? 150000;
    if (widget.pricePerHour.toLowerCase().contains('k') || basePrice < 1000) basePrice *= 1000;

    double multiplier = selectedDurationIndex == 0 ? 1.0 : 2.0;
    int subtotal = (basePrice * multiplier).toInt();
    int serviceFee = 5000;
    int total = subtotal + serviceFee;

    String formatRp(int number) {
      return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Court Rental (${durations[selectedDurationIndex]})', style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(formatRp(subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Service Fee', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(formatRp(serviceFee), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(formatRp(total), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPaymentBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: selectedStartTime == null ? null : _processBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: selectedStartTime == null ? 0 : 5,
          ),
          child: Text(
            selectedStartTime == null ? 'Pilih Jam Dulu' : 'Proceed to Payment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: selectedStartTime == null ? Colors.grey.shade600 : Colors.white),
          ),
        ),
      ),
    );
  }
}