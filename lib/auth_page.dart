import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_page.dart';

class LoginColors {
  static const mochaDark = Color(0xFF2D1813);
  static const mocha = Color(0xFF48291F);
  static const mochaMuted = Color(0xFF826C64);
  static const pink = Color(0xFFF4A5B8);
  static const pinkLight = Color(0xFFFFF0F4);
  static const white = Color(0xFFFFFFFF);
  static const line = Color(0xFFE9DFDC);
}

class PixelIcon7x7 extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const PixelIcon7x7({
    super.key,
    required this.name,
    this.size = 21,
    this.color,
  });

  static const Map<String, List<String>> _patterns = {
    'user': [
      "0011100",
      "0111110",
      "0111110",
      "0011100",
      "0111110",
      "1101011",
      "1100011",
    ],
    'lock': [
      "0011100",
      "0110110",
      "0110110",
      "1111111",
      "1101011",
      "1100011",
      "1111111",
    ],
    'eye': [
      "0000000",
      "0111110",
      "1100011",
      "1101011",
      "0111110",
      "0000000",
      "0000000",
    ],
    'eyeOff': [
      "1000000",
      "0111110",
      "1100111",
      "1101011",
      "1111010",
      "0000001",
      "0000000",
    ],
    'cup': [
      "1111100",
      "1000110",
      "1010110",
      "1000110",
      "1111100",
      "0111000",
      "1111100",
    ],
    'spark': [
      "0001000",
      "0001000",
      "1011101",
      "0111110",
      "1011101",
      "0001000",
      "0001000",
    ],
  };

  @override
  Widget build(BuildContext context) {
    final pattern = _patterns[name] ?? _patterns['cup']!;
    final pixels = pattern.join("").split("");

    return SizedBox(
      width: size,
      height: size,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemCount: 49,
        itemBuilder: (context, index) {
          return Container(
            color: pixels[index] == "1"
                ? (color ?? LoginColors.mocha)
                : Colors.transparent,
          );
        },
      ),
    );
  }
}

