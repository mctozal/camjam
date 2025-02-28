import 'package:camjam/features/game/data/repositories/photo_repository.dart';
import 'package:flutter/material.dart';
import 'package:camjam/features/game/data/models/player.dart';
import 'package:image_downloader/image_downloader.dart';

class ResultScreen extends StatefulWidget {
  final List<Player> players;
  final String gameCode;
  final int numberOfRound;
  final int timePerRound;

  const ResultScreen(
      {super.key,
      required this.players,
      required this.gameCode,
      required this.numberOfRound,
      required this.timePerRound});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final PhotoRepository _photoRepository = PhotoRepository();
  List<Map<String, dynamic>>? _pictures;

  @override
  void initState() {
    super.initState();
    _loadPictures();
  }

  Future<void> _loadPictures() async {
    try {
      final pictures = await _photoRepository.getPictures(widget.gameCode);
      if (mounted) {
        setState(() {
          _pictures = pictures;
        });
      }
    } catch (e) {
      debugPrint('Error loading pictures: $e');
      if (mounted) {
        setState(() {
          _pictures = []; // Handle error by setting an empty list
        });
      }
    }
  }

  Future<void> _downloadMeme(String imageUrl) async {
    try {
      // Saved with this method.
      var imageId = await ImageDownloader.downloadImage(imageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image downloaded.')),
        );
      }
      if (imageId == null) {
        return;
      }
    } catch (e) {
      debugPrint('Error downloading meme: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download meme')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort players by score in descending order
    final sortedPlayers = widget.players.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final winner = sortedPlayers.isNotEmpty ? sortedPlayers.first : null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Ensure column takes minimal height
              children: [
                Image.asset(
                  'lib/assets/logo-small.png',
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (winner != null) ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      'What a Round!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.numberOfRound}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'The winner is',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0), // Add spacing for better layout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align items from top
                children: [
                  Expanded(
                    // Use Expanded to prevent overflow
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          winner.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Winner',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _infoText("Total Score:", winner.score.toString()),
                        _infoText("Shoot time:", '${widget.timePerRound} sec'),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    minRadius: 20,
                    maxRadius: 45,
                    backgroundImage: AssetImage('lib/assets/${winner.avatar}'),
                  ),
                ],
              ),
              if (_pictures != null && _pictures!.isNotEmpty) ...[
                const SizedBox(height: 16.0), // Add spacing before photo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      children: [
                        Image.network(
                          _pictures!
                              .where((pic) => pic['uploadedBy'] == winner.id)
                              .first['url']!, // Display the winner's photo
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height:
                              400, // Fixed height for the photo, adjust as needed
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text('Failed to load photo'),
                            );
                          },
                        ),
                        const SizedBox(
                            height: 8.0), // Spacing between image and button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () =>
                                  _downloadMeme(_pictures!.first['url']!),
                              tooltip: 'Download meme',
                            ),
                            const Text(
                              'Download Meme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0), // Add spacing before text
                        Center(
                          child: Column(
                            children: const [
                              Text(
                                "Don't forget to",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "collect memories!",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No photos available')),
                ),
            ] else
              const Center(child: Text('No players found')),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Go to home',
            style: TextStyle(fontSize: 18, color: Color(0xFF4E0F97)),
          ),
        ),
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
