import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      selectedItemColor: const Color(0xFF39FF14),
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.movie_creation_outlined), label: "Rạp chiếu"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "Lịch sử"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Tài khoản"),
      ],
    );
  }
}
