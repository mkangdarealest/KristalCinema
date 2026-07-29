import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final avatarController = TextEditingController(
    text: "https://i.pravatar.cc/300",
  );

  String gender = "Male";
  String city = "Ho Chi Minh";

  bool agree = false;
  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    avatarController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đồng ý với Điều khoản sử dụng")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserModel user = UserModel(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        avatar: avatarController.text.trim(),
        gender: gender,
        city: city,
      );

      bool success = await AuthService.register(user);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (success) {
        fullNameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();

        avatarController.text = "https://i.pravatar.cc/300";

        gender = "Male";
        city = "Ho Chi Minh";
        agree = false;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng ký tài khoản thành công!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      String errorMessage = "Đăng ký thất bại. Vui lòng thử lại.";
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains("email-already-in-use")) {
        errorMessage = "Email này đã được sử dụng bởi một tài khoản khác.";
      } else if (errorStr.contains("weak-password")) {
        errorMessage = "Mật khẩu quá yếu. Vui lòng nhập tối thiểu 6 ký tự.";
      } else if (errorStr.contains("invalid-email")) {
        errorMessage = "Địa chỉ email không đúng định dạng.";
      } else if (errorStr.contains("network-request-failed")) {
        errorMessage = "Lỗi kết nối mạng. Vui lòng kiểm tra lại internet.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Register", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFF39FF14),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.movie_filter,
                      size: 60,
                      color: Color(0xFF39FF14),
                    );
                  },
                ),

                const SizedBox(height: 10),

                const Text(
                  "KRISTAL CINEMA",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF39FF14),
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: fullNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Full Name", Icons.person),
                  validator: (value) =>
                      value!.isEmpty ? "Enter Full Name" : null,
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Email", Icons.email),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter Email";
                    if (!value.contains("@")) return "Invalid Email";
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Phone", Icons.phone),
                  validator: (value) => value!.isEmpty ? "Enter Phone" : null,
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF39FF14)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF39FF14)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.length < 6) {
                      return "Password >= 6 characters";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: avatarController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Avatar URL", Icons.image),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Text(
                      "Gender:",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),

                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                unselectedWidgetColor: Colors.grey,
                              ),
                              child: RadioListTile<String>(
                                value: "Male",
                                groupValue: gender,
                                title: const Text("Male", style: TextStyle(color: Colors.white)),
                                activeColor: const Color(0xFF39FF14),
                                contentPadding: EdgeInsets.zero,
                                onChanged: (String? value) {
                                  setState(() {
                                    gender = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                unselectedWidgetColor: Colors.grey,
                              ),
                              child: RadioListTile<String>(
                                value: "Female",
                                groupValue: gender,
                                title: const Text("Female", style: TextStyle(color: Colors.white)),
                                activeColor: const Color(0xFF39FF14),
                                contentPadding: EdgeInsets.zero,
                                onChanged: (String? value) {
                                  setState(() {
                                    gender = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: city,
                  dropdownColor: Colors.grey.shade900,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "City",
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF39FF14)),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Ho Chi Minh",
                      child: Text("Ho Chi Minh"),
                    ),
                    DropdownMenuItem(value: "Can Tho", child: Text("Can Tho")),
                    DropdownMenuItem(
                      value: "Dong Nai",
                      child: Text("Dong Nai"),
                    ),
                    DropdownMenuItem(
                      value: "Dong Thap",
                      child: Text("Dong Thap"),
                    ),
                    DropdownMenuItem(
                      value: "An Giang",
                      child: Text("An Giang"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      city = value!;
                    });
                  },
                ),

                const SizedBox(height: 15),

                Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Colors.grey,
                  ),
                  child: CheckboxListTile(
                    value: agree,
                    title: const Text("I agree to the Terms", style: TextStyle(color: Colors.grey)),
                    activeColor: const Color(0xFF39FF14),
                    checkColor: Colors.black,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        agree = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF39FF14),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "REGISTER",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF39FF14)),
                      foregroundColor: const Color(0xFF39FF14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text("BACK TO LOGIN", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
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
    );
  }
}
