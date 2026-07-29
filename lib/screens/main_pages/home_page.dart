import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../services/firestore_service.dart';
import '../widgets/banner_widget.dart';
import '../widgets/logo_header.dart';
import 'movie_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Movie> allMovies = [];
  List<Movie> hotMovies = [];
  List<Movie> nowShowing = [];
  List<Movie> comingSoon = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadMovies() async {
    final movies = await FirestoreService.getMovies();
    if (!mounted) return;
    setState(() {
      allMovies = movies;
      hotMovies = movies.where((m) => m.isHot).toList();
      nowShowing = movies.where((m) => m.status == 'now_showing').toList();
      comingSoon = movies.where((m) => m.status == 'coming_soon').toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF39FF14),
          ),
        ),
      );
    }

    final hotBanners = hotMovies.map((m) => m.image).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Header
              const LogoHeader(height: 50),

              // Ô tìm kiếm đẹp mắt
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: const Color(0xFF39FF14),
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm tên phim hoặc thể loại...",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF39FF14)),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                searchQuery = "";
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Color(0xFF39FF14), width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Kiểm tra xem người dùng đang tìm kiếm hay duyệt bình thường
              if (searchQuery.isNotEmpty)
                _buildSearchResults()
              else ...[
                // Banner Carousel
                if (hotBanners.isNotEmpty)
                  BannerCarousel(
                    banners: hotBanners,
                    onTap: (index) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailPage(movie: hotMovies[index]),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 25),

                // Now Showing Section
                if (nowShowing.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "PHIM ĐANG CHIẾU",
                      style: TextStyle(
                        color: Color(0xFF39FF14),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMovieRow(nowShowing),
                  const SizedBox(height: 30),
                ],

                // Coming Soon Section
                if (comingSoon.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "PHIM SẮP CHIẾU",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMovieRow(comingSoon),
                  const SizedBox(height: 30),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final filtered = allMovies.where((m) {
      return m.title.toLowerCase().contains(searchQuery) ||
          m.genre.toLowerCase().contains(searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.movie_creation_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Không tìm thấy phim phù hợp",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final movie = filtered[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailPage(movie: movie),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: movie.image.startsWith("http")
                        ? Image.network(
                            movie.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Image.asset(
                            movie.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      movie.rating,
                      style: const TextStyle(
                        color: Color(0xFF39FF14),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      movie.duration,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieRow(List<Movie> movies) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailPage(movie: movie),
                  ),
                );
              },
              child: SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: movie.image.startsWith("http")
                            ? Image.network(
                                movie.image,
                                fit: BoxFit.cover,
                                width: 140,
                              )
                            : Image.asset(
                                movie.image,
                                fit: BoxFit.cover,
                                width: 140,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          movie.rating,
                          style: const TextStyle(
                            color: Color(0xFF39FF14),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          movie.duration,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
