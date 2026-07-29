import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/preference_service.dart';
import '../../models/user_model.dart';

import 'register_page.dart';
import '../main_pages/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    loadRememberMe();
  }

  Future<void> loadRememberMe() async {
    bool remember = await PreferenceService.getRememberMe();
    if (remember) {
      UserModel? user = await PreferenceService.getUser();
      if (user != null) {
        setState(() {
          rememberMe = true;
          emailController.text = user.email;
          passwordController.text = user.password;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      bool success = await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (success) {
        // Lưu trạng thái ghi nhớ đăng nhập
        await PreferenceService.setRememberMe(rememberMe);
        if (rememberMe) {
          final user = UserModel(
            fullName: "",
            email: emailController.text.trim(),
            phone: "",
            password: passwordController.text.trim(),
            avatar: "",
            gender: "",
            city: "",
          );
          await PreferenceService.saveUser(user);
        }

        // Lấy lịch sử đăng nhập từ SharedPreferences
        List<String> history = await AuthService.getHistory();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đăng nhập thành công!\nSố lần đăng nhập: ${history.length}"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      
      String errorMessage = "Đăng nhập thất bại. Vui lòng kiểm tra lại.";
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains("invalid-credential") || 
          errorStr.contains("user-not-found") || 
          errorStr.contains("wrong-password")) {
        errorMessage = "Email hoặc Mật khẩu không chính xác.";
      } else if (errorStr.contains("network-request-failed")) {
        errorMessage = "Lỗi kết nối mạng. Vui lòng kiểm tra lại internet.";
      } else if (errorStr.contains("invalid-email")) {
        errorMessage = "Định dạng Email không hợp lệ.";
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.movie_filter,
                        size: 80,
                        color: Color(0xFF39FF14),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "KRISTAL CINEMA",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF39FF14),
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 40),

                  //-----------------------------------
                  // EMAIL
                  //-----------------------------------
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF39FF14)),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập Email";
                      }

                      if (value.trim() != "admin01" && !value.contains("@")) {
                        return "Định dạng Email không hợp lệ";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  //-----------------------------------
                  // PASSWORD
                  //-----------------------------------
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
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter password";
                      }

                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }

                      return null;
                    },
                  ),
                  CheckboxListTile(
                    value: rememberMe,
                    title: const Text("Remember me?", style: TextStyle(color: Colors.grey)),
                    activeColor: const Color(0xFF39FF14),
                    checkColor: Colors.black,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  //-----------------------------------
                  // LOGIN BUTTON
                  //-----------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
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
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(color: Colors.white24),

                  const SizedBox(height: 10),

                  //-----------------------------------
                  // REGISTER
                  //-----------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: Color(0xFF39FF14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
