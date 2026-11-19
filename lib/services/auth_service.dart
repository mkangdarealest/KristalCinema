import '../models/user_model.dart';
import 'api_service.dart';
import 'preference_service.dart';

class AuthService {
  /// Đăng ký tài khoản
  static Future<bool> register(UserModel user) async {
    return await ApiService.register(user);
  }

  /// Đăng nhập
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    return await ApiService.login(email: email, password: password);
  }

  /// Lấy thông tin người dùng hiện tại
  static Future<UserModel?> currentUser() async {
    return await ApiService.getCurrentUser();
  }

  /// Kiểm tra trạng thái đăng nhập
  static Future<bool> isLogin() async {
    final user = await ApiService.getCurrentUser();
    return user != null;
  }

  /// Đăng xuất
  static Future<void> logout() async {
    await ApiService.logout();
  }

  /// Lịch sử đăng nhập (Lưu cục bộ thiết bị)
  static Future<List<String>> getHistory() async {
    return await PreferenceService.getHistory();
  }

  /// Kiểm tra email đã tồn tại hay chưa
  static Future<bool> isExistEmail(String email) async {
    return await ApiService.isExistEmail(email);
  }

  /// Cập nhật thông tin profile người dùng
  static Future<bool> updateUserProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String city,
    required String avatar,
  }) async {
    return await ApiService.updateProfile(
      fullName: fullName,
      phone: phone,
      gender: gender,
      city: city,
      avatar: avatar,
    );
  }
}
