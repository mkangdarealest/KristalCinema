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

  /// Chuyển từ Firestore Document sang Cinema object
  factory Cinema.fromFirestore(Map<String, dynamic> json, String docId) {
    return Cinema(
      id: docId,
      name: json["name"] ?? "",
      address: json["address"] ?? "",
      image: json["image"] ?? json["imageUrl"] ?? "",
      showtimes: json["showtimes"] is List 
          ? List<String>.from(json["showtimes"]) 
          : ["09:00", "12:00", "15:00", "18:00", "21:00"],
    );
  }

  /// Chuyển Cinema sang Map để lưu trên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "address": address,
      "image": image,
      "showtimes": showtimes,
    };
  }

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
