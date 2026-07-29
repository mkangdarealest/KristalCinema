import 'package:flutter/material.dart';
import '../../services/preference_service.dart';
import '../../services/auth_service.dart';
import '../auth_pages/login_page.dart';
import '../admin_pages/admin_dashboard_page.dart';
import '../widgets/logo_header.dart';

class ProfileSettingPage extends StatefulWidget {
  const ProfileSettingPage({super.key});

  @override
  State<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  // Profile Data
  String fullName = "Guest";
  String email = "";
  String phone = "";
  String gender = "";
  String city = "";
  String avatar = "";
  String role = "user";

  // Settings Data
  bool emailNotify = true;
  bool pushNotify = true;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final user = await AuthService.currentUser();
    final settings = await PreferenceService.getSettings();

    setState(() {
      fullName = user?.fullName ?? "Guest";
      email = user?.email ?? "";
      phone = user?.phone ?? "";
      gender = user?.gender ?? "Chưa thiết lập";
      city = user?.city ?? "Chưa thiết lập";
      avatar = user?.avatar ?? "";
      role = user?.role ?? "user";

      emailNotify = settings["emailNotify"] ?? true;
      pushNotify = settings["pushNotify"] ?? true;

      isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await PreferenceService.saveSettings(
      darkMode: false,
      emailNotify: emailNotify,
      pushNotify: pushNotify,
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _openEditProfileDialog() {
    final nameCtrl = TextEditingController(text: fullName);
    final phoneCtrl = TextEditingController(text: phone);
    final cityCtrl = TextEditingController(text: city);
    final avatarCtrl = TextEditingController(text: avatar);
    String selectedGender = gender;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                "Chỉnh sửa thông tin",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Họ và tên",
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF39FF14))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại",
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF39FF14))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cityCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Thành phố",
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF39FF14))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: avatarCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Đường dẫn ảnh đại diện (URL)",
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF39FF14))),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Giới tính:", style: TextStyle(color: Colors.grey)),
                        DropdownButton<String>(
                          value: ["Nam", "Nữ", "Khác"].contains(selectedGender) ? selectedGender : "Khác",
                          dropdownColor: const Color(0xFF1C1C1C),
                          style: const TextStyle(color: Colors.white),
                          iconEnabledColor: const Color(0xFF39FF14),
                          underline: Container(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setDialogState(() {
                                selectedGender = newValue;
                              });
                            }
                          },
                          items: <String>["Nam", "Nữ", "Khác"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("HỦY", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39FF14),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    
                    setState(() {
                      isLoading = true;
                    });
                    
                    final success = await AuthService.updateUserProfile(
                      fullName: nameCtrl.text,
                      phone: phoneCtrl.text,
                      gender: selectedGender,
                      city: cityCtrl.text,
                      avatar: avatarCtrl.text,
                    );
                    
                    if (success) {
                      _loadAllData();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cập nhật thông tin thành công!"), backgroundColor: Colors.green),
                      );
                    } else {
                      if (!context.mounted) return;
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lỗi cập nhật thông tin"), backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                  child: const Text("LƯU", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF39FF14))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo Header
              const LogoHeader(height: 50),

              // Profile Section Card
              Card(
                color: const Color(0xFF121212),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white12,
                        backgroundImage: avatar.isNotEmpty && avatar.startsWith("http")
                            ? NetworkImage(avatar)
                            : null,
                        child: avatar.isEmpty || !avatar.startsWith("http")
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _openEditProfileDialog,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text("Chỉnh sửa thông tin", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0x14FFFFFF),
                          foregroundColor: const Color(0xFF39FF14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 10),

                      // Compact Info details
                      _buildInfoRow(Icons.phone, "Số điện thoại", phone),
                      _buildInfoRow(Icons.face, "Giới tính", gender),
                      _buildInfoRow(Icons.location_city, "Thành phố", city),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Settings Section Card
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "CÀI ĐẶT ỨNG DỤNG",
                    style: TextStyle(
                      color: Color(0xFF39FF14),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              Card(
                color: const Color(0xFF121212),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      secondary: const Icon(Icons.email, color: Color(0xFF39FF14)),
                      title: const Text("Nhận thông tin qua Email", style: TextStyle(color: Colors.white)),
                      subtitle: const Text("Nhận thông tin khuyến mãi vé phim", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      value: emailNotify,
                      activeColor: const Color(0xFF39FF14),
                      checkColor: Colors.black,
                      onChanged: (bool? value) {
                        setState(() {
                          emailNotify = value ?? false;
                        });
                        _saveSettings();
                      },
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    CheckboxListTile(
                      secondary: const Icon(Icons.notifications, color: Color(0xFF39FF14)),
                      title: const Text("Thông báo đẩy (Push)", style: TextStyle(color: Colors.white)),
                      subtitle: const Text("Nhận tin nhắn cập nhật suất chiếu hot", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      value: pushNotify,
                      activeColor: const Color(0xFF39FF14),
                      checkColor: Colors.black,
                      onChanged: (bool? value) {
                        setState(() {
                          pushNotify = value ?? false;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),

              if (role == "admin") ...[
                const SizedBox(height: 20),
                Card(
                  color: const Color(0xFF121212),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Color(0xFF39FF14), width: 1.2),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF39FF14)),
                    title: const Text("Giao diện Quản trị (Admin)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Quản lý phim, doanh thu và hóa đơn", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                      ).then((_) => _loadAllData());
                    },
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Đăng xuất
              Card(
                color: const Color(0xFF121212),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text("Đăng xuất", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: _logout,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF39FF14), size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
