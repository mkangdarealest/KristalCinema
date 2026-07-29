import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/movie_model.dart';
import '../../models/cinema_model.dart';
import '../../services/firestore_service.dart';
import 'main_page.dart';

class BookingPage extends StatefulWidget {
  final Movie movie;
  final Cinema? initialCinema;
  final String? initialTime;

  const BookingPage({
    super.key,
    required this.movie,
    this.initialCinema,
    this.initialTime,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int currentStep = 1; // 1: Mall & Showtime, 2: Seat Selection

  Cinema? selectedCinema;
  String? selectedTime;

  List<String> selectedSeats = [];
  List<Cinema> cinemas = [];
  bool isLoadingCinemas = true;
  final List<String> vipRows = ["D", "E", "F"];

  final TextEditingController voucherController = TextEditingController();
  String? appliedVoucherCode;
  int voucherDiscount = 0;
  int? voucherMinPrice;
  bool isApplyingVoucher = false;

  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    selectedCinema = widget.initialCinema;
    selectedTime = widget.initialTime;
    if (selectedCinema != null && selectedTime != null) {
      currentStep = 2; // Jump directly to seat selection
    }
    loadCinemas();
  }

  @override
  void dispose() {
    voucherController.dispose();
    super.dispose();
  }

  int get finalPrice {
    final sum = ticketPriceSum;
    final priceAfterDiscount = sum - voucherDiscount;
    return priceAfterDiscount < 0 ? 0 : priceAfterDiscount;
  }

  Future<void> loadCinemas() async {
    final list = await FirestoreService.getCinemas();
    if (!mounted) return;
    setState(() {
      cinemas = list;
      isLoadingCinemas = false;
      if (selectedCinema != null) {
        selectedCinema = cinemas.firstWhere(
          (c) => c.id == selectedCinema!.id,
          orElse: () => selectedCinema!,
        );
      }
    });
  }

  int get ticketPriceSum {
    int total = 0;
    for (String seat in selectedSeats) {
      String row = seat.substring(0, 1);
      if (vipRows.contains(row)) {
        total += 110000;
      } else {
        total += 80000;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          currentStep == 1 ? "Chọn Rạp & Suất Chiếu" : "Chọn Ghế Ngồi",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFF39FF14),
      ),
      body: currentStep == 1 ? _buildStep1() : _buildStep2(),
    );
  }

