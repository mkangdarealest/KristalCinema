import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../services/firestore_service.dart';

class AddEditMoviePage extends StatefulWidget {
  final Movie? movie; // null if adding a new movie

  const AddEditMoviePage({super.key, this.movie});

  @override
  State<AddEditMoviePage> createState() => _AddEditMoviePageState();
}

class _AddEditMoviePageState extends State<AddEditMoviePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController durationController;
  late TextEditingController genreController;
  late TextEditingController imageController;
  late TextEditingController synopsisController;

  bool isHot = false;
  String rating = "P";
  String status = "now_showing";
  bool isLoading = false;

  final List<String> ratings = ["P", "T13", "T16", "T18"];
  final List<Map<String, String>> statuses = [
    {"value": "now_showing", "label": "Đang chiếu (Now Showing)"},
    {"value": "coming_soon", "label": "Sắp chiếu (Coming Soon)"},
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.movie;
    titleController = TextEditingController(text: m?.title ?? "");
    durationController = TextEditingController(text: m?.duration ?? "120 phút");
    genreController = TextEditingController(text: m?.genre ?? "");
    imageController = TextEditingController(text: m?.image ?? "https://");
    synopsisController = TextEditingController(text: m?.synopsis ?? "");
    isHot = m?.isHot ?? false;
    rating = m?.rating ?? "P";
    status = m?.status ?? "now_showing";

    if (!ratings.contains(rating)) {
      rating = ratings.first;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    durationController.dispose();
    genreController.dispose();
    imageController.dispose();
    synopsisController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final movie = Movie(
      id: widget.movie?.id ?? "",
      title: titleController.text.trim(),
      image: imageController.text.trim(),
      isHot: isHot,
      rating: rating,
      duration: durationController.text.trim(),
      genre: genreController.text.trim(),
      synopsis: synopsisController.text.trim(),
      status: status,
    );

    try {
      await FirestoreService.saveMovie(movie);
      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate movie was saved
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lưu phim thành công!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi lưu phim: $e"),
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
    final isEdit = widget.movie != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isEdit ? "Chỉnh sửa phim" : "Thêm phim mới", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    // Tên phim
                    _buildTextField(
                      controller: titleController,
                      label: "Tên phim",
                      hint: "Nhập tên phim",
                      icon: Icons.movie,
                      validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập tên phim" : null,
                    ),
                    const SizedBox(height: 15),

                    // Thể loại
                    _buildTextField(
                      controller: genreController,
                      label: "Thể loại",
                      hint: "Ví dụ: Hành động, Kinh dị",
                      icon: Icons.category,
                      validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập thể loại" : null,
                    ),
                    const SizedBox(height: 15),

                    // Thời lượng & Rating row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: durationController,
                            label: "Thời lượng",
                            hint: "Ví dụ: 120 phút",
                            icon: Icons.timer,
                            validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập thời lượng" : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildDropdownField<String>(
                            label: "Độ tuổi (Rating)",
                            icon: Icons.family_restroom,
                            value: rating,
                            items: ratings.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => rating = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Trạng thái phim (Đang chiếu / Sắp chiếu)
                    _buildDropdownField<String>(
                      label: "Trạng thái hiển thị",
                      icon: Icons.visibility,
                      value: status,
                      items: statuses.map((s) => DropdownMenuItem(value: s["value"]!, child: Text(s["label"]!))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => status = val);
                      },
                    ),
                    const SizedBox(height: 15),

                    // Link poster
                    _buildTextField(
                      controller: imageController,
                      label: "Đường dẫn ảnh Poster",
                      hint: "Link ảnh poster (hoặc đường dẫn asset)",
                      icon: Icons.image,
                      validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập link ảnh" : null,
                    ),
                    const SizedBox(height: 15),

                    // Hot Movie Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Phim nổi bật (Slider Banner)", style: TextStyle(color: Colors.white)),
                      subtitle: const Text("Hiển thị lớn trên đầu trang chủ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      value: isHot,
                      activeThumbColor: const Color(0xFF39FF14),
                      activeTrackColor: const Color(0xFF1A5A1A),
                      onChanged: (val) => setState(() => isHot = val),
                    ),
                    const SizedBox(height: 15),

                    // Tóm tắt phim
                    _buildTextField(
                      controller: synopsisController,
                      label: "Tóm tắt nội dung",
                      hint: "Nhập tóm tắt cốt truyện phim...",
                      icon: Icons.description,
                      maxLines: 5,
                      validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập tóm tắt" : null,
                    ),
                    const SizedBox(height: 35),

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
                        child: const Text("LƯU THÔNG TIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
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
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
