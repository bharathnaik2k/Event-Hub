import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color.fromARGB(255, 96, 111, 25);
  static const Color lightPurple = Color(0xFFBA68C8);
  static const Color darkPurple = Color(0xFF7B1FA2);
  static const Color accentBlue = Color.fromARGB(255, 33, 205, 243);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);

  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 84, 98, 22),
      Color.fromARGB(255, 24, 152, 181),
    ],
  );
  static LinearGradient buttonGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.fromARGB(255, 30, 105, 137),
      Color.fromARGB(255, 63, 110, 9),
    ],
  );
}

class CategoryColors {
  static const Map<String, Color> colors = {
    'Music': Color(0xFFE91E63),
    'Food': Color(0xFFFF9800),
    'Sports': Color(0xFF4CAF50),
    'Tech': Color(0xFF2196F3),
    'Art': Color(0xFF9C27B0),
    'Travel': Color(0xFF00BCD4),
  };

  static Color getColor(String category) {
    return colors[category] ?? AppColors.primaryPurple;
  }
}

const List<String> interestList = [
  'Music',
  'Food',
  'Sports',
  'Tech',
  'Art',
  'Travel',
];

void showSnack(BuildContext context, String msg) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
