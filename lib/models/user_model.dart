class UserModel {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String avatar;
  final String gender;
  final String city;
  final String role;

  UserModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.avatar,
    required this.gender,
    required this.city,
    this.role = "user",
  });

  /// Chuyển Object -> Map (bao gồm password cho lưu cục bộ nếu cần)
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "phone": phone,
      "password": password,
      "avatar": avatar,
      "gender": gender,
      "city": city,
      "role": role,
    };
  }

  /// Chuyển Object -> Map để lưu lên Firestore (Không lưu password)
  Map<String, dynamic> toFirestore() {
    return {
      "fullName": fullName,
      "email": email,
      "phone": phone,
      "avatar": avatar,
      "gender": gender,
      "city": city,
      "role": role,
    };
  }

  /// Chuyển Map -> Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      password: json["password"] ?? "",
      avatar: json["avatar"] ?? "",
      gender: json["gender"] ?? "",
      city: json["city"] ?? "",
      role: json["role"] ?? "user",
    );
  }

  @override
  String toString() {
    return '''
UserModel(
  fullName: $fullName,
  email: $email,
  phone: $phone,
  password: $password,
  avatar: $avatar,
  gender: $gender,
  city: $city,
  role: $role
)
''';
  }
}
