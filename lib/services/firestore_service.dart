import 'dart:async';
import '../models/movie_model.dart';
import '../models/cinema_model.dart';
import 'api_service.dart';

/// Lớp adapter tương thích cấu trúc DocumentSnapshot cũ để giữ nguyên 100% UI StreamBuilder
class DocumentSnapshot {
  final Map<String, dynamic>? _data;
  final bool exists;
  DocumentSnapshot(this._data, {this.exists = true});
  Map<String, dynamic>? data() => _data;
}

class FirestoreService {
  // ==========================================
  // MOVIES
  // ==========================================
  static Future<List<Movie>> getMovies() async {
    return await ApiService.getMovies();
  }

  static Future<void> saveMovie(Movie movie) async {
    await ApiService.saveMovie(movie);
  }

  static Future<void> deleteMovie(String movieId) async {
    await ApiService.deleteMovie(movieId);
  }

  // ==========================================
  // CINEMAS
  // ==========================================
  static Future<List<Cinema>> getCinemas() async {
    return await ApiService.getCinemas();
  }

  static Future<void> saveCinema(Cinema cinema) async {
    await ApiService.saveCinema(cinema);
  }

  static Future<void> deleteCinema(String cinemaId) async {
    await ApiService.deleteCinema(cinemaId);
  }

  // ==========================================
  // SHOWTIME SEATS & STREAM
  // ==========================================
  static String getShowtimeId(String cinemaId, String movieId, String time) {
    return ApiService.getShowtimeId(cinemaId, movieId, time);
  }

  static Stream<DocumentSnapshot> streamShowtimeSeats(String showtimeId) {
    return ApiService.streamShowtimeSeats(showtimeId).map((seats) {
      return DocumentSnapshot({'bookedSeats': seats}, exists: true);
    });
  }

  // ==========================================
  // BOOKINGS (ORACLE PL/SQL VIA REST API)
  // ==========================================
  static Future<bool> bookSeats({
    required String userId,
    required String movieTitle,
    required String moviePoster,
    required String cinemaName,
    required String showtimeId,
    required String showtimeTime,
    required List<String> seats,
    required int totalPrice,
    String? voucherCode,
    int? discountAmount,
  }) async {
    return await ApiService.bookSeats(
      userId: userId,
      movieTitle: movieTitle,
      moviePoster: moviePoster,
      cinemaName: cinemaName,
      showtimeId: showtimeId,
      showtimeTime: showtimeTime,
      seats: seats,
      totalPrice: totalPrice,
      voucherCode: voucherCode,
      discountAmount: discountAmount,
    );
  }

  static Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    return await ApiService.getUserBookings(userId);
  }

  static Future<List<Map<String, dynamic>>> getAllBookings() async {
    return await ApiService.getAllBookings();
  }

  static Future<void> seedDatabase() async {
    print('[FirestoreService] Seeded data handled via Oracle Database 23ai scripts.');
  }

  // ==========================================
  // VOUCHERS
  // ==========================================
  static Future<List<Map<String, dynamic>>> getVouchers() async {
    return await ApiService.getVouchers();
  }

  static Future<void> saveVoucher(Map<String, dynamic> voucherData) async {
    await ApiService.saveVoucher(voucherData);
  }

  static Future<void> deleteVoucher(String voucherId) async {
    await ApiService.deleteVoucher(voucherId);
  }

  static Future<Map<String, dynamic>?> verifyVoucher(String code) async {
    return await ApiService.verifyVoucher(code);
  }
}
