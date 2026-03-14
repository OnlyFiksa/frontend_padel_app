import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../config/api_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryColor = const Color(0xFF0d59f2);
  final Color bgColor = const Color(0xFFF5F6F8);

  // --- STATE VARIABLES ---
  bool _isLoading = true;
  String _userName = "Memuat...";
  
  // List kosong untuk menampung data dari database
  List<dynamic> _upcomingMatches = [];
  List<dynamic> _featuredVenues = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData(); // Tarik data saat halaman pertama kali dibuka
  }

  // --- FUNGSI LOGIC API KE CODEIGNITER 4 ---
  Future<void> _fetchDashboardData() async {
    // 2. BACA MEMORI HP SEBELUM NARIK API
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedName = prefs.getString('userName') ?? 'Pemain';

    setState(() {
      _userName = savedName; // Langsung tampilkan nama yang tersimpan
    });

    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
      ));
      
      final response = await dio.get('/dashboard'); 

      if (response.statusCode == 200 && response.data['status'] == 200) {
        setState(() {
          // Namanya tidak perlu ditimpa dari CI4 lagi, cukup data lapangannya saja
          _upcomingMatches = response.data['data']['upcoming_matches'] ?? [];
          _featuredVenues = response.data['data']['featured_venues'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetch dashboard: $e");
      // JARING PENGAMAN TINGKAT DEWA: 
      // Kalau API CI4 kamu belum siap/error, aplikasi ngga akan blank putih. 
      // Kita kasih data dummy sementaranya di sini sampai backend kamu beres.
      if (mounted) {
        setState(() {
          _userName = "Opik"; // Data fallback
          _upcomingMatches = [
            {
              "title": "Club de Padel Madrid",
              "type": "SEMI-FINALS",
              "date": "Today",
              "time": "18:30 PM"
            }
          ];
          _featuredVenues = [
            {"name": "Padel Hub East", "rating": "4.9", "distance": "2.4 km away", "price": "€12/hr"},
            {"name": "Sky Terrace Padel", "rating": "4.7", "distance": "4.1 km away", "price": "€15/hr"},
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoading 
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildPromoBanner(),  // Ini tetap statis sesuai permintaanmu
                    _buildNextMatch(),    // Ini sekarang dinamis dari DB
                    _buildFeaturedVenues(), // Ini sekarang dinamis dari DB
                  ],
                ),
              ),
      ),
    );
  }

  // 1. Header (Nama User Dinamis & Tanpa Icon Search)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WELCOME BACK',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              Text(
                _userName, // NAMA USER TAMPIL DI SINI
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          Stack(
            children: [
              _buildIconButton(Icons.notifications_none),
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(icon, color: Colors.grey.shade700, size: 22),
    );
  }

  // 2. Promotional Banner (Statis)
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [primaryColor, Colors.blue.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20, bottom: -20,
              child: Icon(Icons.sports_tennis, size: 140, color: Colors.white.withOpacity(0.15)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                    child: const Text('SUMMER PRO LEAGUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Get 20% Off Bookings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Book any court this weekend\nand save on your next match.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, foregroundColor: primaryColor, elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Claim Offer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Your Next Match (Dinamis dari list _upcomingMatches)
  Widget _buildNextMatch() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Next Match', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('View Schedule', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Kalau belum ada bookingan, tampilkan pesan kosong
          if (_upcomingMatches.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: const Text("Belum ada jadwal main nih. Yuk booking lapangan!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            )
          else 
            // Kalau ada bookingan, tampilkan card pertama (atau bisa pakai ListView kalau mau nampilin banyak)
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 120, width: double.infinity, color: Colors.grey.shade300,
                      child: const Icon(Icons.image, color: Colors.grey, size: 40), 
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                'UPCOMING • ${_upcomingMatches[0]['type']}', 
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor)
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${_upcomingMatches[0]['date']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Text('${_upcomingMatches[0]['time']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${_upcomingMatches[0]['title']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Check In Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  // 4. Featured Venues (Dinamis List Horizontal)
  Widget _buildFeaturedVenues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Featured Venues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Explore All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: _featuredVenues.isEmpty 
            ? const Center(child: Text('Belum ada referensi lapangan.'))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _featuredVenues.length,
                itemBuilder: (context, index) {
                  final venue = _featuredVenues[index];
                  return _buildVenueCard(
                    venue['name'], 
                    venue['rating'], 
                    venue['distance'], 
                    venue['price'],
                    venue['image'] ?? '',
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildVenueCard(String title, String rating, String distance, String price, String imageUrl) {
    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            // GANTI BAGIAN CONTAINER ICON JADI IMAGE.NETWORK
            child: imageUrl.isNotEmpty 
              ? Image.network(
                  imageUrl, 
                  height: 120, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  // Jaring pengaman kalau gambarnya gagal loading
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120, width: double.infinity, color: Colors.blueGrey.shade100,
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  ),
                )
              : Container(
                  height: 120, width: double.infinity, color: Colors.blueGrey.shade100,
                  child: const Icon(Icons.sports_tennis, color: Colors.white, size: 40), 
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 2),
                        Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(distance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('From $price', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                      child: const Text('Book', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}