// Custom Widget Tombol dengan Efek Hover & Press Interaktif
class PixelButton extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color shadowColor;
  final VoidCallback onTap;
  final String? suffixIcon;

  const PixelButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.shadowColor,
    required this.onTap,
    this.suffixIcon,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Menghitung kedalaman bayangan dan perpindahan posisi tombol saat dihover/ditekan
    final double shadowOffset = _isPressed ? 1.0 : (_isHovered ? 3.0 : 5.0);
    final double translation = 5.0 - shadowOffset;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          transform: Matrix4.translationValues(translation, translation, 0),
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(color: LoginColors.mochaDark, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                offset: Offset(shadowOffset, shadowOffset),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: GoogleFonts.pixelifySans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
              ),
              if (widget.suffixIcon != null) ...[
                const SizedBox(width: 6),
                Text(
                  widget.suffixIcon!,
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    color: widget.textColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool isLoginMode = true;
  bool showPassword = false;
  bool showSuccessMessage = false;

  void _handleSubmit() async {
    final prefs = await SharedPreferences.getInstance();

    if (isLoginMode) {
      // Baca kredensial yang tersimpan. Jika belum ada (null), gunakan default 'Minji' dan '123'
      final savedUser = prefs.getString('user') ?? 'Minji';
      final savedPass = prefs.getString('pass') ?? '123';

      // Validasi Login
      if (_userCtrl.text.isNotEmpty &&
          _userCtrl.text == savedUser &&
          _passCtrl.text == savedPass) {
        // MENYIMPAN STATUS LOGIN AGAR TIDAK HILANG SAAT REFRESH
        await prefs.setBool('isLoggedIn', true);

        setState(() => showSuccessMessage = true);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Username atau Password salah! Default: User: Minji, Pass: 123',
            ), // Menampilkan hint default
            backgroundColor: LoginColors.mochaDark,
          ),
        );
      }
    } else {
      // Validasi Register
      if (_userCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mohon isi semua kolom!')));
        return;
      }

      // Simpan User & Pass baru
      await prefs.setString('user', _userCtrl.text);
      await prefs.setString('pass', _passCtrl.text);

      setState(() {
        isLoginMode = true;
        _passCtrl.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pendaftaran berhasil! Silakan Login dengan akun barumu.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 100,
              right: 20,
              child: Container(width: 7, height: 7, color: LoginColors.pink),
            ),
            Positioned(
              bottom: 80,
              left: 15,
              child: Container(width: 7, height: 7, color: LoginColors.mocha),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 27,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 40,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BRAND HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: LoginColors.pink,
                                  boxShadow: [
                                    BoxShadow(
                                      color: LoginColors.mochaDark,
                                      offset: Offset(4, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: PixelIcon7x7(
                                    name: 'cup',
                                    size: 28,
                                    color: LoginColors.mochaDark,
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.pixelifySans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: LoginColors.mocha,
                                    letterSpacing: 1,
                                  ),
                                  children: [
                                    const TextSpan(text: 'MO'),
                                    TextSpan(
                                      text: 'KA',
                                      style: GoogleFonts.pixelifySans(
                                        color: LoginColors.pink,
                                        shadows: [
                                          const Shadow(
                                            color: LoginColors.mocha,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 35),

                          // TRANSISI ANIMASI ANTAR HALAMAN (LOGIN <-> REGISTER)
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.04, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                            child: Column(
                              key: ValueKey<bool>(isLoginMode),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const PixelIcon7x7(
                                      name: 'spark',
                                      size: 11,
                                      color: Color(0xFFBD7184),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      isLoginMode
                                          ? 'NICE TO SEE YOU'
                                          : 'GET STARTED',
                                      style: GoogleFonts.pixelifySans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFBD7184),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  isLoginMode
                                      ? 'Welcome\nback!'
                                      : 'Create\naccount!',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    height: 0.93,
                                    letterSpacing: -2.5,
                                    color: LoginColors.mochaDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isLoginMode
                                      ? "Sign in and let's get your coffee started."
                                      : "Register now and order your favorite drink.",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: LoginColors.mochaMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // INPUT USERNAME
                          Text(
                            'Username',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: LoginColors.mocha,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: LoginColors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(color: LoginColors.line),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                const PixelIcon7x7(
                                  name: 'user',
                                  size: 21,
                                  color: LoginColors.mocha,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _userCtrl,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: LoginColors.mocha,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Your username',
                                      hintStyle: GoogleFonts.dmSans(
                                        color: const Color(0xFFB7A9A4),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // INPUT PASSWORD
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Password',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: LoginColors.mocha,
                                ),
                              ),
                              if (isLoginMode)
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Forgot password?',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFB76A7D),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: LoginColors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(color: LoginColors.line),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                const PixelIcon7x7(
                                  name: 'lock',
                                  size: 21,
                                  color: LoginColors.mocha,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _passCtrl,
                                    obscureText: !showPassword,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: LoginColors.mocha,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Your password',
                                      hintStyle: GoogleFonts.dmSans(
                                        color: const Color(0xFFB7A9A4),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: PixelIcon7x7(
                                    name: showPassword ? 'eyeOff' : 'eye',
                                    size: 19,
                                    color: LoginColors.mochaMuted,
                                  ),
                                  onPressed: () => setState(
                                    () => showPassword = !showPassword,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),

                          if (showSuccessMessage) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 17,
                                  height: 17,
                                  color: const Color(0xFFE8F3E7),
                                  child: const Center(
                                    child: Text(
                                      '✓',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF5E7E5B),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "You're all set. Coffee time!",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF5E7E5B),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 28),

                          // TOMBOL UTAMA
                          PixelButton(
                            text: isLoginMode ? 'Login' : 'Submit Register',
                            suffixIcon: isLoginMode ? '→' : null,
                            backgroundColor: LoginColors.pink,
                            textColor: LoginColors.mochaDark,
                            shadowColor: LoginColors.mochaDark,
                            onTap: _handleSubmit,
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: LoginColors.line),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.pixelifySans(
                                    fontSize: 9,
                                    color: const Color(0xFFB2A39E),
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: LoginColors.line),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // TOMBOL SEKUNDER
                          PixelButton(
                            text: isLoginMode ? 'Register' : 'Back to Login',
                            backgroundColor: LoginColors.mocha,
                            textColor: LoginColors.white,
                            shadowColor: LoginColors.pink,
                            onTap: () {
                              setState(() {
                                isLoginMode = !isLoginMode;
                                showSuccessMessage = false;
                              });
                            },
                          ),

                          const Spacer(),

                          // FOOTER
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  color: LoginColors.pink,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  'One cup closer to a good day.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    color: const Color(0xFFA99892),
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Container(
                                  width: 4,
                                  height: 4,
                                  color: LoginColors.pink,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
