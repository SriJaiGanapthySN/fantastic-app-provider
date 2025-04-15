import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

class PlayAudio extends StatefulWidget {
  final String email;
  // final QueryDocumentSnapshot couching;
  final Map<String, dynamic> coachingData;
  // final Map<String,dynamic> coachingSeries;

  const PlayAudio({
    super.key,
    required this.email,
    // required this.couching,
    required this.coachingData,
    // required this.coachingSeries
  });

  @override
  State<PlayAudio> createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {
  final AudioPlayer audioPlayer = AudioPlayer();
  String htmlContent = '';
  bool isPlaying = true;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool ran = false;
  bool isMuted = false;

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void initState() {
    super.initState();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    _fetchContent(widget.coachingData["contentUrl"]);
    _playSound(widget.coachingData["audioUrl"]);
  }

  Future<void> _fetchContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          htmlContent = response.body; // Set the HTML content
        });
      } else {
        print("Failed to load content: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching content: $e");
    }
  }

  void toggle() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _playSound(String audioLink) async {
    try {
      // await audioPlayer.play(AssetSource('audio/sample.m4a'));
      await audioPlayer.play(UrlSource(audioLink));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _stopSound() async {
    try {
      await audioPlayer.pause();
    } catch (e) {
      print("Error stopping sound: $e");
    }
  }

  void _voice() {
    setState(() {
      isMuted = !isMuted;
    });
    audioPlayer.setVolume(isMuted ? 0 : 1);
  }

  @override
  void dispose() {
    audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20),
            child: SizedBox(
              height: 30,
              width: 100,
              child: ElevatedButton.icon(
                onPressed: _voice,
                label: Text(
                  isMuted ? "On" : "Off",
                  style: TextStyle(color: Colors.white),
                ),
                icon: Icon(
                    isMuted ? Icons.notifications_on : Icons.notifications_off),
                style: ElevatedButton.styleFrom(
                  elevation: 0.5,
                  backgroundColor: Colors.grey[800],
                  iconColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 60),
        child: Column(
          children: [
            SizedBox(
                height: 120,
                width: 400,
                child: Lottie.asset('assets/animations/audio.json')),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 35,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 0),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 2),
                        trackShape: RoundedRectSliderTrackShape(),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 20, right: 10),
                        child: SizedBox(
                          width: 300,
                          child: Slider(
                            activeColor: Colors.white38,
                            inactiveColor: Colors.white12,
                            min: 0,
                            max: duration.inSeconds.toDouble(),
                            value: position.inSeconds.toDouble(),
                            onChanged: (value) {
                              final newPosition =
                                  Duration(seconds: value.toInt());
                              audioPlayer.seek(newPosition);
                              audioPlayer.resume();
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      child: Text(
                        "-${formatTime((duration - position).inSeconds)}",
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 203, 199, 199),
                        ),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white12,
                  child: IconButton(
                      onPressed: () {
                        if (!isPlaying) {
                          _playSound(widget.coachingData["audioUrl"]);
                          toggle();
                        } else {
                          _stopSound();
                          toggle();
                        }
                      },
                      icon: isPlaying
                          ? Icon(Icons.pause, color: Colors.white38)
                          : Icon(Icons.play_arrow, color: Colors.white38)),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                // Conditionally display the Share Button
                if (!ran)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.coachingData["type"] == "FOCUS"
                            ? Colors.orange
                            : widget.coachingData["type"] == "NIGHTLY"
                                ? Colors.black38
                                : Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 26,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Share",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Conditionally display the Share Icon + Add to Morning Routine Button
                if (ran)
                  Row(
                    children: [
                      // Share Icon Button
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      // Add to Morning Routine Button
                      SizedBox(
                        width: 270,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          label: Text(
                            "Add to Morning Routine",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Divider(
                color: const Color.fromARGB(255, 229, 227, 227),
                thickness: 1,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: htmlContent.isNotEmpty
                  ? SingleChildScrollView(
                      child: Html(
                        data: htmlContent,
                        style: {
                          "body": Style(
                            color: Colors.white,
                            fontSize: FontSize(18), // Increased font size
                            lineHeight: LineHeight(
                                1.5), // Adjust line height for better readability
                          ),
                          "p": Style(
                            color: Colors.white,
                            fontSize:
                                FontSize(18), // Apply font size to paragraphs
                          ),
                          "h1": Style(
                            color: Colors.white,
                            fontSize: FontSize(
                                22), // Apply larger font size to headings
                            fontWeight: FontWeight.bold,
                          ),
                          "h2": Style(
                            color: Colors.white,
                            fontSize:
                                FontSize(20), // Apply font size to subheadings
                            fontWeight: FontWeight.bold,
                          ),
                        },
                      ),
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
