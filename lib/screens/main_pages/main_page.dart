import 'package:flutter/material.dart';

import '../../screens/widgets/nav_widget.dart';
import '../../screens/main_pages/history_page.dart';
import '../../screens/main_pages/home_page.dart';
import '../../screens/main_pages/cinema_page.dart';
import '../../screens/main_pages/profile_setting_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomePage(),
      const CinemaPage(),
      const HistoryPage(),
      const ProfileSettingPage(),
    ];
  }

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: changeTab,
      ),
    );
  }
}
