import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/movie_model.dart';
import '../../models/cinema_model.dart';
import '../../services/firestore_service.dart';
import 'add_edit_movie_page.dart';
import 'add_edit_cinema_page.dart';
import 'add_voucher_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<Movie> movies = [];
  List<Cinema> cinemas = [];
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> vouchers = [];
  bool isLoading = true;

  final TextEditingController movieSearchController = TextEditingController();
  String movieSearchQuery = "";

  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    movieSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      isLoading = true;
    });

    final fetchedMovies = await FirestoreService.getMovies();
    final fetchedCinemas = await FirestoreService.getCinemas();
    final fetchedBookings = await FirestoreService.getAllBookings();
    final fetchedVouchers = await FirestoreService.getVouchers();

    setState(() {
      movies = fetchedMovies;
      cinemas = fetchedCinemas;
      bookings = fetchedBookings;
      vouchers = fetchedVouchers;
      isLoading = false;
    });
  }

  Future<void> _deleteMovie(String movieId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text("Xác nhận xóa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc chắn muốn xóa bộ phim \"$title\" khỏi hệ thống?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService.deleteMovie(movieId);
        _loadAllData(); // Refresh list
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa phim thành công"), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi xóa phim: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _deleteCinema(String cinemaId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text("Xác nhận xóa rạp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc chắn muốn xóa rạp \"$name\" khỏi hệ thống?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService.deleteCinema(cinemaId);
        _loadAllData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa rạp chiếu thành công"), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi xóa rạp: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _deleteVoucher(String voucherId, String code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text("Xác nhận xóa Voucher", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc chắn muốn xóa mã giảm giá \"$code\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService.deleteVoucher(voucherId);
        _loadAllData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa Voucher thành công"), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi xóa Voucher: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Trang quản trị (Admin Portal)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Color(0xFF39FF14),
            labelColor: Color(0xFF39FF14),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: "Thống kê"),
              Tab(icon: Icon(Icons.movie), text: "Phim"),
              Tab(icon: Icon(Icons.domain), text: "Rạp chiếu"),
              Tab(icon: Icon(Icons.receipt_long), text: "Hóa đơn"),
              Tab(icon: Icon(Icons.local_offer), text: "Voucher"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF39FF14)))
            : TabBarView(
                children: [
                  _buildStatsTab(),
                  _buildMoviesTab(),
                  _buildCinemasTab(),
                  _buildBookingsTab(),
                  _buildVouchersTab(),
                ],
              ),
      ),
    );
  }

  // ==========================================
  // TAB 1: STATS & OVERVIEW
  // ==========================================
  Widget _buildStatsTab() {
    // Tính tổng doanh thu
    int totalRevenue = 0;
    for (final b in bookings) {
      totalRevenue += (b['totalPrice'] as num? ?? 0).toInt();
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: const Color(0xFF39FF14),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "HOẠT ĐỘNG HỆ THỐNG",
              style: TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2),
            ),
            const SizedBox(height: 15),

            // Hàng thẻ thống kê
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard("Doanh thu", formatter.format(totalRevenue), Icons.monetization_on, const Color(0xFF39FF14)),
                _buildStatCard("Vé đã bán", "${bookings.length} vé", Icons.local_activity, Colors.blueAccent),
                _buildStatCard("Tổng số phim", "${movies.length} phim", Icons.movie, Colors.orangeAccent),
                _buildStatCard("Tổng số rạp", "${cinemas.length} rạp", Icons.domain, Colors.purpleAccent),
              ],
            ),

            const SizedBox(height: 30),

            // Lịch sử giao dịch gần đây
            const Text(
              "VÉ ĐẶT GẦN ĐÂY",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),

            if (bookings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text("Chưa có giao dịch đặt vé nào.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length > 5 ? 5 : bookings.length,
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  final timeStr = b['bookingTime'] ?? "";
                  String dateFormatted = "";
                  try {
                    final date = DateTime.parse(timeStr);
                    dateFormatted = DateFormat("dd/MM/yyyy HH:mm").format(date);
                  } catch (e) {
                    dateFormatted = timeStr;
                  }

                  return Card(
                    color: const Color(0xFF121212),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(b['movieTitle'] ?? "N/A", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text("Ghế: ${(b['seats'] as List? ?? []).join(', ')} • Rạp: ${b['cinemaName']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatter.format(b['totalPrice'] ?? 0), style: const TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(dateFormatted, style: const TextStyle(color: Colors.white30, fontSize: 9)),
                        ],
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: MANAGE MOVIES
  // ==========================================
  Widget _buildMoviesTab() {
    final filteredMovies = movies.where((m) {
      return m.title.toLowerCase().contains(movieSearchQuery) ||
          m.genre.toLowerCase().contains(movieSearchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF39FF14),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditMoviePage()),
          );
          if (res == true) {
            _loadAllData();
          }
        },
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm phim dành cho Admin
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: TextField(
              controller: movieSearchController,
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFF39FF14),
              decoration: InputDecoration(
                hintText: "Tìm kiếm phim theo tên hoặc thể loại...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF39FF14)),
                suffixIcon: movieSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            movieSearchController.clear();
                            movieSearchQuery = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF121212),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Color(0xFF39FF14), width: 1.5),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  movieSearchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAllData,
              color: const Color(0xFF39FF14),
              child: filteredMovies.isEmpty
                  ? const Center(
                      child: Text(
                        "Không tìm thấy phim phù hợp",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredMovies.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemBuilder: (context, index) {
                        final movie = filteredMovies[index];
                        final statusLabel = movie.status == 'now_showing' ? 'Đang chiếu' : 'Sắp chiếu';
                        final statusColor = movie.status == 'now_showing' ? const Color(0xFF39FF14) : Colors.orangeAccent;

                        return Card(
                          color: const Color(0xFF121212),
                          margin: const EdgeInsets.only(bottom: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: movie.image.startsWith("http")
                                      ? Image.network(movie.image, width: 55, height: 75, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey, width: 55, height: 75))
                                      : Image.asset(movie.image, width: 55, height: 75, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey, width: 55, height: 75)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(movie.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(movie.genre, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(5)),
                                            child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 8),
                                          if (movie.isHot)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(5)),
                                              child: const Text("HOT", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () async {
                                    final res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => AddEditMoviePage(movie: movie)),
                                    );
                                    if (res == true) {
                                      _loadAllData();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteMovie(movie.id, movie.title),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: BOOKINGS LIST (HÓA ĐƠN)
  // ==========================================
  Widget _buildBookingsTab() {
    if (bookings.isEmpty) {
      return const Center(child: Text("Chưa có hóa đơn vé đặt nào.", style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: const Color(0xFF39FF14),
      child: ListView.builder(
        itemCount: bookings.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          final b = bookings[index];
          final timeStr = b['bookingTime'] ?? "";
          String dateFormatted = "";
          try {
            final date = DateTime.parse(timeStr);
            dateFormatted = DateFormat("dd/MM/yyyy HH:mm").format(date);
          } catch (e) {
            dateFormatted = timeStr;
          }

          final seats = List<String>.from(b['seats'] ?? []);

          return Card(
            color: const Color(0xFF121212),
            margin: const EdgeInsets.only(bottom: 14.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          b['movieTitle'] ?? "N/A",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formatter.format(b['totalPrice'] ?? 0),
                        style: const TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  _buildDetailRow("Rạp chiếu:", b['cinemaName'] ?? "N/A"),
                  _buildDetailRow("Suất chiếu:", b['showtime'] ?? "N/A"),
                  _buildDetailRow("Ghế đặt:", seats.join(', ')),
                  _buildDetailRow("User ID:", b['userId'] ?? "N/A"),
                  _buildDetailRow("Thời gian đặt:", dateFormatted),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: CINEMA MANAGEMENT
  // ==========================================
  Widget _buildCinemasTab() {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF39FF14),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditCinemaPage()),
          );
          if (res == true) _loadAllData();
        },
      ),
      body: cinemas.isEmpty
          ? const Center(child: Text("Không có rạp chiếu nào", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cinemas.length,
              itemBuilder: (context, index) {
                final c = cinemas[index];
                return Card(
                  color: const Color(0xFF121212),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white10),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: c.image.startsWith("http")
                              ? NetworkImage(c.image)
                              : AssetImage(c.image) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(c.address, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF39FF14), size: 20),
                          onPressed: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddEditCinemaPage(cinema: c)),
                            );
                            if (res == true) _loadAllData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteCinema(c.id, c.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ==========================================
  // TAB 5: VOUCHER MANAGEMENT
  // ==========================================
  Widget _buildVouchersTab() {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF39FF14),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVoucherPage()),
          );
          if (res == true) _loadAllData();
        },
      ),
      body: vouchers.isEmpty
          ? const Center(child: Text("Không có mã giảm giá nào", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                final v = vouchers[index];
                final code = v['code'] ?? "";
                final discount = (v['discountAmount'] ?? 0) as int;
                final minPrice = (v['minPrice'] ?? 0) as int;
                final active = (v['isActive'] ?? true) as bool;

                return Card(
                  color: const Color(0xFF121212),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.local_offer, color: Color(0xFF39FF14), size: 28),
                    title: Row(
                      children: [
                        Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: active ? const Color(0x334CAF50) : const Color(0x33F44336),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            active ? "Active" : "Inactive",
                            style: TextStyle(color: active ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Giảm: ${formatter.format(discount)}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        Text("Giá trị đơn tối thiểu: ${formatter.format(minPrice)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF39FF14), size: 20),
                          onPressed: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddVoucherPage(voucher: v)),
                            );
                            if (res == true) _loadAllData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteVoucher(v['id'], code),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
