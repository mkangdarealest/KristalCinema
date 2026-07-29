import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class PreferenceService {
  //=============================
  // KEY
  //=============================
  static const String loginKey = "isLogin";
  static const String userKey = "user";
  static const String historyKey = "history";

  //=============================
  // SAVE USER
  //=============================
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(userKey, jsonEncode(user.toJson()));
    // in ra màn hình để test
    print("===== SAVE USER =====");
    print("Name     : ${user.fullName}");
    print("Email    : ${user.email}");
    print("Password : ${user.password}");
    print("=====================");
  }

  //=============================
  // GET USER
  //=============================
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    String? json = prefs.getString(userKey);

    if (json == null) {
      return null;
    }

    UserModel user = UserModel.fromJson(jsonDecode(json));

    print("===== LOAD USER =====");
    print("Name     : ${user.fullName}");
    print("Email    : ${user.email}");
    print("=====================");

    return user;
  }

  //=============================
  // LOGIN
  //=============================
  static Future<void> setLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(loginKey, value);
  }

  //=============================
  // CHECK LOGIN
  //=============================
  static Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(loginKey) ?? false;
  }

  //=============================
  // LOGOUT
  //=============================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(loginKey, false);
  }

  //=============================
  // PROFILE
  //=============================
  static Future<Map<String, String>> getProfile() async {
    UserModel? user = await getUser();

    if (user == null) {
      return {};
    }

    return {
      "fullName": user.fullName,
      "email": user.email,
      "phone": user.phone,
      "avatar": user.avatar,
      "gender": user.gender,
      "city": user.city,
    };
  }

  //=============================
  // LOGIN HISTORY
  //=============================
  static Future<void> addHistory(String info) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> history = prefs.getStringList(historyKey) ?? [];

    history.insert(0, "$info | ${DateTime.now()}");

    await prefs.setStringList(historyKey, history);
  }

  //=============================
  // GET HISTORY
  //=============================
  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(historyKey) ?? [];
  }

  //=============================
  // HAS USER
  //=============================
  static Future<bool> hasUser() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(userKey);
  }

  //=============================
  // CLEAR HISTORY
  //=============================
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(historyKey);
  }

  //=============================
  // UPDATE USER
  //=============================
  static Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }

  //=============================
  // REMEMBER ME
  //=============================
  static const String rememberMeKey = "rememberMe";

  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(rememberMeKey, value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(rememberMeKey) ?? false;
  }

  //=============================
  // SETTINGS
  //=============================
  static const String darkModeKey = "darkMode";
  static const String emailNotifyKey = "emailNotify";
  static const String pushNotifyKey = "pushNotify";

  static Future<void> saveSettings({
    required bool darkMode,
    required bool emailNotify,
    required bool pushNotify,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, darkMode);
    await prefs.setBool(emailNotifyKey, emailNotify);
    await prefs.setBool(pushNotifyKey, pushNotify);
  }

  static Future<Map<String, bool>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "darkMode": prefs.getBool(darkModeKey) ?? false,
      "emailNotify": prefs.getBool(emailNotifyKey) ?? true,
      "pushNotify": prefs.getBool(pushNotifyKey) ?? true,
    };
  }

  //=============================
  // TICKET BOOKING HISTORY
  //=============================
  static const String ticketHistoryKey = "bookingHistory";

  static Future<void> addTicket(Map<String, dynamic> ticketData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(ticketHistoryKey) ?? [];
    list.insert(0, jsonEncode(ticketData));
    await prefs.setStringList(ticketHistoryKey, list);
  }

  static Future<List<Map<String, dynamic>>> getTickets() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(ticketHistoryKey) ?? [];
    return list.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  static Future<void> clearTickets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ticketHistoryKey);
  }
}
