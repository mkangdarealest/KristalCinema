class Cinema {
  final String id;
  final String name;
  final String address;
  final String image;
  final List<String> showtimes;

  Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.showtimes,
  });

  /// Chuyển từ JSON API sang Cinema object
  factory Cinema.fromJson(Map<String, dynamic> json) {
    List<String> times = ["09:30", "12:40", "15:15", "18:00", "20:30", "22:45"];
    if (json["showtimes"] is List) {
      times = (json["showtimes"] as List).map((e) => e.toString()).toList();
    }
    return Cinema(
      id: (json["id"] ?? json["cinemaId"] ?? json["CINEMA_ID"] ?? "").toString(),
      name: json["name"] ?? json["NAME"] ?? "",
      address: json["address"] ?? json["ADDRESS"] ?? "",
      image: json["image"] ?? json["IMAGE"] ?? json["imageUrl"] ?? "",
      showtimes: times,
    );
  }

  /// Tương thích fromFirestore cũ
  factory Cinema.fromFirestore(Map<String, dynamic> json, String docId) {
    final m = Map<String, dynamic>.from(json);
    m["id"] = docId;
    return Cinema.fromJson(m);
  }

  /// Chuyển Cinema sang Map để gửi qua REST API
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "address": address,
      "image": image,
      "showtimes": showtimes,
    };
  }

  /// Tương thích toFirestore cũ
  Map<String, dynamic> toFirestore() => toJson();

  static final List<Cinema> mockCinemas = [
    Cinema(
      id: "1",
      name: "KristalCinema Aeon Bình Tân",
      address: "Đường Số 17A, Bình Trị Đông B, Bình Tân, TP. Hồ Chí Minh",
      image: "assets/images/mall1.jpg",
      showtimes: ["09:30", "12:40", "15:15", "18:00", "20:30", "22:45"],
    ),
    Cinema(
      id: "2",
      name: "KristalCinema Aeon Tân Phú",
      address: "30 Bờ Bao Tân Thắng, Sơn Kỳ, Tân Phú, TP. Hồ Chí Minh",
      image: "assets/images/mall2.jpg",
      showtimes: ["10:00", "13:15", "16:00", "19:00", "21:30", "23:00"],
    ),
    Cinema(
      id: "3",
      name: "KristalCinema Vạn Hạnh Mall",
      address: "11 Sư Vạn Hạnh, Phường 12, Quận 10, TP. Hồ Chí Minh",
      image: "assets/images/mall3.jpg",
      showtimes: ["09:00", "11:45", "14:30", "17:15", "20:00", "22:30"],
    ),
    Cinema(
      id: "4",
      name: "KristalCinema GigaMall Thủ Đức",
      address: "240-242 Phạm Văn Đồng, Hiệp Bình Chánh, Thủ Đức, TP. Hồ Chí Minh",
      image: "assets/images/mall4.jpg",
      showtimes: ["10:30", "13:30", "16:15", "19:15", "21:45", "23:15"],
    ),
    Cinema(
      id: "5",
      name: "KristalCinema Crescent Mall Quận 7",
      address: "101 Tôn Dật Tiên, Tân Phú, Quận 7, TP. Hồ Chí Minh",
      image: "assets/images/mall5.jpg",
      showtimes: ["09:45", "12:15", "15:00", "18:15", "20:45", "22:50"],
    ),
  ];
}
