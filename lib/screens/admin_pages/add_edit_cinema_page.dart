import 'package:flutter/material.dart';
import '../../models/cinema_model.dart';
import '../../services/firestore_service.dart';

class AddEditCinemaPage extends StatefulWidget {
  final Cinema? cinema; // null if adding a new cinema

  const AddEditCinemaPage({super.key, this.cinema});

  @override
  State<AddEditCinemaPage> createState() => _AddEditCinemaPageState();
}

class _AddEditCinemaPageState extends State<AddEditCinemaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController imageController;
  late TextEditingController showtimesController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cinema;
    nameController = TextEditingController(text: c?.name ?? "");
    addressController = TextEditingController(text: c?.address ?? "");
    imageController = TextEditingController(text: c?.image ?? "assets/images/mall1.jpg");
    showtimesController = TextEditingController(
      text: c?.showtimes.join(", ") ?? "09:30, 13:30, 16:00, 19:30, 22:00",
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    imageController.dispose();
    showtimesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    // Tách các suất chiếu bằng dấu phẩy
    final showtimes = showtimesController.text
        .split(",")
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final cinema = Cinema(
      id: widget.cinema?.id ?? "",
      name: nameController.text.trim(),
      address: addressController.text.trim(),
      image: imageController.text.trim(),
      showtimes: showtimes,
    );

    try {
      await FirestoreService.saveCinema(cinema);
      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lưu rạp chiếu thành công!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi lưu rạp chiếu: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cinema != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isEdit ? "Chỉnh sửa rạp" : "Thêm rạp chiếu mới", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF39FF14)))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên rạp
                    _buildTextField(
                      controller: nameController,
                      label: "Tên rạp chiếu",
                      hint: "Ví dụ: KristalCinema Aeon Bình Tân",
                      icon: Icons.domain,
                      validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập tên rạp" : null,
                    ),
                    const SizedBox(height: 15),

                    // Địa chỉ rạp
                    _buildTextField(
                      controller: addressController,
                      label: "Địa chỉ chi tiết",
                      hint: "Nhập địa chỉ của rạp...",
                      icon: Icons.location_on,
                      validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập địa chỉ" : null,
                    ),
                    const SizedBox(height: 15),

                    // Đường dẫn ảnh
                    _buildTextField(
                      controller: imageController,
                      label: "Đường dẫn hình ảnh",
                      hint: "Ví dụ: assets/images/mall1.jpg hoặc link web",
                      icon: Icons.image,
                      validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập đường dẫn ảnh" : null,
                    ),
                    const SizedBox(height: 15),

                    // Suất chiếu mặc định
                    _buildTextField(
                      controller: showtimesController,
                      label: "Danh sách suất chiếu (Cách nhau bởi dấu phẩy)",
                      hint: "Ví dụ: 09:30, 13:30, 16:00, 19:30, 22:00",
                      icon: Icons.access_time,
                      validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập suất chiếu" : null,
                    ),
                    const SizedBox(height: 40),

                    // Nút Lưu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF39FF14),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _save,
                        child: const Text("LƯU THÔNG TIN RẠP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF39FF14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF39FF14)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: validator,
    );
  }
}
