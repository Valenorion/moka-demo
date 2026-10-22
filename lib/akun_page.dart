import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'moka_theme.dart';
import 'auth_page.dart';

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('cartIds');
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 250),
      child: Column(
        children: [
          // Kartu Profil
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MokaColors.pinkSoft, // <-- Diperbaiki menjadi pinkSoft
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: MokaColors.pink),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: MokaColors.brown,
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: MokaColors.pink,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minji',
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: MokaColors.brown,
                        ),
                      ),
                      Text(
                        'minji@moka.com',
                        style: GoogleFonts.dmSans(color: MokaColors.brownSoft),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: MokaColors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '2.450 Moka Points',
                          style: GoogleFonts.vt323(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MokaColors.brown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildMenuTile(Icons.person_outline, 'Edit Profil'),
          _buildMenuTile(Icons.location_on_outlined, 'Alamat Tersimpan'),
          _buildMenuTile(Icons.notifications_none, 'Notifikasi'),
          const Divider(height: 40),
          _buildMenuTile(Icons.headset_mic_outlined, 'Bantuan & Call Center'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Logout',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            onTap: () => _logout(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: MokaColors.brown),
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.bold,
          color: MokaColors.brown,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: MokaColors.brownSoft),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: () {},
    );
  }
}
