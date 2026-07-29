import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> banners;
  final Function(int)? onTap;

  const BannerCarousel({super.key, required this.banners, this.onTap});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final CarouselSliderController controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CarouselSlider(
          carouselController: controller,
          items: widget.banners.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            return GestureDetector(
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!(index);
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: url.startsWith("assets/")
                    ? Image.asset(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            viewportFraction: 0.8,
          ),
        ),

        Positioned(
          left: 10,
          child: IconButton(
            onPressed: () {
              controller.previousPage();
            },
            icon: const CircleAvatar(
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        ),

        Positioned(
          right: 10,
          child: IconButton(
            onPressed: () {
              controller.nextPage();
            },
            icon: const CircleAvatar(
              child: Icon(Icons.arrow_forward_ios_rounded),
            ),
          ),
        ),
      ],
    );
  }
}
