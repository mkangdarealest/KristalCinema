import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/preference_service.dart';
import '../../services/firestore_service.dart';
import '../widgets/logo_header.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> loginHistory = [];
  List<Map<String, dynamic>> bookingHistory = [];

  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    loadAllHistories();
  }

  Future<void> loadAllHistories() async {
    loginHistory = await AuthService.getHistory();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bookingHistory = await FirestoreService.getUserBookings(user.uid);
    } else {
      bookingHistory = [];
    }
    if (mounted) setState(() {});
  }

  Future<void> clearLoginHistory() async {
    await PreferenceService.clearHistory();
    loadAllHistories();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lịch sử đăng nhập đã xóa")),
    );
  }

  Future<void> clearBookingHistory() async {
    await PreferenceService.clearTickets();
    loadAllHistories();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lịch sử đặt vé đã xóa")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const LogoHeader(height: 45, horizontalPadding: 0),
          backgroundColor: Colors.black,
          bottom: const TabBar(
            indicatorColor: Color(0xFF39FF14),
            labelColor: Color(0xFF39FF14),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.movie), text: "Vé đã đặt"),
              Tab(icon: Icon(Icons.login), text: "Đăng nhập"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Booking History
            _buildBookingTab(),

            // Tab 2: Login History
            _buildLoginTab(),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------
  // BOOKING HISTORY TAB
  //--------------------------------------------
  Widget _buildBookingTab() {
    if (bookingHistory.isEmpty) {
      return const Center(
        child: Text(
          "Chưa có lịch sử đặt vé nào.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadAllHistories,
      child: ListView.builder(
        itemCount: bookingHistory.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (context, index) {
          final ticket = bookingHistory[index];
          final title = ticket["movieTitle"] ?? "N/A";
          final image = ticket["movieImage"] ?? ticket["moviePoster"] ?? "";
          final cinema = ticket["cinemaName"] ?? "N/A";
          final showtime = ticket["showtime"] ?? "N/A";
          final seats = List<String>.from(ticket["seats"] ?? []);
          final price = ticket["totalPrice"] ?? 0;
          final timeStr = ticket["bookingTime"] ?? "";

          String dateFormatted = "";
          try {
            final date = DateTime.parse(timeStr);
            dateFormatted = DateFormat("dd/MM/yyyy HH:mm").format(date);
          } catch (e) {
            dateFormatted = timeStr;
          }

          return Card(
            color: const Color(0xFF121212),
            margin: const EdgeInsets.only(bottom: 14.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: image.isNotEmpty
                        ? (image.startsWith("http")
                            ? Image.network(image, width: 60, height: 85, fit: BoxFit.cover)
                            : Image.asset(image, width: 60, height: 85, fit: BoxFit.cover))
                        : Container(color: Colors.grey, width: 60, height: 85),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cinema,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text("Suất: ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(showtime, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            const Text("Ghế: ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(seats.join(', '), style: const TextStyle(color: Color(0xFF39FF14), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tổng: ${formatter.format(price)}",
                          style: const TextStyle(color: Color(0xFF39FF14), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ngày đặt: $dateFormatted",
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //--------------------------------------------
  // LOGIN HISTORY TAB
  //--------------------------------------------
  Widget _buildLoginTab() {
    if (loginHistory.isEmpty) {
      return const Center(
        child: Text(
          "Chưa có lịch sử đăng nhập nào.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: TextButton.icon(
              onPressed: clearLoginHistory,
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              label: const Text("Xóa lịch sử", style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadAllHistories,
            child: ListView.builder(
              itemCount: loginHistory.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFF121212),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white12,
                      child: Icon(Icons.history, color: Color(0xFF39FF14)),
                    ),
                    title: Text(
                      loginHistory[index],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    subtitle: Text(
                      "Lần đăng nhập ${loginHistory.length - index}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
