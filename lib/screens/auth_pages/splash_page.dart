import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../../services/auth_service.dart';
import '../main_pages/main_page.dart';

class SlashPage extends StatefulWidget {
  const SlashPage({super.key});

  @override
  State<SlashPage> createState() => _SlashPageState();
}

class _SlashPageState extends State<SlashPage> {
  double progress = 0;
  Timer? timer;
  bool isNavigated = false;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() {
        progress += 0.02; // 50 lần = 5 giây
      });

      if (progress >= 1) {
        t.cancel();
        goToLogin();
      }
    });
  }

  Future<void> goToLogin() async {
    if (isNavigated) return;

    isNavigated = true;
    timer?.cancel();

    bool loggedIn = await AuthService.isLogin();

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF121212)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.movie_filter,
                        size: 100,
                        color: Color(0xFF39FF14),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'KRISTAL CINEMA',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFF39FF14),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Hệ thống đặt vé xem phim Online',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 50),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF39FF14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${(progress * 100).toInt()} %",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: 180,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: goToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF39FF14),
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text(
                        "Tiếp tục",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Hoặc chờ 5 giây để tự động chuyển...",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
