import 'package:flutter/material.dart';
import 'booking_screen.dart';

class VenueDetailScreen extends StatefulWidget {
  final String venueName;
  final String rating;
  final String distance;
  final String price;
  final String imageUrl;

  const VenueDetailScreen({
    super.key,
    this.venueName = "Padel Hub Senayan",
    this.rating = "4.9",
    this.distance = "Senayan, Jakarta Selatan",
    this.price = "150000", 
    this.imageUrl = "https://images.unsplash.com/photo-1622225436666-8809ba76d498?q=80&w=1000&auto=format&fit=crop", 
  });

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  final Color primaryColor = const Color(0xFF0d59f2);
  final Color bgColor = const Color(0xFFF5F6F8);
  final Color accentGreen = const Color(0xFF65a30d);

  // FUNGSI PINTAR BUAT NGERAPIHIN HARGA
  String _formatPrice(String rawPrice) {
    String cleanPrice = rawPrice.replaceAll(RegExp(r'[^0-9]'), '');
    int basePrice = int.tryParse(cleanPrice) ?? 150000;
    
    if (rawPrice.toLowerCase().contains('k') || basePrice < 1000) {
      basePrice = basePrice * 1000;
    }
    
    return 'Rp ${basePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomBookingBar(),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: 350,
            child: Image.network(widget.imageUrl, fit: BoxFit.cover),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 280),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleAndRating(),
                      const SizedBox(height: 24),
                      _buildFacilityIcons(),
                      const SizedBox(height: 24),
                      _buildAboutSection(),
                      const SizedBox(height: 24),
                      _buildAvailableCourts(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: _buildGlassButton(Icons.arrow_back, () => Navigator.pop(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44, width: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTitleAndRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.venueName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.2),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.star, color: accentGreen, size: 16),
                  const SizedBox(width: 4),
                  Text(widget.rating, style: TextStyle(fontWeight: FontWeight.bold, color: accentGreen)),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        const Text('Premium Padel Venue • Open until 11:00 PM', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.location_on, color: primaryColor, size: 18),
            const SizedBox(width: 6),
            Text(widget.distance, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }

  Widget _buildFacilityIcons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _facilityItem(Icons.wifi, 'FREE WIFI'),
          _facilityItem(Icons.local_parking, 'PARKING'),
          _facilityItem(Icons.shower, 'SHOWER'),
          _facilityItem(Icons.coffee, 'CAFE'),
        ],
      ),
    );
  }

  Widget _facilityItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          height: 48, width: 48,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ]),
          child: Icon(icon, color: primaryColor),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About Venue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          '${widget.venueName} features world-class panoramic padel courts with artificial turf. We provide premium amenities including a pro shop, equipment rentals, and a lounge area.',
          style: TextStyle(color: Colors.grey.shade600, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAvailableCourts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available Courts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _courtCard('Panoramic Court A', 'Indoor • Premium Turf'),
        const SizedBox(height: 12),
        _courtCard('Panoramic Court B', 'Indoor • Premium Turf'),
      ],
    );
  }

  Widget _courtCard(String name, String type) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.sports_tennis, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(type, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatPrice(widget.price), style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16)),
              const Text('/ hr', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomBookingBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL PRICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(_formatPrice(widget.price), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const Text(' /hr', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        venueName: widget.venueName,
                        location: widget.distance,
                        rating: widget.rating,
                        pricePerHour: widget.price,
                        imageUrl: widget.imageUrl,
                      ),
                    ),
                  );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                shadowColor: primaryColor.withOpacity(0.5),
              ),
              child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}