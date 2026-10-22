import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'menu_data.dart';

class CheckoutColors {
  static const mochaDark = Color(0xFF2D1813);
  static const mocha = Color(0xFF48291F);
  static const mochaMuted = Color(0xFF846F67);
  static const pink = Color(0xFFF4A5B8);
  static const pinkLight = Color(0xFFFFF0F4);
  static const pinkMid = Color(0xFFE88DA3);
  static const cream = Color(0xFFFAF7F5);
  static const white = Color(0xFFFFFFFF);
  static const line = Color(0xFFEADFDB);
  static const success = Color(0xFF53745A);
  static const error = Color(0xFFBE4F62);
  static const background = Color(0xFFF5F5F5);
}

String formatRupiah(double number) {
  return 'Rp ${number.toInt().toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}';
}

class CheckoutPage extends StatefulWidget {
  final List<Product> cart;
  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = 'QRIS';
  late TextEditingController _cashCtrl;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _cashCtrl = TextEditingController(text: total.toInt().toString());
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  double get subtotal => widget.cart.fold(0, (sum, item) => sum + item.price);
  double get tax => subtotal * 0.1;
  double get total => subtotal + tax;

  Map<int, Map<String, dynamic>> get groupedCart {
    Map<int, Map<String, dynamic>> map = {};
    for (var p in widget.cart) {
      if (map.containsKey(p.id)) {
        map[p.id]!['qty'] += 1;
      } else {
        map[p.id] = {'product': p, 'qty': 1};
      }
    }
    return map;
  }

  double get change {
    double cash = double.tryParse(_cashCtrl.text.replaceAll('.', '')) ?? 0;
    return (cash >= total) ? (cash - total) : 0;
  }

  bool get isInsufficient {
    if (_selectedPayment != 'CASH') return false;
    double cash = double.tryParse(_cashCtrl.text.replaceAll('.', '')) ?? 0;
    return cash < total;
  }

  void _setCashAmount(double amount) {
    setState(() {
      _cashCtrl.text = amount.toInt().toString();
      _isPaid = false;
    });
  }

  Future<void> _saveOrderAndClearCart() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('order_history') ?? [];

    final orderId =
        'MKA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final date =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    final orderData = "$orderId|$date|${total.toInt()}";

