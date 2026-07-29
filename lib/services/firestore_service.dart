import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';
import '../models/cinema_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  static final CollectionReference _moviesRef = _db.collection('movies');
  static final CollectionReference _cinemasRef = _db.collection('cinemas');
  static final CollectionReference _bookingsRef = _db.collection('bookings');
  static final CollectionReference _showtimesRef = _db.collection('showtimes');

  // ==========================================
  // MOVIES
  // ==========================================
  static Future<List<Movie>> getMovies() async {
    try {
      final snapshot = await _moviesRef.get();
      if (snapshot.docs.isEmpty) {
        // Nếu DB rỗng, trả về dữ liệu mock tạm thời
        return Movie.mockMovies;
      }
      return snapshot.docs.map((doc) {
        return Movie.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching movies: $e");
      return Movie.mockMovies; // Fallback
    }
  }

  // ==========================================
  // CINEMAS
  // ==========================================
  static Future<List<Cinema>> getCinemas() async {
    try {
      final snapshot = await _cinemasRef.get();
      if (snapshot.docs.isEmpty) {
        // Nếu DB rỗng, trả về dữ liệu mock tạm thời
        return Cinema.mockCinemas;
      }
      return snapshot.docs.map((doc) {
        return Cinema.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching cinemas: $e");
      return Cinema.mockCinemas; // Fallback
    }
  }

  // ==========================================
  // SHOWTIME SEATS STATUS
  // ==========================================
  static String getShowtimeId(String cinemaId, String movieId, String time) {
    return "${cinemaId}_${movieId}_${time.replaceAll(':', '_')}";
  }

  static Stream<DocumentSnapshot> streamShowtimeSeats(String showtimeId) {
    return _showtimesRef.doc(showtimeId).snapshots();
  }

  // ==========================================
  // BOOKING (TRANSACTION)
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
    final showtimeDocRef = _showtimesRef.doc(showtimeId);

    try {
      return await _db.runTransaction((transaction) async {
        final showtimeSnapshot = await transaction.get(showtimeDocRef);
        List<String> bookedSeats = [];

        if (showtimeSnapshot.exists) {
          final data = showtimeSnapshot.data() as Map<String, dynamic>?;
          if (data != null && data['bookedSeats'] != null) {
            bookedSeats = List<String>.from(data['bookedSeats']);
          }
        }

        // Kiểm tra xem ghế đã có người đặt chưa
        for (final seat in seats) {
          if (bookedSeats.contains(seat)) {
            throw Exception("Ghế $seat đã bị người khác đặt trước mất rồi.");
          }
        }

        // Cập nhật danh sách ghế đã đặt cho suất chiếu
        bookedSeats.addAll(seats);
        transaction.set(showtimeDocRef, {
          'bookedSeats': bookedSeats,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Lưu thông tin hóa đơn đặt vé
        final newBookingRef = _bookingsRef.doc();
        transaction.set(newBookingRef, {
          'userId': userId,
          'movieTitle': movieTitle,
          'moviePoster': moviePoster,
          'cinemaName': cinemaName,
          'showtime': showtimeTime,
          'seats': seats,
          'totalPrice': totalPrice,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'success',
          if (voucherCode != null) 'voucherCode': voucherCode,
          if (discountAmount != null) 'discountAmount': discountAmount,
        });

        return true;
      });
    } catch (e) {
      print("Transaction Error: $e");
      rethrow;
    }
  }

  // ==========================================
  // USER BOOKINGS HISTORY
  // ==========================================
  static Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final snapshot = await _bookingsRef
          .where('userId', isEqualTo: userId)
          .get(); // Có thể thêm orderBy sau khi tạo Index trên console

      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Chuyển đổi Timestamp sang String định dạng ISO để đồng bộ với PreferenceService cũ
        if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
          data['bookingTime'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        } else {
          data['bookingTime'] = DateTime.now().toIso8601String();
        }
        return data;
      }).toList();

      // Sắp xếp thủ công theo thời gian giảm dần (để tránh yêu cầu tạo Index Firestore của Firebase ngay lập tức)
      list.sort((a, b) {
        final tA = DateTime.parse(a['bookingTime']);
        final tB = DateTime.parse(b['bookingTime']);
        return tB.compareTo(tA);
      });

      return list;
    } catch (e) {
      print("Error fetching user bookings: $e");
      return [];
    }
  }

  // ==========================================
  // SEED MOCK DATA
  // ==========================================
  static Future<void> seedDatabase() async {
    final batch = _db.batch();

    // 1. Nạp phim mẫu
    for (final movie in Movie.mockMovies) {
      final docRef = _moviesRef.doc(movie.id);
      batch.set(docRef, movie.toFirestore());
    }

    // 2. Nạp rạp chiếu mẫu
    for (final cinema in Cinema.mockCinemas) {
      final docRef = _cinemasRef.doc(cinema.id);
      batch.set(docRef, cinema.toFirestore());
    }

    await batch.commit();
    print("Seeded Movies and Cinemas to Firestore!");
  }

  // ==========================================
  // ADMIN FUNCTIONS
  // ==========================================
  
  /// Lấy toàn bộ danh sách vé đặt trên hệ thống (cho Admin)
  static Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final snapshot = await _bookingsRef.get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
          data['bookingTime'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        } else {
          data['bookingTime'] = DateTime.now().toIso8601String();
        }
        return data;
      }).toList();

      // Sắp xếp theo ngày đặt giảm dần
      list.sort((a, b) {
        final tA = DateTime.parse(a['bookingTime']);
        final tB = DateTime.parse(b['bookingTime']);
        return tB.compareTo(tA);
      });

      return list;
    } catch (e) {
      print("Error fetching all bookings: $e");
      return [];
    }
  }

  /// Xóa phim khỏi Firestore
  static Future<void> deleteMovie(String movieId) async {
    try {
      await _moviesRef.doc(movieId).delete();
    } catch (e) {
      print("Error deleting movie: $e");
      rethrow;
    }
  }

  /// Lưu phim (Thêm mới nếu id trống, cập nhật nếu đã có id)
  static Future<void> saveMovie(Movie movie) async {
    try {
      if (movie.id.isEmpty) {
        final docRef = _moviesRef.doc();
        final newMovie = Movie(
          id: docRef.id,
          title: movie.title,
          image: movie.image,
          isHot: movie.isHot,
          rating: movie.rating,
          duration: movie.duration,
          genre: movie.genre,
          synopsis: movie.synopsis,
          status: movie.status,
        );
        await docRef.set(newMovie.toFirestore());
      } else {
        await _moviesRef.doc(movie.id).set(movie.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      print("Error saving movie: $e");
      rethrow;
    }
  }

  // ==========================================
  // ADMIN CINEMA FUNCTIONS
  // ==========================================

  /// Lưu rạp chiếu (Thêm mới nếu id trống, cập nhật nếu đã có id)
  static Future<void> saveCinema(Cinema cinema) async {
    try {
      if (cinema.id.isEmpty) {
        final docRef = _cinemasRef.doc();
        final newCinema = Cinema(
          id: docRef.id,
          name: cinema.name,
          address: cinema.address,
          image: cinema.image,
          showtimes: cinema.showtimes.isEmpty ? ["09:30", "13:30", "16:00", "19:30", "22:00"] : cinema.showtimes,
        );
        await docRef.set(newCinema.toFirestore());
      } else {
        await _cinemasRef.doc(cinema.id).set(cinema.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      print("Error saving cinema: $e");
      rethrow;
    }
  }

  /// Xóa rạp chiếu khỏi Firestore
  static Future<void> deleteCinema(String cinemaId) async {
    try {
      await _cinemasRef.doc(cinemaId).delete();
    } catch (e) {
      print("Error deleting cinema: $e");
      rethrow;
    }
  }

  // ==========================================
  // VOUCHER FUNCTIONS
  // ==========================================

  /// Lấy danh sách Voucher hoạt động
  static Future<List<Map<String, dynamic>>> getVouchers() async {
    try {
      final snapshot = await _db.collection('vouchers').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching vouchers: $e");
      return [];
    }
  }

  /// Tạo hoặc sửa Voucher
  static Future<void> saveVoucher(Map<String, dynamic> voucherData) async {
    try {
      final code = (voucherData['code'] as String).toUpperCase().trim();
      final id = voucherData['id'] as String? ?? "";
      final data = {
        'code': code,
        'discountAmount': (voucherData['discountAmount'] as num).toInt(),
        'minPrice': (voucherData['minPrice'] as num).toInt(),
        'isActive': voucherData['isActive'] ?? true,
      };

      if (id.isEmpty) {
        await _db.collection('vouchers').add(data);
      } else {
        await _db.collection('vouchers').doc(id).set(data, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error saving voucher: $e");
      rethrow;
    }
  }

  /// Xóa Voucher khỏi Firestore
  static Future<void> deleteVoucher(String voucherId) async {
    try {
      await _db.collection('vouchers').doc(voucherId).delete();
    } catch (e) {
      print("Error deleting voucher: $e");
      rethrow;
    }
  }

  /// Xác thực mã voucher có hợp lệ hay không khi khách hàng thanh toán
  static Future<Map<String, dynamic>?> verifyVoucher(String code) async {
    try {
      final query = await _db
          .collection('vouchers')
          .where('code', isEqualTo: code.toUpperCase().trim())
          .where('isActive', isEqualTo: true)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      final doc = query.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    } catch (e) {
      print("Error verifying voucher: $e");
      return null;
    }
  }
}
