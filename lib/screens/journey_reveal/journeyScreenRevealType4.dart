import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class JourneyRevealScreenType4 extends StatefulWidget {
  final Map<String, dynamic> journeyrevealtype4;

  const JourneyRevealScreenType4({Key? key, required this.journeyrevealtype4})
      : super(key: key);

  @override
  _JourneyRevealScreenType4State createState() =>
      _JourneyRevealScreenType4State();
}

class _JourneyRevealScreenType4State extends State<JourneyRevealScreenType4> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  String? _htmlContent;
  bool _isLoadingHtml = true;
  String? _htmlError;

  // Extracting data for easier access
  String get contentTitle => widget.journeyrevealtype4['contentTitle'] ?? 'No Title';
  String get headlineImageUrl => widget.journeyrevealtype4['headlineImageUrl'] ?? '';
  String get audioUrl => widget.journeyrevealtype4['audioUrl'] ?? '';
  String get contentUrl => widget.journeyrevealtype4['contentUrl'] ?? '';
  String get contentReadingTime => widget.journeyrevealtype4['contentReadingTime'] ?? '';


  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      if (mounted) {
        setState(() => _playerState = s);
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      if (mounted) {
        setState(() => _duration = d);
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      if (mounted) {
        setState(() => _position = p);
      }
    });

    _initAudioPlayer();
    _fetchHtmlContent();
  }

  Future<void> _initAudioPlayer() async {
    if (audioUrl.isNotEmpty) {
      try {
        await _audioPlayer.setSourceUrl(audioUrl);
      } catch (e) {
        print("Error setting audio source: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading audio: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _fetchHtmlContent() async {
    if (contentUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingHtml = false;
          _htmlError = "Content URL is missing.";
        });
      }
      return;
    }
    try {
      final response = await http.get(Uri.parse(contentUrl));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _htmlContent = response.body;
            _isLoadingHtml = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingHtml = false;
            _htmlError = 'Failed to load content: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHtml = false;
          _htmlError = 'Error fetching content: $e';
        });
      }
      print("Error fetching HTML: $e");
    }
  }

  Future<void> _play() async {
    if (audioUrl.isNotEmpty) {
      await _audioPlayer.resume();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio URL is not available.')),
        );
      }
    }
  }

  Future<void> _pause() async {
    await _audioPlayer.pause();
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _position = Duration.zero;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildAudioPlayerControls() {
    if (audioUrl.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Audio not available for this content.", textAlign: TextAlign.center),
      );
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _playerState == PlayerState.playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  iconSize: 64.0,
                  onPressed: _playerState == PlayerState.playing ? _pause : _play,
                ),
                if (_playerState != PlayerState.stopped && _playerState != PlayerState.completed)
                  IconButton(
                    icon: const Icon(Icons.stop_circle_outlined),
                    iconSize: 32.0,
                    onPressed: _stop,
                  ),
              ],
            ),
            if (_duration.inMilliseconds > 0) ...[
              Slider(
                onChanged: (value) async {
                  final newPosition = Duration(milliseconds: value.toInt());
                  await _audioPlayer.seek(newPosition);
                  // Optional: Play if it was paused for seeking
                  // if (_playerState == PlayerState.paused) {
                  //   _play();
                  // }
                },
                value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble()),
                min: 0.0,
                max: _duration.inMilliseconds.toDouble(),
                activeColor: Theme.of(context).primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_position)),
                    Text(_formatDuration(_duration)),
                  ],
                ),
              ),
            // ] else if (_playerState == PlayerState.) ...[
            //   const SizedBox(height: 10),
            //   const CircularProgressIndicator(),
            //   const SizedBox(height: 10),
            //   const Text("Loading audio..."),
            ] else ... [
              const SizedBox(height: 10),
              Text(contentReadingTime.isNotEmpty ? "Audio: $contentReadingTime" : "Audio controls will appear here"),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildHtmlContent() {
    if (_isLoadingHtml) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_htmlError != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Error: $_htmlError", style: const TextStyle(color: Colors.red)),
      );
    }
    if (_htmlContent != null && _htmlContent!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Html(
          data: _htmlContent,
          style: { // Basic styling, you can customize further
            "body": Style(
              fontSize: FontSize.medium,
              lineHeight: LineHeight.number(1.5),
            ),
            "h1": Style(fontSize: FontSize.xxLarge, fontWeight: FontWeight.bold),
            "h2": Style(fontSize: FontSize.xLarge, fontWeight: FontWeight.bold),
            "p": Style(margin: Margins.symmetric(vertical: 10.0)),
          },
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text("No content available to display."),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get safe area padding, especially for the top.
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      // No AppBar
      body: Stack(
        children: [
          // Scrollable Content
          Padding(
            // Add padding at the top so the scrollable content starts below the back button
            padding: EdgeInsets.only(top: topPadding + 40), // 40 is arbitrary for button height + spacing
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 1. Content Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Text(
                      contentTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 2. Headline Image
                  if (headlineImageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          headlineImageUrl,
                          fit: BoxFit.cover,
                          height: 200, // Adjust height as needed
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Center(
                        child: Text("Image not available", style: TextStyle(color: Colors.grey)),
                      ),
                    ),

                  // Reading time info (optional, but good to have)
                  if (contentReadingTime.isNotEmpty && audioUrl.isEmpty) // Show if no audio, or for context
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Text(
                        "Reading time: $contentReadingTime",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),


                  // 3. Audio Player
                  _buildAudioPlayerControls(),

                  // 4. HTML Content
                  _buildHtmlContent(),

                  // Spacer for the bottom button
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Fixed Back Arrow at the Top Left
          Positioned(
            top: topPadding + 8.0, // Respect safe area
            left: 8.0,
            child: Container( // Optional: Add a background for better visibility
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: 'Go back',
              ),
            ),
          ),
        ],
      ),

      // Fixed Bottom Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(fontSize: 18),
            // backgroundColor: Theme.of(context).primaryColor, // Use theme color
            // foregroundColor: Colors.white,
          ),
          onPressed: () {
            // TODO: Implement "Done, What's Next?" functionality
            print("Done, What's Next? button pressed!");
            // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigating to next step... (Not implemented)')),
            );
          },
          child: const Text("Done, What's Next?"),
        ),
      ),
    );
  }
}