    history.insert(0, orderData);
    await prefs.setStringList('order_history', history);
    await prefs.remove('cartIds');
  }

  void _processPayment() {
    if (_selectedPayment == 'QRIS') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: CheckoutColors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scan QRIS',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CheckoutColors.mochaDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${formatRupiah(total)}',
                  style: GoogleFonts.vt323(
                    fontSize: 24,
                    color: CheckoutColors.pinkMid,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CheckoutColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CheckoutColors.line, width: 2),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    size: 200,
                    color: CheckoutColors.mochaDark,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Menunggu pembayaran...',
                  style: GoogleFonts.dmSans(color: CheckoutColors.mochaMuted),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CheckoutColors.mocha,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() => _isPaid = true);
                      await _saveOrderAndClearCart();
                      _showSuccessDialog();
                    },
                    child: Text(
                      'Simulasi: Anggap Sudah Bayar',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: CheckoutColors.pinkLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      setState(() => _isPaid = true);
      _saveOrderAndClearCart().then((_) => _showSuccessDialog());
    }
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: CheckoutColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: CheckoutColors.success,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Pembayaran Berhasil!',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: CheckoutColors.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan sedang disiapkan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: CheckoutColors.mochaMuted),
            ),

            const SizedBox(height: 20),

            // TAMBAHAN QR CODE BOHONGAN
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CheckoutColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CheckoutColors.line, width: 2),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: CheckoutColors.mochaDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tunjukkan layar ini ke kasir',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: CheckoutColors.mochaMuted,
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CheckoutColors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    color: CheckoutColors.mochaDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CheckoutColors.background,
      appBar: AppBar(
        backgroundColor: CheckoutColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: CheckoutColors.mochaDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Konfirmasi Pesanan',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CheckoutColors.mochaDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. KARTU LOKASI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CheckoutColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CheckoutColors.pinkLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: CheckoutColors.mocha,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengambilan (Takeaway)',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: CheckoutColors.mochaMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Moka Shibuya',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CheckoutColors.mochaDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. DAFTAR PESANAN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CheckoutColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan Kamu',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CheckoutColors.mochaDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...groupedCart.values.map((item) {
                      final Product p = item['product'];
                      final int qty = item['qty'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: CheckoutColors.line),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${qty}x',
                                style: GoogleFonts.vt323(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CheckoutColors.mocha,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: CheckoutColors.mochaDark,
                                    ),
                                  ),
                                  Text(
                                    p.detail,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: CheckoutColors.mochaMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatRupiah(p.price * qty),
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: CheckoutColors.mochaDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. METODE PEMBAYARAN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CheckoutColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CheckoutColors.mochaDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Opsi QRIS Menggunakan Efek Interaktif
                    HoverablePaymentCard(
                      onTap: () => setState(() {
                        _selectedPayment = 'QRIS';
                        _isPaid = false;
                      }),
                      isSelected: _selectedPayment == 'QRIS',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            color: CheckoutColors.mochaDark,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'QRIS (Gopay, ShopeePay, Dana)',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: CheckoutColors.mochaDark,
                              ),
                            ),
                          ),
                          if (_selectedPayment == 'QRIS')
                            const Icon(
                              Icons.check_circle,
                              color: CheckoutColors.pinkMid,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Opsi CASH Menggunakan Efek Interaktif
                    HoverablePaymentCard(
                      onTap: () => setState(() {
                        _selectedPayment = 'CASH';
                        _isPaid = false;
                      }),
                      isSelected: _selectedPayment == 'CASH',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.money,
                                color: CheckoutColors.mochaDark,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Uang Tunai (Kasir)',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold,
                                    color: CheckoutColors.mochaDark,
                                  ),
                                ),
                              ),
                              if (_selectedPayment == 'CASH')
                                const Icon(
                                  Icons.check_circle,
                                  color: CheckoutColors.pinkMid,
                                ),
                            ],
                          ),
                          if (_selectedPayment == 'CASH') ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(),
                            ),
                            Text(
                              'Ketik manual nominal uang pelanggan:',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: CheckoutColors.mochaMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: CheckoutColors.white,
                                border: Border.all(
                                  color: isInsufficient
                                      ? CheckoutColors.error
                                      : CheckoutColors.line,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Rp',
                                    style: GoogleFonts.vt323(
                                      fontSize: 22,
                                      color: CheckoutColors.mochaDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _cashCtrl,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: CheckoutColors.mochaDark,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0',
                                        isDense: true,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildCashPresetBtn(total, 'Uang Pas'),
                                const SizedBox(width: 8),
                                _buildCashPresetBtn(100000, 'Rp 100rb'),
                                const SizedBox(width: 8),
                                _buildCashPresetBtn(200000, 'Rp 200rb'),
                              ],
                            ),
                            if (change > 0 && !isInsufficient)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Kembalian:',
                                      style: GoogleFonts.dmSans(
                                        color: CheckoutColors.mochaMuted,
                                      ),
                                    ),
                                    Text(
                                      formatRupiah(change),
                                      style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.bold,
                                        color: CheckoutColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (isInsufficient)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  'Uang tunai kurang ${formatRupiah(total - (double.tryParse(_cashCtrl.text) ?? 0))}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: CheckoutColors.error,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. RINCIAN PEMBAYARAN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CheckoutColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian Pembayaran',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CheckoutColors.mochaDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal (${widget.cart.length} item)',
                          style: GoogleFonts.dmSans(
                            color: CheckoutColors.mochaMuted,
                          ),
                        ),
                        Text(
                          formatRupiah(subtotal),
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            color: CheckoutColors.mochaDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PB1 (10%)',
                          style: GoogleFonts.dmSans(
                            color: CheckoutColors.mochaMuted,
                          ),
                        ),
                        Text(
                          formatRupiah(tax),
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            color: CheckoutColors.mochaDark,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Keseluruhan',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CheckoutColors.mochaDark,
                          ),
                        ),
                        Text(
                          formatRupiah(total),
                          style: GoogleFonts.vt323(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: CheckoutColors.pinkMid,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CheckoutColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: CheckoutColors.mochaMuted,
                      ),
                    ),
                    Text(
                      formatRupiah(total),
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CheckoutColors.mochaDark,
                      ),
                    ),
                  ],
                ),
              ),
              Opacity(
                opacity: (isInsufficient || _isPaid) ? 0.5 : 1.0,
                child: ElevatedButton(
                  onPressed: (isInsufficient || _isPaid)
                      ? null
                      : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CheckoutColors.mocha,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isPaid ? 'Sudah Dibayar' : 'Bayar Sekarang',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CheckoutColors.pinkLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCashPresetBtn(double amount, String label) {
    bool isSelected = (_cashCtrl.text == amount.toInt().toString());
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _setCashAmount(amount),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? CheckoutColors.pink : CheckoutColors.white,
              border: Border.all(
                color: isSelected ? CheckoutColors.pink : CheckoutColors.line,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? CheckoutColors.mochaDark
                      : CheckoutColors.mochaMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET KUSTOM UNTUK KARTU PEMBAYARAN YANG RESPONSIF (HOVER)
// ============================================================================
class HoverablePaymentCard extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;

  const HoverablePaymentCard({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<HoverablePaymentCard> createState() => _HoverablePaymentCardState();
}

class _HoverablePaymentCardState extends State<HoverablePaymentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? CheckoutColors.pinkLight
                  : CheckoutColors.white,
              border: Border.all(
                color: widget.isSelected
                    ? CheckoutColors.pink
                    : (_isHovered ? CheckoutColors.pink : CheckoutColors.line),
                width: widget.isSelected || _isHovered ? 2.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: CheckoutColors.pinkLight.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
