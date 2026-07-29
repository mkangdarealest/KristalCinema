import 'package:flutter/material.dart';
import '../../models/cinema_model.dart';
import '../../models/movie_model.dart';
import '../../services/firestore_service.dart';
import '../widgets/logo_header.dart';
import 'booking_page.dart';

class CinemaPage extends StatefulWidget {
  const CinemaPage({super.key});

  @override
  State<CinemaPage> createState() => _CinemaPageState();
}

class _CinemaPageState extends State<CinemaPage> {
  Cinema? selectedCinema;
  List<Movie> activeMovies = [];
  List<Cinema> cinemas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final fetchedCinemas = await FirestoreService.getCinemas();
    final fetchedMovies = await FirestoreService.getMovies();
    if (!mounted) return;
    setState(() {
      cinemas = fetchedCinemas;
      activeMovies = fetchedMovies.where((m) => m.status == 'now_showing').toList();
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Logo Header at top
            const LogoHeader(height: 50),

            // Main body
            Expanded(
              child: selectedCinema == null
                  ? _buildCinemaList()
                  : _buildCinemaDetails(),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------
  // LIST OF MALLS
  //--------------------------------------------
  Widget _buildCinemaList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            "DANH SÁCH RẠP CHIẾU",
            style: TextStyle(
              color: Color(0xFF39FF14),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cinemas.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              final cinema = cinemas[index];
              return Card(
                color: const Color(0xFF121212),
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: const BorderSide(color: Colors.white10, width: 1),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedCinema = cinema;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                        child: Image.asset(
                          cinema.image,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cinema.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFF39FF14), size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    cinema.address,
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //--------------------------------------------
  // DETAILED VIEW FOR SELECTED MALL
  //--------------------------------------------
  Widget _buildCinemaDetails() {
    final cinema = selectedCinema!;

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          selectedCinema = null;
        });
        return false;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cinema Name and back button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF39FF14)),
                  onPressed: () {
                    setState(() {
                      selectedCinema = null;
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cinema.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cinema.address,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "PHIM ĐANG CHIẾU & LỊCH CHIẾU",
              style: TextStyle(
                color: Color(0xFF39FF14),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Movies showing at this mall
          Expanded(
            child: ListView.builder(
              itemCount: activeMovies.length,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (context, index) {
                final movie = activeMovies[index];

                return Card(
                  color: const Color(0xFF121212),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                movie.image,
                                width: 70,
                                height: 95,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    movie.genre,
                                    style: const TextStyle(
                                      color: Color(0xFF39FF14),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Thời lượng: ${movie.duration} | ${movie.rating}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Giờ chiếu khả dụng:",
                          style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // Showtimes chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: cinema.showtimes.map((time) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingPage(
                                      movie: movie,
                                      initialCinema: cinema,
                                      initialTime: time,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: const Color(0xFF39FF14), width: 0.5),
                                ),
                                child: Text(
                                  time,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
