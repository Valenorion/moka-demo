import 'package:flutter/material.dart';

class MokaColors {
  static const brown = Color(0xFF3A2018);
  static const brownSoft = Color(0xFF76594F);
  static const pink = Color(0xFFF7A9BB);
  static const pinkSoft = Color(0xFFFFF0F3);
  static const cream = Color(0xFFF7F3EF);
  static const white = Color(0xFFFFFFFF);
  static const line = Color(0xFFEEE7E3);
}

// Terjemahan komponen <PixelIcon /> dari React ke Flutter
class PixelIcon extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;

  const PixelIcon({super.key, required this.iconName, this.size = 20, this.color});

  static const Map<String, List<String>> _icons = {
    'home': ["01110", "11011", "10001", "10101", "11111"],
    'cup': ["11110", "10011", "10011", "11110", "01100"],
    'bag': ["01110", "11011", "10001", "10001", "11111"],
    'pin': ["01110", "11011", "11011", "01110", "00100"],
    'sparkle': ["00100", "10101", "01110", "10101", "00100"],
  };

  @override
  Widget build(BuildContext context) {
    final pattern = _icons[iconName] ?? _icons['cup']!;
    final pixels = pattern.join("").split("");
    
    return SizedBox(
      width: size,
      height: size,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        itemCount: 25,
        itemBuilder: (context, index) {
          return Container(
            color: pixels[index] == "1" ? (color ?? MokaColors.brown) : Colors.transparent,
          );
        },
      ),
    );
  }
}