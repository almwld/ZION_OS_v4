import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class VideoPlayerApp extends StatefulWidget {
  const VideoPlayerApp({super.key});

  @override
  State<VideoPlayerApp> createState() => _VideoPlayerAppState();
}

class _VideoPlayerAppState extends State<VideoPlayerApp> {
  VideoPlayerController? _controller;
  int _selectedVideoIndex = 0;
  bool _isInitialized = false;
  bool _isPlaying = false;

  final List<Map<String, dynamic>> _videos = [
    {'name': 'Butterfly', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', 'duration': '0:30', 'size': '2.5 MB'},
    {'name': 'Bee', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', 'duration': '0:45', 'size': '3.2 MB'},
    {'name': 'Owl', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/owl.mp4', 'duration': '0:25', 'size': '1.8 MB'},
  ];

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(_videos[_selectedVideoIndex]['url']));
    await _controller!.initialize();
    setState(() => _isInitialized = true);
  }

  Future<void> _changeVideo(int index) async {
    setState(() {
      _selectedVideoIndex = index;
      _isInitialized = false;
      _isPlaying = false;
    });
    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(_videos[index]['url']));
    await _controller!.initialize();
    setState(() => _isInitialized = true);
  }

  void _play() { setState(() { _isPlaying = true; _controller!.play(); }); }
  void _pause() { setState(() { _isPlaying = false; _controller!.pause(); }); }
  void _replay() { _controller!.seekTo(Duration.zero); if (!_isPlaying) _play(); }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Player', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Container(
            height: 250,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF00BCD4).withOpacity(0.3), blurRadius: 20)]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _isInitialized
                  ? Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!)),
                        Container(
                          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.7), Colors.transparent])),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              VideoProgressIndicator(_controller!, allowScrubbing: true),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32), onPressed: _isPlaying ? _pause : _play),
                                  const SizedBox(width: 20),
                                  IconButton(icon: const Icon(Icons.replay, color: Colors.white, size: 28), onPressed: _replay),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_videos[_selectedVideoIndex]['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Duration: ${_videos[_selectedVideoIndex]['duration']} • Size: ${_videos[_selectedVideoIndex]['size']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.share, color: Color(0xFF00BCD4)), onPressed: () {
                  Clipboard.setData(ClipboardData(text: _videos[_selectedVideoIndex]['url']));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL copied'), backgroundColor: Color(0xFF00BCD4)));
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _videos.length,
              itemBuilder: (ctx, i) {
                final video = _videos[i];
                final isSelected = _selectedVideoIndex == i;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00BCD4).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? const Color(0xFF00BCD4) : const Color(0xFF00BCD4).withOpacity(0.3)),
                  ),
                  child: ListTile(
                    leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.play_circle_filled, color: Color(0xFF00BCD4), size: 32)),
                    title: Text(video['name'], style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${video['duration']} • ${video['size']}', style: const TextStyle(color: Colors.white54)),
                    trailing: IconButton(icon: const Icon(Icons.play_arrow, color: Color(0xFF00BCD4)), onPressed: () => _changeVideo(i)),
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
