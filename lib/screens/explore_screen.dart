import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'venue_detail_screen.dart'; 

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Color primaryColor = const Color(0xFF278cf1);
  int selectedCategoryIndex = 0;
  bool _isLoading = true;

  List<String> categories = ['Semua']; 
  List<dynamic> allVenues = [];      
  List<dynamic> filteredVenues = []; 

  @override
  void initState() {
    super.initState();
    _fetchVenues(); 
  }

  Future<void> _fetchVenues() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
      ));

      final response = await dio.get('/venues'); 

      if (response.statusCode == 200 && response.data['status'] == 200) {
        if (mounted) {
          setState(() {
            categories = List<String>.from(response.data['data']['categories']);
            allVenues = response.data['data']['venues'] ?? [];
            filteredVenues = allVenues; 
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetch explore: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCategorySelected(int index) {
    setState(() {
      selectedCategoryIndex = index;
      
      if (index == 0) {
        filteredVenues = allVenues;
      } else {
        String selectedLocation = categories[index];
        filteredVenues = allVenues.where((venue) => venue['location'] == selectedLocation).toList();
      }
    });
  }

  void _goToVenueDetail(Map<String, dynamic> venue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VenueDetailScreen(
          venueName: venue['name'],
          rating: venue['rating'].toString(),
          distance: venue['full_location'], 
          price: venue['price'],
          imageUrl: venue['image'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderAndSearch(),
            _buildCategoryChips(), 
            _buildSectionTitle(),
            
            Expanded(
              child: _isLoading 
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : _buildVenueList(), 
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAndSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      color: Colors.white.withOpacity(0.9),
      child: Column(
        children: [
          // HEADER TANPA CIRCLE NOTIFIKASI
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.location_on, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Lokasi Anda', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  Text('Jakarta Selatan, ID', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari lapangan atau klub...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true, fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    if (categories.length == 1 && _isLoading) return const SizedBox(height: 70); 

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => _onCategorySelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(colors: [primaryColor, Colors.blue.shade800]) : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Rekomendasi Terdekat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Lihat Semua', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor)),
        ],
      ),
    );
  }

  Widget _buildVenueList() {
    if (filteredVenues.isEmpty) {
      return const Center(
        child: Text("Belum ada lapangan di lokasi ini.", style: TextStyle(color: Colors.grey))
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
      itemCount: filteredVenues.length,
      itemBuilder: (context, index) {
        return _buildVenueCard(filteredVenues[index]);
      },
    );
  }

  Widget _buildVenueCard(Map<String, dynamic> venue) {
    String imageUrl = venue['image'] ?? '';

    return GestureDetector(
      onTap: () => _goToVenueDetail(venue), 
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageUrl.isNotEmpty 
                    ? Image.network(
                        imageUrl,
                        height: 200, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200, width: double.infinity, color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 60),
                        ),
                      )
                    : Container(
                        height: 200, width: double.infinity, color: Colors.grey.shade300,
                        child: const Icon(Icons.sports_tennis, color: Colors.white, size: 60),
                      ),
                ),
                Positioned(
                  top: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text(venue['rating'].toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                if (venue['isPopular'] == true)
                  Positioned(
                    bottom: 16, left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryColor, Colors.blue.shade800]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('POPULER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(venue['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.near_me, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(child: Text('${venue['location']} • ${venue['distance']}', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(venue['price'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                          const Text('PER JAM', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF0F0F0), height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildSmallAvatar('JD', Colors.grey.shade200, Colors.grey.shade700),
                          Transform.translate(offset: const Offset(-8, 0), child: _buildSmallAvatar('AS', primaryColor.withOpacity(0.2), primaryColor)),
                          Transform.translate(offset: const Offset(-16, 0), child: _buildSmallAvatar('+12', Colors.grey.shade100, Colors.grey.shade500)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _goToVenueDetail(venue), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 4, shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        child: Row(
                          children: const [
                            Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallAvatar(String text, Color bgColor, Color textColor) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
    );
  }
}