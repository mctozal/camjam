import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final Function(String) onImageSelected;

  ImageCarousel({required this.onImageSelected});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  static const int _initialPage = 3; // Start from the middle
  late PageController _controller;
  String _selectedImage = "";

  final List<String> _images = [
    "avatar_0.png",
    "avatar_1.png",
    "avatar_2.png",
    "avatar_3.png",
    "avatar_4.png",
    "avatar_5.png",
    "avatar_6.png",
  ];

  final List<String> _avatarNames = [
    "Clumsy Jellybelly",
    "Captain Procrastinator",
    "Waffle Wizard",
    "The Caffeine Comet",
    "Unicorn on Roller Skates",
    "The Sneaky Burrito",
    "Chillzilla",
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        PageController(viewportFraction: 0.3, initialPage: _initialPage);
    _selectedImage = _images[_initialPage]; // Set initial selection

    _controller.addListener(_onPageChanged);
  }

  // Helper method for calculating the scale
  double _getScale(int index) {
    if (_controller.hasClients) {
      double pageValue = _controller.page ?? _initialPage.toDouble();
      double scale = 1 - (index - pageValue).abs() * 0.3;
      return scale.clamp(0.7, 1.3); // Ensure proper scaling
    }
    return 1.0;
  }

  // Listener method to handle page changes
  void _onPageChanged() {
    if (_controller.hasClients && _controller.page != null) {
      int closestIndex = _controller.page!.round();
      if (_selectedImage != _images[closestIndex]) {
        setState(() {
          _selectedImage = _images[closestIndex];
        });
        widget.onImageSelected(_selectedImage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _selectedImage = _images[index];
              });
              widget.onImageSelected(_selectedImage);
            },
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _controller.animateToPage(
                    index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Transform.scale(
                  scale: _getScale(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        foregroundImage:
                            AssetImage('lib/assets/' + _images[index]),
                        minRadius: 30,
                        maxRadius: 75,
                        backgroundColor: _selectedImage == _images[index]
                            ? Colors.blueAccent // Highlight selected avatar
                            : Colors.transparent,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _avatarNames[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  @override
  void dispose() {
    _controller.removeListener(_onPageChanged);
    _controller.dispose();
    super.dispose();
  }
}
