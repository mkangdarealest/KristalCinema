import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/movie_model.dart';
import '../models/cinema_model.dart';
import 'preference_service.dart';

class ApiService {
  // Cấu hình URL linh hoạt: Tự động nhận diện Android Emulator (10.0.2.2) hoặc Windows/Web/iOS (localhost)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static UserModel? _currentUser;
  static UserModel? get currentUser => _currentUser;

  // ==========================================
  // AUTHENTICATION
  // ==========================================

  /// Đăng ký tài khoản mới
  static Future<bool> register(UserModel user) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        if (data['data'] != null) {
          _currentUser = UserModel.fromJson(data['data']);
        }
        return true;
      }
      throw Exception(data['message'] ?? 'Đăng ký thất bại');
    } catch (e) {
      print('[ApiService.register] Error: $e');
      rethrow;
    }
  }

  /// Đăng nhập tài khoản
  static Future<bool> login({required String email, required String password}) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        _currentUser = UserModel.fromJson(data['data']);
        await PreferenceService.addHistory(_currentUser!.email);
        await PreferenceService.setLogin(true);
        return true;
      }
      throw Exception(data['message'] ?? 'Đăng nhập thất bại');
    } catch (e) {
      print('[ApiService.login] Error: $e');
      rethrow;
    }
  }

  /// Lấy thông tin người dùng hiện tại
  static Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final histories = await PreferenceService.getHistory();
      if (histories.isEmpty) return null;

      final lastEmail = histories.first;
      final url = Uri.parse('$baseUrl/auth/user?email=$lastEmail');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          _currentUser = UserModel.fromJson(data['data']);
          return _currentUser;
        }
      }
      return null;
    } catch (e) {
      print('[ApiService.getCurrentUser] Error: $e');
      return null;
    }
  }

  /// Cập nhật thông tin profile
  static Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String city,
    required String avatar,
  }) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      final url = Uri.parse('$baseUrl/auth/profile');
      final res = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user.id ?? user.email,
          'fullName': fullName,
          'phone': phone,
          'gender': gender,
          'city': city,
          'avatar': avatar,
        }),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        _currentUser = UserModel(
          id: user.id,
          fullName: fullName,
          email: user.email,
          phone: phone,
          password: user.password,
          avatar: avatar,
          gender: gender,
          city: city,
          role: user.role,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('[ApiService.updateProfile] Error: $e');
      return false;
    }
  }

  /// Kiểm tra email đã tồn tại chưa
  static Future<bool> isExistEmail(String email) async {
    try {
      final url = Uri.parse('$baseUrl/auth/check-email?email=${email.trim()}');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['exists'] == true;
      }
      return false;
    } catch (e) {
      print('[ApiService.isExistEmail] Error: $e');
      return false;
    }
  }

  /// Đăng xuất
  static Future<void> logout() async {
    _currentUser = null;
    await PreferenceService.logout();
  }

  // ==========================================
  // MOVIES
  // ==========================================

  /// Lấy danh sách phim
  static Future<List<Movie>> getMovies({String? status, String? keyword}) async {
    try {
      String path = '$baseUrl/movies';
      List<String> params = [];
      if (status != null) params.add('status=$status');
      if (keyword != null) params.add('keyword=${Uri.encodeComponent(keyword)}');
      if (params.isNotEmpty) path += '?${params.join('&')}';

      final res = await http.get(Uri.parse(path)).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final list = (body['data'] as List).map((m) => Movie.fromJson(m)).toList();
          if (list.isNotEmpty) return list;
        }
      }
      return Movie.mockMovies; // Fallback an toàn nếu chưa bật server
    } catch (e) {
      print('[ApiService.getMovies] Fallback mock movies: $e');
      return Movie.mockMovies;
    }
  }

  /// Lưu hoặc cập nhật phim (Admin)
  static Future<void> saveMovie(Movie movie) async {
    try {
      final url = Uri.parse('$baseUrl/movies');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(movie.toJson()),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Lỗi lưu phim');
      }
    } catch (e) {
      print('[ApiService.saveMovie] Error: $e');
      rethrow;
    }
  }

  /// Xóa phim (Admin)
  static Future<void> deleteMovie(String movieId) async {
    try {
      final url = Uri.parse('$baseUrl/movies/$movieId');
      final res = await http.delete(url);
      final data = jsonDecode(res.body);
      if (res.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Lỗi xóa phim');
      }
    } catch (e) {
      print('[ApiService.deleteMovie] Error: $e');
      rethrow;
    }
  }

  // ==========================================
  // CINEMAS
  // ==========================================

  /// Lấy danh sách cụm rạp
  static Future<List<Cinema>> getCinemas() async {
    try {
      final url = Uri.parse('$baseUrl/cinemas');
      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final list = (body['data'] as List).map((c) => Cinema.fromJson(c)).toList();
          if (list.isNotEmpty) return list;
        }
      }
      return Cinema.mockCinemas;
    } catch (e) {
      print('[ApiService.getCinemas] Fallback mock cinemas: $e');
      return Cinema.mockCinemas;
    }
  }

  /// Lưu hoặc cập nhật rạp chiếu (Admin)
  static Future<void> saveCinema(Cinema cinema) async {
    try {
      final url = Uri.parse('$baseUrl/cinemas');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(cinema.toJson()),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Lỗi lưu rạp');
      }
    } catch (e) {
      print('[ApiService.saveCinema] Error: $e');
      rethrow;
    }
  }

  /// Xóa rạp chiếu (Admin)
  static Future<void> deleteCinema(String cinemaId) async {
    try {
      final url = Uri.parse('$baseUrl/cinemas/$cinemaId');
      final res = await http.delete(url);
      final data = jsonDecode(res.body);
      if (res.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Lỗi xóa rạp');
      }
    } catch (e) {
      print('[ApiService.deleteCinema] Error: $e');
      rethrow;
    }
  }

  // ==========================================
  // SHOWTIME & SEATS & BOOKING
  // ==========================================

  /// Tạo ID suất chiếu đồng bộ với logic cũ
  static String getShowtimeId(String cinemaId, String movieId, String time) {
    return "${cinemaId}_${movieId}_${time.replaceAll(':', '_')}";
  }

  /// Lấy danh sách ghế đã đặt của một suất chiếu
  static Future<List<String>> getShowtimeSeats(String showtimeId) async {
    try {
      final url = Uri.parse('$baseUrl/bookings/seats/$showtimeId');
      final res = await http.get(url).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final booked = body['data']['bookedSeats'];
          if (booked is List) {
            return booked.map((e) => e.toString()).toList();
          }
        }
      }
      return ['C5', 'C6', 'D5', 'D6'];
    } catch (e) {
      return ['C5', 'C6', 'D5', 'D6'];
    }
  }

  /// Stream ghế thời gian thực cập nhật định kỳ mỗi 2 giây
  static Stream<List<String>> streamShowtimeSeats(String showtimeId) async* {
    yield await getShowtimeSeats(showtimeId);
    yield* Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => getShowtimeSeats(showtimeId));
  }

  /// Đặt vé (Gọi Package Oracle PKG_KRISTAL_BOOKING.SP_CONFIRM_BOOKING qua API)
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
    try {
      final url = Uri.parse('$baseUrl/bookings/confirm');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'movieTitle': movieTitle,
          'moviePoster': moviePoster,
          'cinemaName': cinemaName,
          'showtimeId': showtimeId,
          'showtimeTime': showtimeTime,
          'seats': seats,
          'totalPrice': totalPrice,
          'voucherCode': voucherCode,
          'discountAmount': discountAmount,
        }),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return true;
      }
      throw Exception(data['message'] ?? 'Đặt vé thất bại');
    } catch (e) {
      print('[ApiService.bookSeats] Error: $e');
      rethrow;
    }
  }

  /// Lấy lịch sử đặt vé của User
  static Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/bookings/user/$userId');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
      return [];
    } catch (e) {
      print('[ApiService.getUserBookings] Error: $e');
      return [];
    }
  }

  /// Lấy toàn bộ hóa đơn đặt vé (Admin)
  static Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final url = Uri.parse('$baseUrl/bookings/all');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
      return [];
    } catch (e) {
      print('[ApiService.getAllBookings] Error: $e');
      return [];
    }
  }

  // ==========================================
  // VOUCHERS
  // ==========================================

  /// Lấy danh sách Voucher
  static Future<List<Map<String, dynamic>>> getVouchers() async {
    try {
      final url = Uri.parse('$baseUrl/vouchers');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
      return [];
    } catch (e) {
      print('[ApiService.getVouchers] Error: $e');
      return [];
    }
  }

  /// Kiểm tra voucher hợp lệ
  static Future<Map<String, dynamic>?> verifyVoucher(String code) async {
    try {
      final url = Uri.parse('$baseUrl/vouchers/verify/${code.toUpperCase().trim()}');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          return Map<String, dynamic>.from(body['data']);
        }
      }
      return null;
    } catch (e) {
      print('[ApiService.verifyVoucher] Error: $e');
      return null;
    }
  }

  /// Lưu voucher (Admin)
  static Future<void> saveVoucher(Map<String, dynamic> voucherData) async {
    try {
      final url = Uri.parse('$baseUrl/vouchers');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(voucherData),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Lỗi lưu voucher');
      }
    } catch (e) {
      print('[ApiService.saveVoucher] Error: $e');
      rethrow;
    }
  }

  /// Xóa voucher (Admin)
  static Future<void> deleteVoucher(String voucherId) async {
    try {
      final url = Uri.parse('$baseUrl/vouchers/$voucherId');
      final res = await http.delete(url);
      final data = jsonDecode(res.body);
      if (res.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Lỗi xóa voucher');
      }
    } catch (e) {
      print('[ApiService.deleteVoucher] Error: $e');
      rethrow;
    }
  }

  // ==========================================
  // ADMIN STATISTICS
  // ==========================================

  /// Lấy thống kê tổng quan doanh thu từ Oracle PL/SQL
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final url = Uri.parse('$baseUrl/admin/statistics');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          return Map<String, dynamic>.from(body['data']);
        }
      }
      return {'totalRevenue': 0, 'totalBookings': 0, 'totalMovies': 0, 'totalCinemas': 0};
    } catch (e) {
      print('[ApiService.getStatistics] Error: $e');
      return {'totalRevenue': 0, 'totalBookings': 0, 'totalMovies': 0, 'totalCinemas': 0};
    }
  }
}
