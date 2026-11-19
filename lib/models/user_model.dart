class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String avatar;
  final String gender;
  final String city;
  final String role;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.avatar,
    required this.gender,
    required this.city,
    this.role = "user",
  });

  /// Chuyển Object -> Map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) "userId": id,
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

  /// Tương thích toFirestore cũ
  Map<String, dynamic> toFirestore() => toJson();

  /// Chuyển Map / JSON -> Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["userId"] ?? json["id"] ?? "",
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      password: json["password"] ?? "",
      avatar: json["avatar"] ?? "",
      gender: json["gender"] ?? "Khác",
      city: json["city"] ?? "TP. Hồ Chí Minh",
      role: json["role"] ?? "user",
    );
  }

  @override
  String toString() {
    return '''
UserModel(
  id: $id,
  fullName: $fullName,
  email: $email,
  phone: $phone,
  avatar: $avatar,
  gender: $gender,
  city: $city,
  role: $role
)
''';
  }
}
