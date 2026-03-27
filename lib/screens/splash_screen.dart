import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart'; // Pastikan import halaman login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Color primaryColor = const Color(0xFF278cf1);

  @override
  void initState() {
    super.initState();
    // Simulasi loading 3 detik, lalu pindah ke Login Screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Dekorasi (Pattern & Gradient tiruan)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.05)),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.05)),
            ),
          ),
          
          // Konten Utama
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Glowing
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                    ],
                  ),
                  child: Icon(Icons.sports_tennis, size: 80, color: primaryColor),
                ),
                const SizedBox(height: 24),
                // Judul PadelPro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Padel', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('Pro', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: primaryColor)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'PREMIUM COURT BOOKING',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor.withOpacity(0.8), letterSpacing: 2),
                ),
              ],
            ),
          ),

          // Loading Area di Bawah
          Positioned(
            bottom: 50,
            left: 40,
            right: 40,
            child: Column(
              children: [
                // Animasi Loading Bar
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 3), // Samakan dengan durasi Timer
                  builder: (context, value, _) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Loading experience...', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('${(value * 100).toInt()}%', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor: primaryColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: primaryColor.withOpacity(0.7), size: 16),
                    const SizedBox(width: 4),
                    const Text('Official Padel Federation Partner', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
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