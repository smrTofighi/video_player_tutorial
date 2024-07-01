import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

final List<String> _src = [
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
];
int _selectedIndex = 0;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(_src[_selectedIndex]));
    _controller.initialize().then((value) => setState(() {}));
    _controller.play();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final pos = await _controller.position;
                              final targetPos = pos!.inMilliseconds - 10000;
                              await _controller
                                  .seekTo(Duration(milliseconds: targetPos));
                            },
                            icon: const Icon(
                              Icons.fast_rewind_rounded,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _selectedIndex--;
                              _selectedIndex %= _src.length;
                              onChangeVideo();
                            },
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              _controller.value.isPlaying
                                  ? await _controller.pause()
                                  : await _controller.play();
                              setState(() {});
                            },
                            icon: Icon(_controller.value.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded),
                          ),
                          IconButton(
                            onPressed: () {
                              _selectedIndex++;
                              _selectedIndex %= _src.length;
                              onChangeVideo();
                            },
                            icon: const Icon(
                              Icons.skip_next_rounded,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final pos = await _controller.position;
                              final targetPos = pos!.inMilliseconds + 10000;
                              await _controller
                                  .seekTo(Duration(milliseconds: targetPos));
                            },
                            icon: const Icon(
                              Icons.fast_forward_rounded,
                            ),
                          ),
                        ],
                      ),
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                            playedColor: Colors.greenAccent,
                            backgroundColor: Colors.grey),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  onChangeVideo() async {
    _controller.dispose();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(_src[_selectedIndex]));
    _controller.addListener(() {
      setState(() {
        if (!_controller.value.isPlaying &&
            _controller.value.isInitialized &&
            (_controller.value.duration == _controller.value.position)) {
          _controller.seekTo(Duration.zero);
        }
      });
      _controller.initialize().then(
            (value) => setState(() {
              _controller.play();
            }),
          );
    });
  }
}
