import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pastikan path ini sesuai dengan letak file splash_screen.dart milikmu
import 'screens/splash_screen.dart';

void main() {
  runApp(const PadelProApp());
}

class PadelProApp extends StatelessWidget {
  const PadelProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PadelPro',
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" merah
      theme: ThemeData(
        primaryColor: const Color(0xFF278cf1),
        scaffoldBackgroundColor: Colors.grey.shade50,      
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF278cf1),
        ),
        // Menerapkan font Poppins ke seluruh aplikasi
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      // Pintu masuk utama aplikasi
      home: const SplashScreen(),
    );
  }
}