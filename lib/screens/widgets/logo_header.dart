import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final double height;
  final double horizontalPadding;

  const LogoHeader({
    super.key,
    this.height = 40,
    this.horizontalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/logo.png",
            height: height,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.movie_filter,
                size: height * 0.8,
                color: const Color(0xFF39FF14),
              );
            },
          ),
          const SizedBox(width: 10),
          const Text(
            "KristalCinema",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF39FF14),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
