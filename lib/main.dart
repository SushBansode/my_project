// ignore_for_file: prefer_const_constructors, unused_field, unused_element, use_key_in_widget_constructors, deprecated_member_use, library_private_types_in_public_api, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(const MaterialApp(
    home: VideoPlayerDemo(),
  ));
}

class VideoPlayerDemo extends StatefulWidget {
  const VideoPlayerDemo({Key? key}) : super(key: key);

  @override
  State<VideoPlayerDemo> createState() => _VideoPlayerDemoState();
}

class _VideoPlayerDemoState extends State<VideoPlayerDemo> {
  int index = 0;
  double _position = 0;
  double _buffer = 0;
  bool _lock = true;
  bool _areControlsVisible = true;
  double _playbackSpeed = 1.0;
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<int, VoidCallback> _listeners = {};
  static const _urls = {
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4#1',
    'https://pca-franctelbucket.s3.ap-south-1.amazonaws.com/Analyzer/AnalyzerAdmin/grayscale.MP4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4#2',
    'https://pca-franctelbucket.s3.ap-south-1.amazonaws.com/Analyzer/AnalyzerAdmin/grayscale.MP4#1',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4#3',
    'https://pca-franctelbucket.s3.ap-south-1.amazonaws.com/Analyzer/AnalyzerAdmin/grayscale.MP4#2',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4#4',
    'https://pca-franctelbucket.s3.ap-south-1.amazonaws.com/Analyzer/AnalyzerAdmin/grayscale.MP4#3',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4#5',
    'https://pca-franctelbucket.s3.ap-south-1.amazonaws.com/Analyzer/AnalyzerAdmin/grayscale.MP4#4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4#6',
    'https://pca-franctelbucket.s3.ap-south-1.amazonaws.com/Analyzer/AnalyzerAdmin/grayscale.MP4#5',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4#7',
    'https://pca-franctelbucket.s3.ap-south-1.amazonaws.com/Analyzer/AnalyzerAdmin/grayscale.MP4#6',
  };

  @override
  void initState() {
    super.initState();
    Wakelock.enable();

    if (_urls.isNotEmpty) {
      _initController(0).then((_) {
        _playController(0);
      });
    }

    if (_urls.length > 1) {
      _initController(1).whenComplete(() => _lock = false);
    }
  }

  VoidCallback _listenerSpawner(index) {
    return () {
      int dur = _controller(index).value.duration.inMilliseconds;
      int pos = _controller(index).value.position.inMilliseconds;
      int buf = _controller(index).value.buffered.last.end.inMilliseconds;

      setState(() {
        if (dur <= pos) {
          _position = 0;
          return;
        }
        _position = pos / dur;
        _buffer = buf / dur;
      });
      if (dur - pos < 1) {
        if (index < _urls.length - 1) {
          _nextVideo();
        }
      }
    };
  }

  VideoPlayerController _controller(int index) {
    return _controllers[_urls.elementAt(index)]!;
  }

  // Future<void> _initController(int index) async {
  //   final url = Uri.parse(_urls.elementAt(index));
  //   var controller = VideoPlayerController.network(url.toString());
  //   _controllers[_urls.elementAt(index)] = controller;
  //   await controller.initialize();
  // }

  Future<void> _initController(int index) async {
    final url = Uri.parse(_urls.elementAt(index));
    var controller = VideoPlayerController.network(url.toString())
      ..setPlaybackSpeed(_playbackSpeed);
    _controllers[_urls.elementAt(index)] = controller;
    await controller.initialize();
  }

  void _removeController(int index) {
    _controller(index).dispose();
    _controllers.remove(_urls.elementAt(index));
    _listeners.remove(index);
  }

  void _stopController(int index) {
    _controller(index).removeListener(_listeners[index]!);
    _controller(index).pause();
    _controller(index).seekTo(const Duration(milliseconds: 0));
  }

  void _playController(int index) async {
    if (!_listeners.keys.contains(index)) {
      _listeners[index] = _listenerSpawner(index);
    }
    _controller(index).addListener(_listeners[index]!);
    await _controller(index).play();
    setState(() {});
  }

  void _previousVideo() {
    if (_lock || index == 0) {
      return;
    }
    _lock = true;

    _stopController(index);

    if (index + 1 < _urls.length) {
      _removeController(index + 1);
    }

    _playController(--index);

    if (index == 0) {
      _lock = false;
    } else {
      _initController(index - 1).whenComplete(() => _lock = false);
    }
  }

  void _nextVideo() async {
    if (_lock || index == _urls.length - 1) {
      return;
    }
    _lock = true;

    _stopController(index);

    if (index - 1 >= 0) {
      _removeController(index - 1);
    }

    _playController(++index);

    if (index == _urls.length - 1) {
      _lock = false;
    } else {
      _initController(index + 1).whenComplete(() => _lock = false);
    }
  }

