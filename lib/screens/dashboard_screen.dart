import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'notification_screen.dart';
import 'venue_detail_screen.dart';
import 'order_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryColor = const Color(0xFF0d59f2);
  final Color bgColor = const Color(0xFFF5F6F8);

  bool _isLoading = true;
  String _userName = "Pemain";
  List<dynamic> _upcomingMatches = [];
  List<dynamic> _featuredVenues = [];

  // STATE PROMO 
  bool _isPromoUsed = false;    // True = Udah bayar pake promo (Banner Hilang)
  bool _isPromoClaimed = false; // True = Udah klik claim (Teks Dicoret)

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? 1;
      String savedName = prefs.getString('userName') ?? "Pemain";

      final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
      final response = await dio.get('/dashboard?user_id=$userId');

      if (response.statusCode == 200) {
        // 🔥 SINKRONISASI MUTLAK: DATABASE -> MEMORI HP 🔥
        bool hasUsedPromoApi = response.data['data']['has_used_promo'] ?? false;
        
        // Paksa memori HP ngikutin status dari Database!
        await prefs.setBool('isPromoUsed', hasUsedPromoApi);

        // Kalau dari database ketahuan udah pernah pakai promo, hanguskan status claim-nya
        if (hasUsedPromoApi) {
          await prefs.setBool('isPromoClaimed', false);
        }

        // Baru kita baca status claim yang valid
        bool promoClaimed = prefs.getBool('isPromoClaimed') ?? false;

        // --- LOGIKA FILTER JADWAL MASA LALU ---
        List<dynamic> rawMatches = response.data['data']['upcoming_matches'] ?? [];
        DateTime now = DateTime.now();
        
        List<dynamic> validMatches = rawMatches.where((match) {
          try {
            DateTime matchDate = DateTime.parse("${match['date']} ${match['time']}");
            return matchDate.isAfter(now); 
          } catch (e) {
            return true; 
          }
        }).toList();
        // --------------------------------------

        if (mounted) {
          setState(() {
            _userName = response.data['data']['user_name'] ?? savedName;
            _upcomingMatches = validMatches; 
            _featuredVenues = response.data['data']['featured_venues'] ?? [];
            
            _isPromoUsed = hasUsedPromoApi; // Pakai data API yang paling akurat!
            _isPromoClaimed = promoClaimed;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetch dashboard: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // LOGIKA KLAIM PROMO YANG BENAR
  Future<void> _claimPromo() async {
    if (_isPromoClaimed) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPromoClaimed', true); 

    setState(() {
      _isPromoClaimed = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode Promo NEW20 Berhasil Diklaim! Gunakan saat bayar ya.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('WELCOME BACK',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5)),
                            const SizedBox(height: 4),
                            Text('Hello, $_userName! 👋',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationScreen()),
                            );
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: Icon(Icons.notifications_outlined,
                                color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TAMPILKAN BANNER HANYA JIKA BELUM DIPAKAI BAYAR (USED)
                  if (!_isPromoUsed) _buildPromoBanner(),
                  if (!_isPromoUsed) const SizedBox(height: 32),

                  // TIKET UPCOMING MATCH
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Text('Your Next Match',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                  ),
                  const SizedBox(height: 16),
                  _buildTicketCard(),

                  const SizedBox(height: 32),

                  // FEATURED VENUES
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Featured Venues',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Text('See All',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeaturedVenues(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isPromoClaimed
              ? [Colors.grey.shade500, Colors.grey.shade600] 
              : [primaryColor, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: (_isPromoClaimed ? Colors.grey : primaryColor).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4)),
                child: const Text('SUMMER PRO LEAGUE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
              const SizedBox(height: 12),

              Text(
                'Get 20% Off Bookings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: _isPromoClaimed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: Colors.white,
                  decorationThickness: 2.5,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                'Kode: NEW20',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: _isPromoClaimed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: Colors.white,
                  decorationThickness: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Book any court this weekend and save on your next match.',
                style: TextStyle(
                  color: _isPromoClaimed ? Colors.white54 : Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isPromoClaimed ? null : _claimPromo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPromoClaimed ? Colors.white30 : Colors.white,
                  foregroundColor: _isPromoClaimed ? Colors.white60 : primaryColor,
                  disabledBackgroundColor: Colors.white30,
                  disabledForegroundColor: Colors.white60,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                ),
                child: Text(
                  _isPromoClaimed ? '✓ Promo Sudah Diklaim' : 'Claim Offer',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Positioned(
            right: -20,
            bottom: -30,
            child: Icon(Icons.sports_tennis,
                size: 120, color: Colors.white.withOpacity(0.1)),
          )
        ],
      ),
    );
  }

  Widget _buildTicketCard() {
    if (_upcomingMatches.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200)),
        child: const Center(
            child: Text("Belum ada jadwal main nih.\nYuk booking sekarang!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey))),
      );
    }

    final match = _upcomingMatches[0];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderData: match),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text('UPCOMING MATCH',
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(match['title'] ?? 'Padel Venue',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(match['date'] ?? '-',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(match['time'] ?? '-',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedVenues() {
    if (_featuredVenues.isEmpty) {
      return const Center(
          child: Text("Tidak ada rekomendasi lapangan."));
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _featuredVenues.length,
        itemBuilder: (context, index) {
          final venue = _featuredVenues[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VenueDetailScreen(
                    venueName: venue['name'] ?? 'Padel Hub Senayan',
                    rating: venue['rating'] ?? '4.9',
                    distance: venue['location'] ?? 'Jakarta',
                    price: venue['price'] ?? 'Rp150.000',
                    imageUrl: venue['image'] != null && venue['image'] != ''
                        ? venue['image']
                        : 'https://images.unsplash.com/photo-1622225436666-8809ba76d498?q=80&w=1000',
                  ),
                ),
              );
            },
            child: Container(
              width: 260,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    child: Image.network(
                      venue['image'] != ''
                          ? venue['image']
                          : 'https://images.unsplash.com/photo-1622225436666-8809ba76d498?q=80&w=1000',
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                          height: 130,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(venue['name'] ?? 'Venue Name',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(venue['rating'] ?? '4.0',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                            ]),
                            Text(venue['price'] ?? 'Rp -',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}