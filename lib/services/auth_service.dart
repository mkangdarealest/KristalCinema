import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'preference_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ============================
  /// REGISTER
  /// ============================
  static Future<bool> register(UserModel user) async {
    try {
      // 1. Tạo tài khoản trong Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email.trim(),
        password: user.password,
      );

      final uid = userCredential.user?.uid;
      if (uid != null) {
        // 2. Lưu thông tin bổ sung lên Firestore
        await _firestore.collection('users').doc(uid).set(user.toFirestore());
        return true;
      }
      return false;
    } catch (e) {
      print("Register Error: $e");
      rethrow; // Ném ra ngoại lệ để màn hình hiển thị thông báo lỗi cụ thể
    }
  }

  /// ============================
  /// LOGIN
  /// ============================
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      String finalEmail = email.trim();
      if (!finalEmail.contains("@")) {
        finalEmail = "$finalEmail@kristalcinema.com";
      }

      // 1. Đăng nhập qua Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: finalEmail,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid != null) {
        // Kiểm tra xem user document đã tồn tại trên Firestore chưa
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final isAdmin = finalEmail.toLowerCase().startsWith("admin") || finalEmail.toLowerCase().contains("admin");
        if (!userDoc.exists) {
          // Tạo document thông tin cho admin/user mới nếu chưa có thông tin bổ sung
          final adminUser = UserModel(
            fullName: isAdmin ? "Admin Kristal" : "Người dùng Kristal",
            email: finalEmail,
            phone: "0123456789",
            password: "",
            avatar: "",
            gender: "Khác",
            city: "TP. Hồ Chí Minh",
            role: isAdmin ? "admin" : "user",
          );
          await _firestore.collection('users').doc(uid).set(adminUser.toFirestore());
        } else {
          // Nếu đã tồn tại nhưng chưa có role admin (phòng trường hợp tạo tài khoản thủ công qua Firebase Console)
          final data = userDoc.data();
          if (data != null && isAdmin && data['role'] != 'admin') {
            await _firestore.collection('users').doc(uid).update({'role': 'admin'});
          }
        }
      }

      // 2. Lưu lịch sử đăng nhập vào SharedPreferences cục bộ
      await PreferenceService.addHistory(finalEmail);
      await PreferenceService.setLogin(true);

      return true;
    } catch (e) {
      print("Login Error: $e");
      rethrow; // Ném ra ngoại lệ để xử lý hiển thị ở giao diện
    }
  }

  /// ============================
  /// USER HIỆN TẠI
  /// ============================
  static Future<UserModel?> currentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      // Lấy thông tin chi tiết từ Firestore
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Thêm trường email từ Firebase Auth nếu Firestore trống
        data['email'] = firebaseUser.email ?? "";
        data['password'] = ""; // Không lưu mật khẩu
        return UserModel.fromJson(data);
      } else {
        // Fallback tạo một UserModel cơ bản
        final userEmail = firebaseUser.email ?? "";
        final isAdmin = userEmail.toLowerCase().startsWith("admin") || userEmail.toLowerCase().contains("admin");
        return UserModel(
          fullName: firebaseUser.displayName ?? (isAdmin ? "Admin Kristal" : "Người dùng Kristal"),
          email: userEmail,
          phone: firebaseUser.phoneNumber ?? "",
          password: "",
          avatar: "",
          gender: "Khác",
          city: "TP. Hồ Chí Minh",
          role: isAdmin ? "admin" : "user",
        );
      }
    } catch (e) {
      print("Get Current User Error: $e");
      return null;
    }
  }

  /// ============================
  /// KIỂM TRA ĐĂNG NHẬP
  /// ============================
  static Future<bool> isLogin() async {
    return _auth.currentUser != null;
  }

  /// ============================
  /// LOGOUT
  /// ============================
  static Future<void> logout() async {
    await _auth.signOut();
    await PreferenceService.logout();
  }

  /// ============================
  /// LỊCH SỬ ĐĂNG NHẬP (Lưu cục bộ)
  /// ============================
  static Future<List<String>> getHistory() async {
    return await PreferenceService.getHistory();
  }

  /// ============================
  /// KIỂM TRA EMAIL ĐÃ TỒN TẠI
  /// ============================
  static Future<bool> isExistEmail(String email) async {
    try {
      final list = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .get();
      return list.docs.isNotEmpty;
    } catch (e) {
      print("Check Email Error: $e");
      return false;
    }
  }

  /// ============================
  /// UPDATE USER PROFILE INFO
  /// ============================
  static Future<bool> updateUserProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String city,
    required String avatar,
  }) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return false;

      final uid = firebaseUser.uid;
      final data = {
        'fullName': fullName.trim(),
        'phone': phone.trim(),
        'gender': gender.trim(),
        'city': city.trim(),
        'avatar': avatar.trim(),
      };

      await _firestore.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      print("Update User Profile Error: $e");
      return false;
    }
  }
}