  // void _toggleFullscreen() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>
  //           FullscreenVideoPlayer(controller: _controller(index)),
  //     ),
  //   );
  // }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Playback Speed'),
          content: Column(
            children: [
              ListTile(
                title: Text('0.25x'),
                onTap: () {
                  _setPlaybackSpeed(0.25);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('0.5x'),
                onTap: () {
                  _setPlaybackSpeed(0.5);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('0.75x'),
                onTap: () {
                  _setPlaybackSpeed(0.75);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('1.0x'),
                onTap: () {
                  _setPlaybackSpeed(1.0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('1.25x'),
                onTap: () {
                  _setPlaybackSpeed(1.25);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('1.5x'),
                onTap: () {
                  _setPlaybackSpeed(1.5);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('1.75x'),
                onTap: () {
                  _setPlaybackSpeed(1.75);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('2.0x'),
                onTap: () {
                  _setPlaybackSpeed(2.0);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      _controller(index).setPlaybackSpeed(speed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playing ${index + 1} of ${_urls.length}"),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _areControlsVisible = !_areControlsVisible;
          });
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller(index).value.aspectRatio,
            child: Stack(
              children: <Widget>[
                VideoPlayer(_controller(index)),
                Visibility(
                  visible: _areControlsVisible,
                  child: Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.fast_rewind,
                            color: Colors.red,
                          ),
                          onPressed: _previousVideo,
                        ),
                        IconButton(
                          icon: Icon(
                            _controller(index).value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            if (_controller(index).value.isPlaying) {
                              _controller(index).pause();
                            } else {
                              _controller(index).play();
                            }
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.fast_forward,
                            color: Colors.red,
                          ),
                          onPressed: _nextVideo,
                        ),
                        Expanded(
                          child: Slider(
                            value: _position,
                            activeColor: Colors.red,
                            inactiveColor: Colors.white,
                            onChanged: (value) {
                              int dur = _controller(index)
                                  .value
                                  .duration
                                  .inMilliseconds;
                              setState(() {
                                _position = value;
                                _controller(index).seekTo(Duration(
                                    milliseconds: (value * dur).round()));
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.red,
                          ),
                          onPressed: _showSpeedDialog,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class FullscreenVideoPlayer extends StatefulWidget {
//   final VideoPlayerController controller;

//   const FullscreenVideoPlayer({required this.controller});

//   @override
//   _FullscreenVideoPlayerState createState() => _FullscreenVideoPlayerState();
// }

// class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
//   late double _position;
//   late double _buffer;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     Wakelock.enable();
//     _position = 0;
//     _buffer = 0;

//     widget.controller.addListener(_listener);
//     widget.controller.play();
//     setState(() {
//       _isPlaying = true;
//     });
//   }

//   @override
//   void dispose() {
//     Wakelock.disable();
//     widget.controller.removeListener(_listener);
//     super.dispose();
//   }

//   void _listener() {
//     if (mounted) {
//       int dur = widget.controller.value.duration.inMilliseconds;
//       int pos = widget.controller.value.position.inMilliseconds;
//       int buf = widget.controller.value.buffered.last.end.inMilliseconds;

//       setState(() {
//         if (dur <= pos) {
//           _position = 0;
//           return;
//         }
//         _position = pos / dur;
//         _buffer = buf / dur;
//       });

//       if (dur - pos < 1) {}
//     }
//   }

//   void _togglePlayPause() {
//     if (_isPlaying) {
//       widget.controller.pause();
//     } else {
//       widget.controller.play();
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   void _seekForward() {
//     final Duration duration = widget.controller.value.duration;
//     final int newPosition = (widget.controller.value.position.inSeconds + 10)
//         .clamp(0, duration.inSeconds);
//     widget.controller.seekTo(Duration(seconds: newPosition));
//   }

//   void _seekBackward() {
//     final Duration duration = widget.controller.value.duration;
//     final int newPosition = (widget.controller.value.position.inSeconds - 10)
//         .clamp(0, duration.inSeconds);
//     widget.controller.seekTo(Duration(seconds: newPosition));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: widget.controller.value.aspectRatio,
//           child: Stack(
//             children: <Widget>[
//               VideoPlayer(widget.controller),
//               Positioned(
//                 bottom: 16,
//                 left: 16,
//                 right: 16,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.fast_rewind),
//                       onPressed: _seekBackward,
//                     ),
//                     IconButton(
//                       icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//                       onPressed: _togglePlayPause,
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.fast_forward),
//                       onPressed: _seekForward,
//                     ),
//                     Expanded(
//                       child: Slider(
//                         value: _position,
//                         onChanged: (value) {
//                           int dur =
//                               widget.controller.value.duration.inMilliseconds;
//                           setState(() {
//                             _position = value;
//                             widget.controller.seekTo(
//                                 Duration(milliseconds: (value * dur).round()));
//                           });
//                         },
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.fullscreen_exit),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//}

