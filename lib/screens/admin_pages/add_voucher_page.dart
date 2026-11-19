import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class AddVoucherPage extends StatefulWidget {
  final Map<String, dynamic>? voucher; // null if adding a new voucher

  const AddVoucherPage({super.key, this.voucher});

  @override
  State<AddVoucherPage> createState() => _AddVoucherPageState();
}

class _AddVoucherPageState extends State<AddVoucherPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController codeController;
  late TextEditingController discountController;
  late TextEditingController minPriceController;

  bool isActive = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final v = widget.voucher;
    codeController = TextEditingController(text: v?['code'] ?? "");
    discountController = TextEditingController(text: v?['discountAmount']?.toString() ?? "30000");
    minPriceController = TextEditingController(text: v?['minPrice']?.toString() ?? "100000");
    isActive = v?['isActive'] ?? true;
  }

  @override
  void dispose() {
    codeController.dispose();
    discountController.dispose();
    minPriceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final discount = int.tryParse(discountController.text.trim()) ?? 0;
    final minPrice = int.tryParse(minPriceController.text.trim()) ?? 0;

    final data = {
      'id': widget.voucher?['id'] ?? "",
      'code': codeController.text.trim().toUpperCase(),
      'discountAmount': discount,
      'minPrice': minPrice,
      'isActive': isActive,
    };

    try {
      await FirestoreService.saveVoucher(data);
      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lưu mã Voucher thành công!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi lưu Voucher: $e"),
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
    final isEdit = widget.voucher != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isEdit ? "Chỉnh sửa Voucher" : "Thêm Voucher mới", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    // Mã Voucher
                    _buildTextField(
                      controller: codeController,
                      label: "Mã giảm giá (Voucher Code)",
                      hint: "Ví dụ: KRISTAL30K",
                      icon: Icons.local_offer,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Vui lòng nhập mã giảm giá";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Số tiền giảm
                    _buildTextField(
                      controller: discountController,
                      label: "Số tiền giảm giá (VNĐ)",
                      hint: "Ví dụ: 30000",
                      icon: Icons.monetization_on,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Vui lòng nhập số tiền giảm";
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return "Vui lòng nhập số hợp lệ";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Giá trị đơn hàng tối thiểu
                    _buildTextField(
                      controller: minPriceController,
                      label: "Giá trị đơn hàng tối thiểu (VNĐ)",
                      hint: "Ví dụ: 100000",
                      icon: Icons.shopping_cart,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Vui lòng nhập giá trị đơn tối thiểu";
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return "Vui lòng nhập số hợp lệ";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Switch Hoạt động
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Trạng thái kích hoạt", style: TextStyle(color: Colors.white)),
                      subtitle: const Text("Cho phép người dùng áp dụng mã này khi thanh toán", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      value: isActive,
                      activeThumbColor: const Color(0xFF39FF14),
                      activeTrackColor: const Color(0xFF1A5A1A),
                      onChanged: (val) => setState(() => isActive = val),
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
                        child: const Text("LƯU VOUCHER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
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
