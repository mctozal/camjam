import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _controller =
      PageController(viewportFraction: 0.3); // Adjust viewport fraction
  double _currentPage = 3.0; // Start from the center

  final List<String> _images = [
    "lib/assets/avatar_0.png",
    "lib/assets/avatar_1.png",
    "lib/assets/avatar_2.png",
    "lib/assets/avatar_3.png",
    "lib/assets/avatar_4.png",
    "lib/assets/avatar_5.png",
    "lib/assets/avatar_6.png",
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          // Adjust as needed
          height: 300,
          child: PageView.builder(
            controller: _controller,
            itemCount: _images.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              double scale = (index - _currentPage).abs();
              scale = 1 - (scale * 0.3); // Scale effect

              return Transform.scale(
                scale: scale.clamp(0.7, 1.3), // Center bigger, sides smaller
                child: CircleAvatar(
                  radius: 60,
                  child: Image.asset(_images[index]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
