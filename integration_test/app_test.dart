import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:padel_app/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();


  GoogleFonts.config.allowRuntimeFetching = true;

  group('End-to-End Automation Test PadelPro', () {
    testWidgets('Alur Registrasi dan Login Berhasil', (WidgetTester tester) async {
      
      // ==========================================
      // TRIK MAGIC 2.0: MEMBUNGKAM ERROR GOOGLE FONTS
      // Jika download font gagal karena koneksi dites, robot akan 
      // mengabaikan error tersebut dan tetap melanjutkan tugasnya!
      // ==========================================
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exceptionAsString().contains('GoogleFonts') || 
            details.exceptionAsString().contains('ClientException')) {
          return; 
        }
        originalOnError?.call(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        if (error.toString().contains('GoogleFonts') || 
            error.toString().contains('ClientException')) {
          return true;
        }
        return false;
      };

      // Mulai jalankan aplikasi
      app.main();
      
      // Tunggu animasi Splash Screen selesai
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // ==========================================
      // FASE 1: REGISTRASI AKUN BARU
      // ==========================================
      final Finder signUpText = find.text('Sign Up').last; 
      await tester.tap(signUpText);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      final String testUsername = 'qa_user$uniqueId';
      final String testEmail = 'qa_$uniqueId@padelpro.com';

      await tester.enterText(find.byType(TextFormField).at(0), 'Auto Tester'); 
      await tester.enterText(find.byType(TextFormField).at(1), testUsername);  
      await tester.enterText(find.byType(TextFormField).at(2), testEmail);     
      await tester.enterText(find.byType(TextFormField).at(3), 'password123'); 
      await tester.enterText(find.byType(TextFormField).at(4), 'password123'); 
      
      FocusManager.instance.primaryFocus?.unfocus(); 
      await tester.pumpAndSettle();

      final Finder registerButton = find.text('Sign Up').last; 
      await tester.tap(registerButton);
      
      await tester.pumpAndSettle(const Duration(seconds: 5));


      // ==========================================
      // FASE 2: LOGIN DENGAN AKUN BARU
      // ==========================================
      await tester.enterText(find.byType(TextFormField).at(0), testUsername);
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      
      FocusManager.instance.primaryFocus?.unfocus(); 
      await tester.pumpAndSettle();

      final Finder loginButton = find.text('Login').last;
      await tester.tap(loginButton);

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ==========================================
      // FASE 3: VALIDASI HASIL
      // ==========================================
      expect(find.textContaining('Hello'), findsWidgets); 
    });
  });
}