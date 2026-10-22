import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'moka_theme.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Ditambahkan delay sedikit agar animasi loading pull-to-refresh terlihat natural
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _history = prefs.getStringList('order_history') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dibungkus dengan RefreshIndicator untuk fitur pull-to-refresh
    return RefreshIndicator(
      color: MokaColors.brown,
      backgroundColor: MokaColors.pinkSoft,
      onRefresh: _loadHistory,
      child: SingleChildScrollView(
        // AlwaysScrollableScrollPhysics wajib ditambahkan agar layar selalu bisa ditarik ke bawah
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Pesanan',
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: MokaColors.brown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua transaksi yang telah berhasil.',
              style: GoogleFonts.dmSans(color: MokaColors.brownSoft),
            ),
            const SizedBox(height: 24),

            if (_history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: MokaColors.pinkSoft,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada pesanan.',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: MokaColors.brownSoft,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tarik layar ke bawah untuk memuat ulang.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: MokaColors.brownSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final data = _history[index].split('|');
                  if (data.length < 3) return const SizedBox();

                  String formatRupiah =
                      'Rp ${int.parse(data[2]).toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MokaColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: MokaColors.pinkSoft,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MokaColors.pink,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: MokaColors.brown,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[0],
                                style: GoogleFonts.vt323(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MokaColors.brown,
                                ),
                              ),
                              Text(
                                data[1],
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: MokaColors.brownSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatRupiah,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: MokaColors.brown,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF5EE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Sukses',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF53745A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