  //-----------------------------------------
  // STEP 1: CINEMA & SHOWTIME SELECTION
  //-----------------------------------------
  Widget _buildStep1() {
    return Column(
      children: [
        // Movie mini banner
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF121212),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(widget.movie.image, width: 80, height: 110, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.movie.genre,
                      style: const TextStyle(color: Color(0xFF39FF14), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.movie.duration,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // List of cinemas
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Chọn Rạp Chiếu",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        Expanded(
          child: isLoadingCinemas
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF39FF14),
                  ),
                )
              : ListView.builder(
                  itemCount: cinemas.length,
                  itemBuilder: (context, index) {
                    final cinema = cinemas[index];
              final isSelected = selectedCinema?.id == cinema.id;

              return Card(
                color: isSelected ? const Color(0xFF1E3A1E) : const Color(0xFF121212),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF39FF14) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedCinema = cinema;
                      selectedTime = null; // Reset time when mall changes
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(cinema.image, width: 70, height: 70, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cinema.name,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cinema.address,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
        ),

        // Showtimes selection (visible if a cinema is selected)
        if (selectedCinema != null) ...[
          const Divider(color: Colors.white24, height: 1),
          Container(
            color: const Color(0xFF121212),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chọn Suất Chiếu",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedCinema!.showtimes.length,
                    itemBuilder: (context, index) {
                      final time = selectedCinema!.showtimes[index];
                      final isTimeSelected = selectedTime == time;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            time,
                            style: TextStyle(
                              color: isTimeSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isTimeSelected,
                          selectedColor: const Color(0xFF39FF14),
                          backgroundColor: Colors.grey.shade900,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedTime = selected ? time : null;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],

        // Bottom continue bar
        Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (selectedCinema == null || selectedTime == null)
                  ? null
                  : () {
                      setState(() {
                        currentStep = 2;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF39FF14),
                disabledBackgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "CHỌN GHẾ NGỒI",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //-----------------------------------------
  // STEP 2: SEAT SELECTION GRID
  //-----------------------------------------
  Widget _buildStep2() {
    final showtimeId = FirestoreService.getShowtimeId(selectedCinema!.id, widget.movie.id, selectedTime!);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirestoreService.streamShowtimeSeats(showtimeId),
      builder: (context, snapshot) {
        List<String> currentBookedSeats = [];
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data['bookedSeats'] != null) {
            currentBookedSeats = List<String>.from(data['bookedSeats']);
          }
        }

        return Column(
          children: [
            // Top screen details
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: const Color(0xFF121212),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedCinema?.name ?? "",
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "Giờ chiếu: $selectedTime",
                    style: const TextStyle(color: Color(0xFF39FF14), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Screen Indicator
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF39FF14),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF39FF14).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "MÀN HÌNH",
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 5),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Seat layout
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: List.generate(8, (rowIndex) {
                        final rowLetter = String.fromCharCode(65 + rowIndex); // A, B, C...
                        final isVipRow = vipRows.contains(rowLetter);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              // Row label left
                              SizedBox(
                                width: 20,
                                child: Text(
                                  rowLetter,
                                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Left block (seats 1-2)
                              Row(
                                children: List.generate(2, (colIndex) {
                                  final seatCode = "$rowLetter${colIndex + 1}";
                                  return _buildSeatCell(seatCode, isVipRow, currentBookedSeats);
                                }),
                              ),
                              const SizedBox(width: 15), // Gap

                              // Middle block (seats 3-8)
                              Row(
                                children: List.generate(6, (colIndex) {
                                  final seatCode = "$rowLetter${colIndex + 3}";
                                  return _buildSeatCell(seatCode, isVipRow, currentBookedSeats);
                                }),
                              ),
                              const SizedBox(width: 15), // Gap

                              // Right block (seats 9-10)
                              Row(
                                children: List.generate(2, (colIndex) {
                                  final seatCode = "$rowLetter${colIndex + 9}";
                                  return _buildSeatCell(seatCode, isVipRow, currentBookedSeats);
                                }),
                              ),

                              const SizedBox(width: 8),
                              // Row label right
                              SizedBox(
                                width: 20,
                                child: Text(
                                  rowLetter,
                                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),

            // Legend details
            Container(
              color: const Color(0xFF121212),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(Colors.grey.shade800, "Đã đặt"),
                  _buildLegendItem(const Color(0xFF39FF14), "Bạn chọn"),
                  _buildLegendItem(Colors.grey.shade400, "Thường"),
                  _buildLegendItem(Colors.pinkAccent, "Ghế VIP"),
                ],
              ),
            ),

            // Subtotal, voucher & continue button
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Nhập Voucher (chỉ hiển thị khi đã chọn ít nhất 1 ghế)
                  if (selectedSeats.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: voucherController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: "Nhập mã Voucher...",
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                                filled: true,
                                fillColor: const Color(0xFF121212),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF39FF14),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            onPressed: isApplyingVoucher ? null : _applyVoucher,
                            child: isApplyingVoucher
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                : const Text("Áp dụng", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedSeats.isEmpty ? "Chưa chọn ghế" : "Ghế: ${selectedSeats.join(', ')}",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (voucherDiscount > 0) ...[
                            Row(
                              children: [
                                const Text("Tạm tính: ", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                Text(
                                  formatter.format(ticketPriceSum),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Text("Giảm giá: ", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                Text(
                                  "- ${formatter.format(voucherDiscount)}",
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                          ],
                          Row(
                            children: [
                              Text(voucherDiscount > 0 ? "Tổng thanh toán: " : "Tạm tính: ", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                formatter.format(finalPrice),
                                style: const TextStyle(color: Color(0xFF39FF14), fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                currentStep = 1;
                                selectedSeats.clear();
                                appliedVoucherCode = null;
                                voucherDiscount = 0;
                                voucherMinPrice = null;
                                voucherController.clear();
                              });
                            },
                            child: const Text("Quay lại", style: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: selectedSeats.isEmpty ? null : _confirmBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF39FF14),
                              disabledBackgroundColor: Colors.grey.shade800,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            child: const Text("ĐẶT VÉ", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeatCell(String seatCode, bool isVip, List<String> currentBookedSeats) {
    final isBooked = currentBookedSeats.contains(seatCode);
    final isSelected = selectedSeats.contains(seatCode);

    Color seatColor = Colors.grey.shade400; // Regular
    if (isBooked) {
      seatColor = Colors.grey.shade800;
    } else if (isSelected) {
      seatColor = const Color(0xFF39FF14);
    } else if (isVip) {
      seatColor = Colors.pinkAccent;
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: InkWell(
        onTap: isBooked
            ? null
            : () {
                setState(() {
                  if (isSelected) {
                    selectedSeats.remove(seatCode);
                  } else {
                    selectedSeats.add(seatCode);
                  }

                  // Kiểm tra lại voucher động nếu có mã đang áp dụng
                  if (appliedVoucherCode != null && voucherMinPrice != null) {
                    if (ticketPriceSum < voucherMinPrice!) {
                      appliedVoucherCode = null;
                      voucherDiscount = 0;
                      voucherMinPrice = null;
                      voucherController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã hủy áp dụng voucher do tổng giá trị ghế đã chọn không còn đạt điều kiện tối thiểu."),
                          backgroundColor: Colors.orangeAccent,
                        ),
                      );
                    }
                  }
                });
              },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: seatColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: isBooked
              ? const Icon(Icons.close, size: 14, color: Colors.white54)
              : Text(
                  seatCode,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(color == const Color(0xFF39FF14) ? text : text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Future<void> _applyVoucher() async {
    final code = voucherController.text.trim();
    if (code.isEmpty) return;

    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn ghế trước khi áp dụng mã giảm giá!"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      isApplyingVoucher = true;
    });

    try {
      final voucher = await FirestoreService.verifyVoucher(code);
      if (!mounted) return;

      if (voucher == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mã giảm giá không hợp lệ hoặc đã hết hạn!"), backgroundColor: Colors.redAccent),
        );
        setState(() {
          appliedVoucherCode = null;
          voucherDiscount = 0;
          voucherMinPrice = null;
        });
        return;
      }

      final minPrice = (voucher['minPrice'] as num).toInt();
      final discount = (voucher['discountAmount'] as num).toInt();

      if (ticketPriceSum < minPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Chưa đạt giá trị đơn hàng tối thiểu từ ${formatter.format(minPrice)} để áp dụng mã này!"),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() {
          appliedVoucherCode = null;
          voucherDiscount = 0;
          voucherMinPrice = null;
        });
        return;
      }

      setState(() {
        appliedVoucherCode = voucher['code'];
        voucherDiscount = discount;
        voucherMinPrice = minPrice;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Áp dụng mã thành công! Bạn được giảm ${formatter.format(discount)}."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi áp dụng voucher: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isApplyingVoucher = false;
        });
      }
    }
  }

  //-----------------------------------------
  // BOOKING CONFIRMATION & DIALOG
  //-----------------------------------------
  Future<void> _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bạn cần đăng nhập để thực hiện đặt vé."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Hiển thị loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF39FF14),
        ),
      ),
    );

    final showtimeId = FirestoreService.getShowtimeId(selectedCinema!.id, widget.movie.id, selectedTime!);

    try {
      bool success = await FirestoreService.bookSeats(
        userId: user.uid,
        movieTitle: widget.movie.title,
        moviePoster: widget.movie.image,
        cinemaName: selectedCinema!.name,
        showtimeId: showtimeId,
        showtimeTime: selectedTime!,
        seats: selectedSeats,
        totalPrice: finalPrice,
        voucherCode: appliedVoucherCode,
        discountAmount: voucherDiscount > 0 ? voucherDiscount : null,
      );

      // Tắt loading dialog
      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF39FF14), size: 30),
                  SizedBox(width: 10),
                  Text("Đặt Vé Thành Công", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cảm ơn bạn đã mua vé tại KristalCinema!", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  _buildDialogInfoRow("Phim:", widget.movie.title),
                  _buildDialogInfoRow("Rạp:", selectedCinema!.name),
                  _buildDialogInfoRow("Suất chiếu:", selectedTime!),
                  _buildDialogInfoRow("Ghế đã chọn:", selectedSeats.join(', ')),
                  if (voucherDiscount > 0)
                    _buildDialogInfoRow("Giảm giá:", "- ${formatter.format(voucherDiscount)}"),
                  _buildDialogInfoRow("Tổng thanh toán:", formatter.format(finalPrice)),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss dialog
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainPage()),
                      (route) => false,
                    ); // Back to Home/MainPage
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39FF14),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Tắt loading dialog nếu bị lỗi
      if (mounted) Navigator.pop(context);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi đặt vé: ${e.toString().replaceAll("Exception: ", "")}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
