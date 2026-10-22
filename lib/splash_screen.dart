import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahan untuk membaca sesi

import 'auth_page.dart';
import 'dashboard_page.dart'; // Tambahan agar bisa diarahkan ke dashboard

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginSession(); // Memanggil fungsi pengecekan sesi saat aplikasi dibuka
  }

  void _checkLoginSession() async {
    // 1. Inisialisasi SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // 2. Cek status login (jika belum ada, default-nya false)
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // 3. Jeda waktu Splash Screen selama 3.5 detik (sesuai timer Anda sebelumnya)
    await Future.delayed(const Duration(milliseconds: 3500));

    // 4. Logika perpindahan halaman
    if (mounted) {
      if (isLoggedIn) {
        // Jika sudah login, langsung lompat ke Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        // Jika belum login, masuk ke halaman Auth/Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
      }
    }
  }

  Widget _buildPixelLetter(String letter, {required bool isBrown}) {
    final textColor = isBrown
        ? const Color(0xFF48291F)
        : const Color(0xFFF5A6B9);
    final shadowColor = isBrown
        ? const Color(0xFFF5A6B9)
        : const Color(0xFF48291F);

    return Text(
      letter,
      style: GoogleFonts.pixelifySans(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        height: 0.85,
        color: textColor,
        shadows: [Shadow(color: shadowColor, offset: const Offset(4, 4))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: -0.07,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: const BoxDecoration(
                          color: Color(0x59FFDCE4),
                        ),
                      ),
                    ),
                    Image.asset(
                      'carmen.jpg', // Ganti dengan nama file gambar di folder assets Anda
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.local_cafe,
                          size: 80,
                          color: Color(0xFFF5A6B9),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPixelLetter('M', isBrown: true),
                  const SizedBox(width: 8),
                  _buildPixelLetter('O', isBrown: false),
                  const SizedBox(width: 8),
                  _buildPixelLetter('K', isBrown: true),
                  const SizedBox(width: 8),
                  _buildPixelLetter('A', isBrown: false),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'COFFEE & GOOD DAYS',
                style: GoogleFonts.pixelifySans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.0,
                  color: const Color(0xFF48291F),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 5, height: 5, color: const Color(0xFFFFDCE4)),
                const SizedBox(width: 6),
                Container(width: 5, height: 5, color: const Color(0xFF48291F)),
                const SizedBox(width: 6),
                Container(width: 5, height: 5, color: const Color(0xFF48291F)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
