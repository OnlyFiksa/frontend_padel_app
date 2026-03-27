import 'package:flutter/material.dart';
import 'dart:ui'; // Untuk efek blur (glassmorphism)

import 'dashboard_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart'; // Sekarang ini akan narik file history_screen.dart yang asli!

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman utama yang akan ditampilkan
  final List<Widget> _pages = [
    const DashboardScreen(),
    const ExploreScreen(),
    const HistoryScreen(), // Otomatis mengarah ke file baru
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      
      // PERUBAHAN UTAMA: Membuang IndexedStack agar halaman me-refresh saat ganti tab
      body: _pages[_selectedIndex],
      
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4), 
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.home_rounded, 0),
                    _buildNavItem(Icons.explore_rounded, 1),
                    _buildNavItem(Icons.calendar_month_rounded, 2),
                    _buildNavItem(Icons.person_rounded, 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi pembuat ikon menu dengan animasi
  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Warna Primary Blue PadelPro
          color: isSelected ? const Color(0xFF0d59f2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey.shade700,
          size: 26,
        ),
      ),
    );
  }
}