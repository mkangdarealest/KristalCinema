class Movie {
  final String id;
  final String title;
  final String image;
  final bool isHot;
  final String genre;
  final String duration;
  final String rating;
  final String synopsis;
  final String status; // 'now_showing' hoặc 'coming_soon'

  Movie({
    required this.id,
    required this.title,
    required this.image,
    required this.isHot,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.synopsis,
    required this.status,
  });

  /// Chuyển từ JSON API sang Movie object
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: (json["id"] ?? json["movieId"] ?? json["MOVIE_ID"] ?? "").toString(),
      title: json["title"] ?? json["TITLE"] ?? "",
      image: json["image"] ?? json["IMAGE"] ?? json["posterUrl"] ?? "",
      isHot: json["isHot"] == true || json["isHot"] == 1 || json["IS_HOT"] == 1,
      genre: json["genre"] is List
          ? (json["genre"] as List).join(", ")
          : (json["genre"] ?? json["GENRE"] ?? ""),
      duration: json["duration"] is num
          ? "${json["duration"]} phút"
          : (json["duration"] ?? json["DURATION"] ?? ""),
      rating: json["rating"] ?? json["RATING"] ?? "",
      synopsis: json["synopsis"] ?? json["SYNOPSIS"] ?? "",
      status: json["status"] ?? json["STATUS"] ?? "now_showing",
    );
  }

  /// Tương thích fromFirestore cũ
  factory Movie.fromFirestore(Map<String, dynamic> json, String docId) {
    final m = Map<String, dynamic>.from(json);
    m["id"] = docId;
    return Movie.fromJson(m);
  }

  /// Chuyển Movie sang Map để gửi qua REST API
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "image": image,
      "isHot": isHot,
      "genre": genre,
      "duration": duration,
      "rating": rating,
      "synopsis": synopsis,
      "status": status,
    };
  }

  /// Tương thích toFirestore cũ
  Map<String, dynamic> toFirestore() => toJson();

  static final List<Movie> mockMovies = [
    // Hot movies
    Movie(
      id: "1",
      title: "MƯA ĐỎ",
      image: "assets/images/poster(hot).webp",
      isHot: true,
      genre: "lịch sử, chiến tranh, chính kịch",
      duration: "124 phút",
      rating: "T18",
      synopsis: "Phim Mưa Đỏ (đạo diễn Đặng Thái Huyền) là một bản hùng ca bi tráng tái hiện 81 ngày đêm khốc liệt tại Thành cổ Quảng Trị năm 1972. Tác phẩm mang đến trải nghiệm điện ảnh cảm động, chân thực, giúp khán giả tri ân những người lính, dẫu vậy vẫn còn một số điểm trừ nhỏ ở tuyến tình cảm.",
      status: "now_showing",
    ),
    Movie(
      id: "2",
      title: "MA XÓ",
      image: "assets/images/poster1(hot).jpg",
      isHot: true,
      genre: " Kinh dị, Tâm lý ",
      duration: "145 phút",
      rating: "T13",
      synopsis: "Ma Xó là bộ phim điện ảnh Việt Nam thuộc thể loại kinh dị (18+). Tác phẩm xoay quanh câu chuyện tâm linh kỳ bí tại miền Tây sông nước, khai thác chủ đề nuôi ma xó (thế lực siêu nhiên giữ nhà) và bi kịch xuất phát từ tình thân, lòng tham cùng những lời cầu xin trả giá.",
      status: "now_showing",
    ),
    Movie(
      id: "3",
      title: "MẮT BIẾC",
      image: "assets/images/poster2(hot).jpg",
      isHot: true,
      genre: "Truyện dài, văn học thanh thiếu niên, tình cảm",
      duration: "135 phút",
      rating: "P",
      synopsis: "Mắt Biếc của nhà văn Nguyễn Nhật Ánh là một cuốn truyện dài (hoặc tiểu thuyết) thuộc thể loại văn học lãng mạn. Nội dung xoay quanh mối tình đơn phương da diết của Ngạn dành cho Hà Lan - cô bạn thuở ấu thơ có đôi mắt hút hồn, vẽ nên một bức tranh thanh xuân trong trẻo nhưng đượm buồn.",
      status: "now_showing",
    ),
    // Now showing movies
    Movie(
      id: "4",
      title: "MAI",
      image: "assets/images/poster3.jpg",
      isHot: false,
      genre: "tâm lý, tình cảm, hài hước",
      duration: "120 phút",
      rating: "T16",
      synopsis: "Phim xoay quanh cuộc đời của Mai (Phương Anh Đào), một nữ nhân viên mát-xa tuổi gần 40 mang nhiều tổn thương. Dù có quá khứ tăm tối và luôn phải chịu định kiến cay nghiệt từ xã hội, cô vẫn giữ khát khao được yêu thương chân thành. ",
      status: "now_showing",
    ),
    Movie(
      id: "5",
      title: "TITANIC",
      image: "assets/images/poster4.jpg",
      isHot: false,
      genre: "lãng mạn, phiêu lưu và thảm họa",
      duration: "115 phút",
      rating: "T18",
      synopsis: "Titanic là bộ phim điện ảnh kinh điển của Mỹ ra mắt năm 1997, thuộc thể loại lãng mạn, phiêu lưu và thảm họa. Phim tái hiện lại thảm họa đắm tàu RMS Titanic có thật vào năm 1912, lồng ghép cùng câu chuyện tình yêu đầy bi tráng giữa hai nhân vật hư cấu.",
      status: "now_showing",
    ),
    // Coming soon movies
    Movie(
      id: "6",
      title: "SPIDER MAN: NO WAY HOME",
      image: "assets/images/poster5.jpg",
      isHot: false,
      genre: "hành động, khoa học viễn tưởng",
      duration: "128 phút",
      rating: "T16",
      synopsis: "Nội dung phim bắt đầu ngay sau phần trước khi danh tính bí mật của Peter Parker bị kẻ phản diện Mysterio tiết lộ cho toàn thế giới. Việc bị công khai là Người Nhện khiến cuộc sống của Peter cùng những người thân yêu (như MJ và Ned) bị đảo lộn và gặp vô vàn rắc rối.",
      status: "coming_soon",
    ),
    Movie(
      id: "7",
      title: "KUNGFU PANDA 4",
      image: "assets/images/poster6.jpg",
      isHot: false,
      genre: "Hoạt hình, hài hước, võ thuật",
      duration: "110 phút",
      rating: "T18",
      synopsis: "Trong phần 4, đại sư Shifu thông báo Po (do Jack Black lồng tiếng) đã đến lúc từ bỏ danh hiệu Thần Long Đại Hiệp để đảm nhận vị trí Lãnh đạo tinh thần. Po không muốn từ bỏ công việc đánh đấm quen violent, đồng thời phải đối mặt với một mối đe dọa mới là Tắc Kè Hoa (The Chameleon).",
      status: "coming_soon",
    ),
    Movie(
      id: "8",
      title: "BỐ GIÀ",
      image: "assets/images/poster7.webp",
      isHot: false,
      genre: "tâm lý, gia đình, hài kịch và đời sống",
      duration: "105 phút",
      rating: "P",
      synopsis: "Phim tập trung vào ông Ba Sang (Trấn Thành) – một người đàn ông làm nghề chở hàng thuê, tính tình bao đồng nhưng luôn hết lòng hy sinh vì gia đình. Trái ngược với ông là cậu con trai Quắn (Tuấn Trần) – một YouTuber hiện đại, kiếm tiền giỏi nhưng có cái tôi cao và tư tưởng sống khác biệt.",
      status: "coming_soon",
    ),
    Movie(
      id: "9",
      title: "ĐỊA ĐẠO",
      image: "assets/images/poster8.jpg",
      isHot: false,
      genre: "Lịch sử, Chiến tranh, Chính kịch",
      duration: "130 phút",
      rating: "T18",
      synopsis: "Phim điện ảnh Địa Đạo tái hiện cuộc chiến tranh nhân dân kiên cường tại vùng đất thép Củ Chi, tôn vinh ý chí bất khuất của các chiến sĩ và đồng bào trong những năm tháng kháng chiến.",
      status: "coming_soon",
    ),
  ];
}
